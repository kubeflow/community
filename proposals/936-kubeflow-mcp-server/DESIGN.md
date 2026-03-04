# KEP-936: Design Specification

This document contains detailed design specifications for the Kubeflow MCP Server. For the proposal overview, see [README.md](README.md).

## Table of Contents

- [Tool Implementation Details](#tool-implementation-details)
- [MCP-to-SDK Bridge](#mcp-to-sdk-bridge)
- [Resource Estimation Algorithm](#resource-estimation-algorithm)
- [Package Structure](#package-structure)
- [Persona Configuration](#persona-configuration)
- [CLI Usage](#cli-usage)
- [Client Configuration](#client-configuration)
- [Tool Behavior Details](#tool-behavior-details)
- [Two-Phase Confirmation Pattern](#two-phase-confirmation-pattern)
- [Authentication Implementation](#authentication-implementation)
- [Dependencies](#dependencies)
- [Gateway Deployment (Enterprise)](#gateway-deployment-enterprise)
- [MCP Protocol Implementation](#mcp-protocol-implementation)
- [Installation](#installation)
- [Configuration File](#configuration-file)
- [Distribution](#distribution)
- [Secret Management](#secret-management)
- [Audit Logging](#audit-logging)
- [OpenTelemetry Integration (Phase 3)](#opentelemetry-integration-phase-3)
- [Phase 5: Additional Client Modules](#phase-5-additional-client-modules)
- [Compatibility Matrix](#compatibility-matrix)

---

## Tool Implementation Details

### Training Tools

```python
from kubernetes.client.exceptions import ApiException
from kubeflow.trainer import (
    TrainerClient, BuiltinTrainer, CustomTrainer, CustomTrainerContainer,
    TorchTuneConfig, LoraConfig, Initializer,
    HuggingFaceModelInitializer, HuggingFaceDatasetInitializer,
)

@mcp.tool()
def fine_tune(
    model: str,
    dataset: str,
    peft_method: str = "lora",
    epochs: int = 3,
    batch_size: int = 4,
    num_nodes: int = 1,
    resources_per_node: dict | None = None,
    runtime: str | None = None,
    confirmed: bool = False,
) -> dict:
    """Fine-tune an LLM using BuiltinTrainer with TorchTune.
    
    Use this for zero-code fine-tuning of HuggingFace models.
    Internally calls: TrainerClient.train(trainer=BuiltinTrainer(...))
    """
    if not confirmed:
        return {"status": "preview", "message": "Set confirmed=True to submit training job",
                "config": {"model": model, "dataset": dataset, "peft_method": peft_method,
                          "epochs": epochs, "batch_size": batch_size, "num_nodes": num_nodes}}
    
    try:
        client = TrainerClient()
        trainer = BuiltinTrainer(
            config=TorchTuneConfig(
                epochs=epochs, batch_size=batch_size, num_nodes=num_nodes,
                resources_per_node=resources_per_node,
                peft_config=LoraConfig(lora_rank=16, lora_alpha=32) if peft_method == "lora" else None,
            )
        )
        initializer = Initializer(
            model=HuggingFaceModelInitializer(storage_uri=f"hf://{model}"),
            dataset=HuggingFaceDatasetInitializer(storage_uri=f"hf://{dataset}"),
        )
        job_name = client.train(runtime=runtime, trainer=trainer, initializer=initializer)
        return {"success": True, "job_id": job_name, "trainer_type": "BuiltinTrainer"}
    except ApiException as e:
        return {"success": False, "error": f"Kubernetes API error: {e.reason}", "status_code": e.status}
    except Exception as e:
        return {"success": False, "error": str(e)}

@mcp.tool()
def run_custom_training(
    func_code: str,
    func_args: dict | None = None,
    packages_to_install: list[str] | None = None,
    num_nodes: int = 1,
    resources_per_node: dict | None = None,
    runtime: str | None = None,
    confirmed: bool = False,
) -> dict:
    """Run distributed training with user-provided Python code.
    
    The func_code must define a `train(**kwargs)` function.
    MCP Bridge: func_code (str) is converted to Callable via importlib.
    """
    if not confirmed:
        return {"status": "preview", "message": "Set confirmed=True to submit training job",
                "config": {"func_args": func_args, "num_nodes": num_nodes,
                          "packages_to_install": packages_to_install}}
    
    # Step 1: AST validation (fail fast, defense-in-depth)
    import ast
    try:
        tree = ast.parse(func_code)
        func_names = set()
        for node in ast.walk(tree):
            if isinstance(node, ast.FunctionDef):
                func_names.add(node.name)
            # Security checks (defense-in-depth, not a sandbox)
            if isinstance(node, ast.Import):
                for alias in node.names:
                    if alias.name.split('.')[0] in {"os", "subprocess", "sys", "shutil", "socket", "importlib"}:
                        return {"success": False, "error": f"Import '{alias.name}' not allowed. Use run_container_training() for system access."}
            if isinstance(node, ast.Call) and isinstance(node.func, ast.Name):
                if node.func.id in {"eval", "exec", "compile", "__import__", "open"}:
                    return {"success": False, "error": f"'{node.func.id}()' not allowed. Use run_container_training() instead."}
        if "train" not in func_names:
            return {"success": False, "error": "Script must define a 'train(**kwargs)' function"}
    except SyntaxError as e:
        return {"success": False, "error": f"Invalid Python syntax: {e}"}
    
    # Step 2: Convert to Callable (file required for SDK's inspect.getsource())
    import tempfile, importlib.util, hashlib, os
    script_hash = hashlib.md5(func_code.encode()).hexdigest()[:8]
    temp_path = None
    
    try:
        with tempfile.NamedTemporaryFile(
            mode='w', suffix='.py', prefix=f'mcp_train_{script_hash}_', delete=False
        ) as f:
            f.write(func_code)
            temp_path = f.name
        
        spec = importlib.util.spec_from_file_location("training_module", temp_path)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        train_func = module.train
        
        client = TrainerClient()
        trainer = CustomTrainer(
            func=train_func, func_args=func_args, packages_to_install=packages_to_install,
            num_nodes=num_nodes, resources_per_node=resources_per_node,
        )
        job_name = client.train(runtime=runtime, trainer=trainer)
        return {"success": True, "job_id": job_name, "trainer_type": "CustomTrainer"}
    except ApiException as e:
        return {"success": False, "error": f"Kubernetes API error: {e.reason}", "status_code": e.status}
    except Exception as e:
        return {"success": False, "error": str(e)}
    finally:
        if temp_path and os.path.exists(temp_path):
            os.unlink(temp_path)

@mcp.tool()
def run_container_training(
    image: str,
    num_nodes: int = 1,
    resources_per_node: dict | None = None,
    env: dict | None = None,
    runtime: str | None = None,
    confirmed: bool = False,
) -> dict:
    """Run training with a pre-built container image."""
    if not confirmed:
        return {"status": "preview", "message": "Set confirmed=True to submit training job",
                "config": {"image": image, "num_nodes": num_nodes, "env": env}}
    
    try:
        client = TrainerClient()
        trainer = CustomTrainerContainer(
            image=image, num_nodes=num_nodes, resources_per_node=resources_per_node, env=env,
        )
        job_name = client.train(runtime=runtime, trainer=trainer)
        return {"success": True, "job_id": job_name, "trainer_type": "CustomTrainerContainer"}
    except ApiException as e:
        return {"success": False, "error": f"Kubernetes API error: {e.reason}", "status_code": e.status}
    except Exception as e:
        return {"success": False, "error": str(e)}
```

---

## MCP-to-SDK Bridge

The SDK's `CustomTrainer` expects `func: Callable`, but MCP only transports JSON-serializable data. The MCP server bridges this gap:

```
MCP Layer:     func_code: str (Python source code)
                     |
                     v  [1. AST validation - fail fast]
                     |
                     v  [2. importlib conversion - file-backed for inspect.getsource()]
SDK Layer:     func: Callable (Python function object)
```

**Why file-backed?** The SDK internally calls `inspect.getsource(func)` to extract code for the container entrypoint. Using `exec()` alone would break this.

**Security Note:** The `func_code` is executed within K8s pods, not on the MCP server host. For untrusted code, prefer `run_container_training()` with pre-built images.

---

## Resource Estimation Algorithm

```python
def estimate_resources(
    model: str, 
    peft_method: str,
    batch_size: int = 4,
    sequence_length: int = 2048,
    quantization: str = "bf16",  # "fp32", "bf16", "fp16", "int8", "int4"
    num_nodes: int = 1,
) -> dict:
    # Step 1: Lookup model metadata from HuggingFace
    model_info = get_model_info(model)  # Uses HF Hub API
    param_count = model_info.get("num_parameters", None)
    num_layers = model_info.get("num_hidden_layers", 32)
    hidden_size = model_info.get("hidden_size", 4096)
    
    # Step 2: Calculate base model memory
    quant_bytes = {"fp32": 4, "bf16": 2, "fp16": 2, "int8": 1, "int4": 0.5}
    base_memory_gb = (param_count * quant_bytes[quantization]) / (1024**3)
    
    # Step 3: Activation memory (scales with batch_size × sequence_length)
    # Dominant factor for LoRA; ~2 bytes per activation per layer
    activation_memory_gb = (batch_size * sequence_length * num_layers * hidden_size * 2) / (1024**3)
    
    # Step 4: Optimizer and gradient memory
    if peft_method == "full":
        optimizer_memory_gb = base_memory_gb * 2  # AdamW: 2x model for states
        gradient_memory_gb = base_memory_gb
    else:  # LoRA/QLoRA: only adapter weights need gradients
        optimizer_memory_gb = base_memory_gb * 0.1
        gradient_memory_gb = base_memory_gb * 0.05
    
    total_memory_gb = base_memory_gb + activation_memory_gb + optimizer_memory_gb + gradient_memory_gb
    
    return {
        "model": model,
        "param_count": param_count,
        "breakdown": {
            "model": round(base_memory_gb, 1),
            "activations": round(activation_memory_gb, 1),
            "optimizer": round(optimizer_memory_gb, 1),
            "gradients": round(gradient_memory_gb, 1),
        },
        "total_gpu_memory_gb": round(total_memory_gb, 1),
        "recommended_gpu": recommend_gpu(total_memory_gb),
        "confidence": "high" if param_count else "low",
    }
```

**Note:** Activation memory scales linearly with `batch_size × sequence_length` and is often the dominant factor for parameter-efficient methods. See [Memory-Efficient Fine-Tuning](https://arxiv.org/abs/2501.18824) for detailed analysis.

| Trainer Type | Estimation Method |
|--------------|-------------------|
| `BuiltinTrainer` (TorchTune) | Model registry lookup + recipe-based calculation |
| `BuiltinTrainer` (TRL) | *Future:* TRL-specific memory profiling |
| `CustomTrainer` | User-provided hints or conservative defaults |
| `CustomTrainerContainer` | Container metadata or user-provided hints |

---

## Package Structure

```
kubeflow-mcp/
├── pyproject.toml
├── src/kubeflow_mcp/
│   ├── __init__.py
│   ├── server.py                      # FastMCP server with dynamic tool loading
│   │
│   ├── core/                          # Shared utilities (always loaded)
│   │   ├── auth.py                    # K8s authentication
│   │   ├── policy.py                  # Persona-based policy enforcement
│   │   ├── resources.py               # get_cluster_resources()
│   │   └── config.py
│   │
│   ├── clients/                       # SDK client modules (selectively loaded)
│   │   ├── trainer/                   # TrainerClient tools (15 tools)
│   │   │   ├── __init__.py            # MODULE_INFO, TOOLS, INSTRUCTIONS
│   │   │   ├── training.py            # fine_tune, run_custom_training, run_container_training
│   │   │   ├── discovery.py           # list_training_jobs, get_training_job, etc.
│   │   │   ├── monitoring.py          # get_training_logs, get_training_events
│   │   │   └── lifecycle.py           # delete, suspend, resume
│   │   │
│   │   ├── optimizer/                 # OptimizerClient tools (8 tools)
│   │   └── hub/                       # ModelRegistryClient tools (6 tools)
│   │
│   ├── policies/                      # Persona definitions
│   └── cli.py
```

### Client Module Interface

```python
# kubeflow_mcp/clients/trainer/__init__.py
MODULE_INFO = {
    "name": "trainer",
    "sdk_client": "TrainerClient",
    "sdk_import": "kubeflow.trainer",
    "description": "Distributed training and LLM fine-tuning",
}

TOOLS = [fine_tune, run_custom_training, run_container_training, ...]

INSTRUCTIONS = """
TRAINER MODULE - Distributed Training & LLM Fine-Tuning

WORKFLOW: Fine-Tuning - fine_tune(model, dataset, confirmed=True)
WORKFLOW: Custom Training - run_custom_training(func_code, func_args, confirmed=True)
WORKFLOW: Container Training - run_container_training(image, confirmed=True)
"""
```

### Dynamic Tool Loading

```python
def create_server(clients: list[str] | None = None, persona: str = "ml-engineer") -> FastMCP:
    if clients is None:
        clients = detect_available_clients()
    
    all_tools = [get_cluster_resources]
    for client_name in clients:
        module = importlib.import_module(f"kubeflow_mcp.clients.{client_name}")
        all_tools.extend(module.TOOLS)
    
    filtered_tools = filter_tools_by_persona(all_tools, persona)
    mcp = FastMCP("kubeflow-mcp")
    for tool in filtered_tools:
        mcp.tool()(tool)
    return mcp
```

---

## Persona Configuration

```yaml
# Persona tool visibility
personas:
  readonly:
    tools:
      - get_cluster_resources
      - list_training_jobs
      - get_training_job
      - get_training_logs
      - get_training_events
      - list_runtimes
      - get_runtime
      
  data-scientist:
    inherit: readonly           # 7 readonly + 5 = 12 total
    tools:
      - estimate_resources
      - fine_tune
      - run_custom_training
      - wait_for_training
      - delete_training_job
      
  ml-engineer:
    inherit: data-scientist     # 12 data-scientist + 4 = 16 total
    tools:
      - run_container_training
      - get_runtime_packages
      - suspend_training_job
      - resume_training_job
      
  platform-admin:
    tools: "*"                   # All 16 tools
```

### Policy Configuration

```yaml
# ~/.kf-mcp-policy.yaml
policy:
  allow:
    - category:discovery
    - category:monitoring
    - category:planning
    - fine_tune
  deny:
    - risk:destructive
    - delete_*
  namespaces:
    - ml-team-dev
    - ml-team-prod
  read_only: false
```

---

## CLI Usage

```bash
# Auto-detect available clients
kubeflow-mcp serve

# Load specific clients
kubeflow-mcp serve --clients trainer
kubeflow-mcp serve --clients trainer,optimizer,hub

# With persona filtering
kubeflow-mcp serve --clients trainer --persona data-scientist

# List available modules
kubeflow-mcp clients list
```

---

## Client Configuration

**Claude Desktop** (`~/.claude/claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "kubeflow": {
      "command": "kubeflow-mcp",
      "args": ["serve", "--clients", "trainer,optimizer"]
    }
  }
}
```

**Cursor IDE** (`.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "kubeflow-trainer": {
      "command": "kubeflow-mcp",
      "args": ["serve", "--clients", "trainer", "--persona", "data-scientist"]
    }
  }
}
```

---

## Tool Behavior Details

### `wait_for_training` Timeout

```python
@mcp.tool()
def wait_for_training(
    job_id: str,
    timeout: int = 3600,      # Default: 1 hour
    poll_interval: int = 30,
) -> dict:
    """Returns current status on timeout (doesn't cancel job)."""
```

### `get_training_logs` Rate Limiting

- `follow=True` rate-limited to 1 req/sec per job
- Cached results (TTL: 5 seconds) for repeated calls
- `tail` capped at 1000 lines

---

## Two-Phase Confirmation Pattern

Training tools use a confirmation pattern to prevent accidental resource consumption:

```
Phase 1: Preview (confirmed=False, default)
┌─────────────────────────────────────────────────────────────────┐
│ User: "Fine-tune Qwen on alpaca"                                │
│ AI Agent calls: fine_tune(model="Qwen/Qwen2.5-7B", ...,         │
│                           confirmed=False)                      │
│ Returns: {"status": "preview", "config": {...}}                 │
│ AI Agent: "I'll fine-tune Qwen with these settings. Proceed?"   │
└─────────────────────────────────────────────────────────────────┘

Phase 2: Execute (confirmed=True, after user approval)
┌─────────────────────────────────────────────────────────────────┐
│ User: "Yes, go ahead"                                           │
│ AI Agent calls: fine_tune(..., confirmed=True)                  │
│ Returns: {"success": true, "job_id": "ft-qwen-abc123"}          │
└─────────────────────────────────────────────────────────────────┘
```

**Key behaviors:**
- The **AI agent** is responsible for the confirmation flow, NOT the MCP server
- When `confirmed=False` (default), tools return a preview with resolved configuration
- The AI agent presents this preview to the user and asks for approval
- Only after explicit user approval should the agent call with `confirmed=True`
- MCP clients (Claude, Cursor) typically enforce this via their human-in-the-loop UX

---

## Authentication Implementation

### Multi-User In-Cluster (Istio Integration)

```python
# kubeflow_mcp/core/auth.py
import kubernetes
from starlette.requests import Request

def get_user_identity(request: Request) -> dict:
    return {
        "user": request.headers.get("x-user-email", "anonymous"),
        "groups": request.headers.get("x-user-groups", "").split(","),
        "namespace": request.headers.get("x-user-namespace", "default"),
    }

def create_k8s_client_for_user(user_identity: dict) -> kubernetes.client.ApiClient:
    config = kubernetes.client.Configuration()
    config.api_key = {"authorization": f"Bearer {get_sa_token()}"}
    client = kubernetes.client.ApiClient(config)
    client.set_default_header("Impersonate-User", user_identity["user"])
    return client
```

### Required RBAC

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kubeflow-mcp-impersonator
rules:
- apiGroups: [""]
  resources: ["users", "groups"]
  verbs: ["impersonate"]
```

---

## Dependencies

```toml
[project]
name = "kubeflow-mcp"
dependencies = [
    "mcp>=1.0.0",
    "kubernetes>=28.0.0",
    "pyyaml>=6.0",
]

[project.optional-dependencies]
trainer = ["kubeflow>=0.3.0"]
optimizer = ["kubeflow>=0.3.0"]
hub = ["kubeflow[hub]>=0.3.0"]
all = ["kubeflow[hub]>=0.3.0"]
```

---

## Gateway Deployment (Enterprise)

For multi-tenant enterprise deployments, kubeflow-mcp can run behind an MCP gateway ([Microsoft](https://github.com/microsoft/mcp-gateway), [IBM Context Forge](https://ibm.github.io/mcp-context-forge/), [Red Hat](https://developers.redhat.com/articles/2025/12/12/advanced-authentication-authorization-mcp-gateway)):

```yaml
# Gateway-compatible mode
server:
  auth_mode: "gateway"  # Trust gateway headers, skip local auth
  required_headers:
    - "x-authenticated-user"
    - "x-user-groups"
    - "x-request-id"  # For audit correlation
```

**Gateway benefits:**
- OAuth2 Token Exchange (RFC 8693) for narrowly-scoped backend tokens
- Centralized identity-based tool filtering
- Session-aware routing for stateful operations
- Vault integration for credential management

---

## MCP Protocol Implementation

Using [FastMCP](https://gofastmcp.com) for protocol handling:

```python
from mcp.server.fastmcp import FastMCP

mcp = FastMCP(
    "kubeflow-mcp",
    instructions="""
    Kubeflow MCP Server - AI Model Training on Kubernetes
    
    WORKFLOW: Fine-Tuning LLMs
    1. get_cluster_resources() - Check GPU availability
    2. estimate_resources(model, peft_method) - Memory requirements
    3. fine_tune(model, dataset, ..., confirmed=True) - Submit job
    4. get_training_job(job_id) / get_training_logs(job_id) - Monitor
    
    WORKFLOW: Custom Training Code
    1. get_cluster_resources() - Check GPU availability
    2. run_custom_training(func_code, func_args, ..., confirmed=True) - Submit job
    3. get_training_logs(job_id) - View output
    
    TOOL SELECTION:
    - Fine-tune HuggingFace models: fine_tune()
    - Run custom training function: run_custom_training()
    - Run pre-built container: run_container_training()
    """
)
```

---

## Installation

```bash
# Base package (no SDK clients)
pip install kubeflow-mcp

# With specific clients
pip install kubeflow-mcp[trainer]
pip install kubeflow-mcp[trainer,optimizer]
pip install kubeflow-mcp[all]
```

---

## Configuration File

```yaml
# ~/.kubeflow-mcp.yaml
server:
  clients:
    - trainer
    - optimizer
    # - hub           # Commented = not loaded
  
  # Or auto-detect from cluster
  # clients: auto
  
  persona: ml-engineer
  
  namespaces:
    - ml-team-dev
    - ml-team-prod

# Per-client configuration
trainer:
  default_runtime: torch-distributed
  
optimizer:
  default_algorithm: random
```

---

## Distribution

| Channel | Format | Use Case |
|---------|--------|----------|
| **PyPI** | `pip install kubeflow-mcp[trainer]` | Local development, CI/CD |
| **Container** | `ghcr.io/kubeflow/kubeflow-mcp` | Kubernetes, ToolHive |
| **Marketplace** | Smithery, Glama | Discovery, OAuth UI |

**Transport Support:** stdio (Claude Desktop, Cursor) and StreamableHTTP (VS Code, LlamaStack, remote deployments) via FastMCP.

---

## Secret Management

| Secret Type | Storage | Access Pattern |
|-------------|---------|----------------|
| HuggingFace Token | K8s Secret (`hf-token`) | Mounted to training pods, never logged |
| S3 Credentials | K8s Secret | Mounted to initializer pods |
| Model Weights | PVC | Downloaded by initializers, not MCP |

**Best Practices:**
- Secrets should **never** be returned in tool responses
- Container logs should be filtered to redact tokens

---

## Audit Logging

The MCP server will log all tool invocations for audit:

```json
{
  "timestamp": "2026-01-29T10:30:00Z",
  "tool": "fine_tune",
  "user": "user@example.com",
  "namespace": "ml-team-dev",
  "parameters": {"model": "Qwen/Qwen2.5-7B", "dataset": "alpaca", "peft_method": "lora"},
  "result": "success",
  "job_id": "ft-qwen-abc123"
}
```

**Note:** Sensitive parameters (tokens, credentials) are **redacted** from logs.

---

## OpenTelemetry Integration (Phase 3)

FastMCP includes [native OpenTelemetry instrumentation](https://gofastmcp.com/servers/telemetry). Zero configuration required—bring your own SDK:

```bash
# Install OTEL dependencies
pip install opentelemetry-distro opentelemetry-exporter-otlp
opentelemetry-bootstrap -a install

# Run with tracing enabled
opentelemetry-instrument \
  --service_name kubeflow-mcp \
  --exporter_otlp_endpoint http://localhost:4317 \
  kubeflow-mcp serve --clients trainer
```

**Automatic spans created:**

| Span Name | Description |
|-----------|-------------|
| `tools/call fine_tune` | Tool execution |
| `tools/call get_training_logs` | Monitoring operations |
| `resources/read config://...` | Resource access |

**MCP semantic convention attributes:**

| Attribute | Description |
|-----------|-------------|
| `mcp.method.name` | `tools/call`, `resources/read` |
| `mcp.session.id` | Session identifier |
| `enduser.id` | Client ID (when authenticated) |

Works with any OTLP-compatible backend (Jaeger, Grafana Tempo, Datadog, etc.).

---

## Phase 5: Additional Client Modules

### Optimizer Module (`--clients optimizer`)

```python
MODULE_INFO = {
    "name": "optimizer",
    "sdk_client": "OptimizerClient",
    "sdk_import": "kubeflow.optimizer",
    "description": "Hyperparameter optimization with Katib",
}
```

| Tool | SDK Method | Description |
|------|------------|-------------|
| `optimize()` | `OptimizerClient.optimize()` | Create hyperparameter optimization |
| `list_optimization_jobs()` | `OptimizerClient.list_jobs()` | List experiments |
| `get_optimization_job()` | `OptimizerClient.get_job()` | Experiment details |
| `get_optimization_logs()` | `OptimizerClient.get_job_logs()` | Trial logs |
| `get_best_results()` | `OptimizerClient.get_best_results()` | Best hyperparameters |
| `wait_for_optimization()` | `OptimizerClient.wait_for_job_status()` | Block until done |
| `delete_optimization_job()` | `OptimizerClient.delete_job()` | Delete experiment |
| `get_optimization_events()` | `OptimizerClient.get_job_events()` | K8s events |

**SDK Dependency:** `kubeflow.optimizer.OptimizerClient` (SDK v0.3.0)
**Tool Count:** 8 tools (~3K tokens)

### Hub Module (`--clients hub`)

```python
MODULE_INFO = {
    "name": "hub",
    "sdk_client": "ModelRegistryClient",
    "sdk_import": "kubeflow.hub",
    "description": "Model Registry for artifact versioning",
}
```

| Tool | SDK Method | Description |
|------|------------|-------------|
| `register_model()` | `ModelRegistryClient.register_model()` | Register model artifact |
| `list_models()` | `ModelRegistryClient.list_models()` | List registered models |
| `get_model()` | `ModelRegistryClient.get_model()` | Model details |
| `list_model_versions()` | `ModelRegistryClient.list_model_versions()` | Version history |
| `get_model_version()` | `ModelRegistryClient.get_model_version()` | Version details |
| `get_model_artifact()` | `ModelRegistryClient.get_model_artifact()` | Artifact metadata |

**SDK Dependency:** `kubeflow.hub.ModelRegistryClient` (SDK v0.3.0)
**Tool Count:** 6 tools (~2.5K tokens)

### Tool Count Progression

| Phase | Trainer Tools | Notes |
|-------|---------------|-------|
| Phase 1 | 16 | Core trainer tools |
| Phase 2 | 17 | +1 `check_prerequisites()` |
| Phase 4 | 19 | +2 checkpoint tools |

### Cumulative Tool Counts (Phase 5)

| Configuration | Tools |
|---------------|-------|
| `--clients trainer` | 19 |
| `--clients trainer,optimizer` | 27 |
| `--clients trainer,optimizer,hub` | 33 |

---

## Compatibility Matrix

| kubeflow-mcp | Kubeflow SDK | Kubeflow Trainer | Kubernetes | Python |
|--------------|--------------|------------------|------------|--------|
| 0.1.x | ≥0.3.0 | ≥2.0.0 | ≥1.28 | ≥3.10 |
| 0.2.x | ≥0.4.0 | ≥2.1.0 | ≥1.29 | ≥3.10 |

| MCP Client | Transport | Status |
|------------|-----------|--------|
| Claude Desktop | stdio | Target |
| Cursor IDE | stdio | Target |
| VS Code + Copilot | StreamableHTTP | Planned |
| LlamaStack | StreamableHTTP | Planned |
| Ollama | StreamableHTTP | Planned |
| Open WebUI | StreamableHTTP | Planned |

**Transport Selection:**
- **stdio**: Local CLI tools, lowest latency, single-client
- **StreamableHTTP**: Web/remote access, multi-client, scalable (replaces deprecated SSE)
