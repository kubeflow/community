# KEP-819: Kubeflow SDK for ML Experience

## Summary

Original Google document: https://docs.google.com/document/d/1rX7ELAHRb_lvh0Y7BK1HBYAbA0zi9enB0F_358ZC58w/edit

This KEP outlines a proposal to design Kubeflow SDK that streamlines user experience for
data scientists and ML engineers to interact with various Kubeflow projects
(Trainer, Katib, Spark Operator, Pipelines, Model Registry, KServe).

## Motivation

Kubeflow users come from diverse backgrounds, including cluster administrators, data scientists,
and ML engineers (referred to as `ML User` in this proposal). While administrators are familiar
with Kubernetes, ML Users typically are not. They prefer working in a familiar Python environment
with popular data and ML frameworks like PyTorch, TensorFlow, and JAX for ML and Ray, Spark,
Pandas, and Dask for data, while leveraging advanced hardware and cloud infrastructure
to scale their experiments.

Typically, ML Users want to:

- Open JupyterLab.
- Install required AI/ML libraries with `pip`.
- Prototype ML code using PyTorch/TensorFlow APIs.
- Launch jobs to create features from raw data and prepare training datasets.
- Launch jobs to train, fine-tune, and optimize models across many GPUs.
- Collect and analyze results within the same JupyterLab environment.

One of the typical ML experience workflows can be seen at
[this KubeCon + CloudNativeCon talk](https://youtu.be/Lgy4ir1AhYw?t=454).

Currently, Kubeflow's ecosystem lacks simple interfaces for interacting with its components. This
complexity hinders adoption among ML Users, as it requires Kubernetes expertise to use effectively.

This document proposes the Kubeflow Python SDK, designed to streamline the experience of
ML users when interacting with Kubeflow components. In the future, we may extend this SDK to
support additional languages (e.g., Swift, Rust, Java) based on user demand.

### Goals

- Collaborate with ML Experience/IDE Working Group to include this SDK into their charter.

- Introduce initial version of Kubeflow Python SDK that supports Kubeflow Trainer and Kubeflow
  Katib APIs.

  - **Note** that Kubeflow Katib will be probably renamed to Kubeflow Optimizer in the future.
    Thus, in this proposal we will keep the Kubeflow Optimizer name moving forward.

- Reduce duplication across `kubeflow-training` and `kubeflow-katib` SDKs by reusing code assets.

- Design the SDK version control and release schedule.

- Design synchronization scripts between Kubeflow control plane and SDK models.

### No Goals

- Consolidate Kubeflow Pipelines APIs into centralized Kubeflow SDK.

  - As we discussed in the Google document, we want to postpone the `kfp` integration after
    we release the initial version of Kubeflow SDK. The Kubeflow community will work towards
    long-term goal to provide consistent experience for ML Users to interact with Kubeflow APIs.

- Integrate Kubeflow Spark Operator, KServe, Model Registry into Kubeflow SDK.

  - Similar to KFP, we will design the integration between those components in the future releases
    of Kubeflow SDK.

- Use the Kubeflow SDK to submit Kubernetes CRDs that are not part of Kubeflow projects,
  except when a Kubeflow component relies on a third-party tool (e.g., Kubeflow Trainer
  is creating a PodGroup for gang scheduling).

- Use Kubeflow SDK to install the entire Kubeflow control plane. This should be managed by
  cluster administrators via Helm Charts, Kustomize manifests, or Kubeflow distributions.

## Proposal

Design and implement the unified Python SDK to interact with Kubeflow CRDs, so the ML Experience
looks as follows:

```python
from kubeflow.spark import SparkClient
from kubeflow.trainer import TrainerClient
from kubeflow.optimzer import OptimizerClient
from kubeflow.kserve import KServeClient

SparkClient().process_data()
TrainerClient().train()
OptimizerClient().optimize()
KServeClient().serve()

```

![kubeflow-sdk](kubeflow-sdk.drawio.svg)

### User Stories

#### Story 1

As an ML User, I want to fine-tune an LLM with my own dataset using a model from HuggingFace.
I want to open the Jupyter Notebook, select the available Kubeflow LLM TrainingRuntime,
configure PEFT config, my dataset, and trigger a fine-tuning job.

The ML Experience may look as follows:

```python
from kubeflow.trainer import TrainerClient, TorchTuneConfig, LoraConfig

# Get available LLM runtimes.
TrainerClient().list_runtimes(phase="post-training")

# Fine-tune LLM.
job_id = TrainerClient().train(
    runtime_ref="llama-3.2-1b",
    fine_tuning_config=TorchTuneConfig(
        lr=0.01,
        peft_config=LoraConfig(
            lora_rank=4,
            lora_alpha=128,
        ),
    ),
)

# Get the results.
TrainerClient().get_job_logs(job_id)
```

#### Story 2

As an ML User, I want to develop my PyTorch model and train it across available GPUs. I know that
I have 100 training nodes with 5 GPU each (e.g. 500 GPUs in total) to train my model.

The ML Experience may look as follows:

```python
from kubeflow.trainer import TrainerClient, CustomTrainer

def pytorch_train_func(test_run=False):
    import torch
    import torch.distributed as dist
    ...

# Verify that training is functional.
pytorch_train_func(test_run=True)

# Train PyTorch model with 500 GPUs.
job_id = TrainerClient().train(
    trainer=CustomTrainer(
        func=pytorch_train_func,
        num_nodes=100,
        resources_per_node={"GPU": 5},
    ),
)

# Get the results.
TrainerClient().get_job_logs(job_id)
```

#### Story 3

As an ML User, I want to optimize hyperparameters for the LLM that I want to fine-tune.
For example, I know that I want to optimize learning rate and LoRA rank.

```python
from kubeflow.optimizer import OptimizerClient, OptimizerConfig
from kubeflow.optimizer import Search
from kubeflow.trainer import TorchTuneConfig, LoraConfig

# Optimizer HPs during fine-tuning.
job_id = OptimizerClient().optimize(
    runtime_ref="llama-3.2-1b",
    fine_tuning_config=TorchTuneConfig(
        lr=Search(min="0.01", max="0.1", distribution="logNormal"),
        peft_config=LoraConfig(
            lora_rank=Search(min="4", max="8", distribution="uniform"),
        ),
    ),
    optimizer_config=OptimizerConfig(
        objective="loss",
        mode="min",
        num_trials=5,
    ),
)

# Get the HPs from the best Trial.
OptimizerClient().get_job(job_id).best_trial
```

### Risks and Mitigations

If Kubeflow control plane components introduce breaking changes to the CRDs, we won’t create
a new major version for kubeflow SDK. As a result, manually upgrading the SDK may introduce breaking
changes for clients.

We can mitigate this risk by providing a compatibility table between SDK and control plane versions.
We will implement E2E tests to make sure that the SDK is compatible with the desired version of
the control plane.

Additionally, we will gracefully deprecate client APIs and inform users if API will be deleted or
modified in the future releases of Kubeflow SDK.

## Design Details

The Kubeflow SDK will be developed in the `kubeflow/sdk` repository. We will use the OpenAPI to
generate clients from the Kubernetes CRDs.

The following directory structure outlines the organization for the Kubeflow Trainer SDK.

```
python/
│── kubeflow/
│   │── trainer/
│   │   │── api/                               # Client to call Kubeflow Trainer APIs
│   │   │   │── trainer_client.py
│   │   │── types/                             # User's types for Kubeflow Trainer
│   │   │   │── types.py
│   │   │── constants/                         # User's constants for Kubeflow Trainer
│   │   │   │── constants.py
│   │   │── models/                            # OpenAPI generated models
│   │   │   │── trainer_v1alpha1_train_job.py
│   │── optimizer/
│   │── . . .
│── pyproject.toml
│── requirements.txt
```

When users want to call the Kubeflow Trainer API, they firstly should create a `TrainerClient()`
which verifies that:

- Users have required access to the Kubernetes cluster.
- Kubeflow Trainer control plane is installed.

After that, users can interact with `TrainerClient()` APIs:
`train(), list_runtimes(), get_job_logs(), etc`

Users should be able to use the Kubeflow SDK even if certain control plane components are not
installed. For example, if the Kubeflow Trainer control plane is available but the Kubeflow
Optimizer is not, users should still be able to train LLMs but users can't optimize hyperparameters.

### Release Lifecycle

For every minor version of Kubeflow component control plane, we bump the minor version for
Kubeflow SDK. Unless we update the two control plane components together.
In that case, we can have a single minor version for Kubeflow SDK.

The typical release lifecycle looks as follows:

```
Release Kubeflow Trainer
  -> Bump Kubeflow Trainer in Kubeflow SDK
    -> Release Kubeflow SDK
      -> Update examples if required
```

We can release Kubeflow SDK more frequently than control plane components if we introduce new
features to the client APIs. For that, we can just individually release Kubeflow SDK:

```
Release Kubeflow SDK
  -> Update examples if required
```

Tentatively, we plan to release **two minor versions** of the SDK each quarter.

### Version Control

It is the responsibility of cluster administrators to install the correct version of Kubernetes and
Kubeflow components. Kubeflow community will maintain the compatibility table between
Kubeflow SDK and control plane of Kubeflow components. The following table shows
the tentative versions for Kubeflow Trainer and Kubeflow Optimizer.

| SDK Version | Kubernetes Version | Kubeflow Trainer | Kubeflow Optimizer |
| ----------- | ------------------ | ---------------- | ------------------ |
| 0.1.0       | 1.29..1.32         | 2.0.0            | None               |
| 0.2.0       | 1.29..1.32         | 2.0.0            | None               |
| 0.3.0       | 1.30..1.33         | 2.1.0            | 1.0                |

The `constants.py` defines the version of CRDs that user should interact with:

```python
GROUP = os.getenv("DEFAULT_TRAINER_API_GROUP", "trainer.kubeflow.org")
TRAINJOB_VERSION = os.getenv("DEFAULT_TRAINER_TRAINJOB_VERSION", "v1alpha1")
RUNTIME_VERSION = os.getenv("DEFAULT_TRAINER_RUNTIME_VERSION", "v1alpha1")
RUNTIME_KIND = os.getenv("DEFAULT_TRAINER_RUNTIME_KIND", "ClusterTrainingRuntime")
```

Cluster administrators can override the default CRD values, if their users should work with
different versions of CRDs. However, it is the responsibility of cluster administrators to
make sure that client APIs are compatible with these CRD versions.

We need to make sure that Kubeflow SDK uses the correct version of Kubernetes Python client.
The compatibility table for Kubernetes Python client is described here:
[https://github.com/kubernetes-client/python?tab=readme-ov-file#compatibility](https://github.com/kubernetes-client/python?tab=readme-ov-file#compatibility)

### Kubeflow Pipelines SDK

Kubeflow Pipelines currently has its own version of client SDK: `kfp`. The long-term goal is to
consolidate Kubeflow Pipelines client APIs into Kubeflow SDK.

Currently, users can leverage `kfp` and `kubeflow` SDKs together to seamlessly build end-to-end
ML pipelines as follows:

```python
from kfp import dsl

@dsl.component
def extract_features() -> dsl.Dataset:
    from kubeflow.spark import SparkClient
    SparkClient.process_data()

@dsl.component
def fine_tune_llm(dataset dsl.Input[dsl.Dataset]) -> dsl.Model:
    from kubeflow.trainer import TrainerClient
    TrainerClient.train()


@dsl.component
def serve(model dsl.Input[dsl.Model]):
    from kubeflow.kserve import KServeClient
    KServeClient.serve()

@dsl.pipeline
def e2e_pipeline():
    extract_features_task = extract_features()
    llm_ft_task = fine_tune_llm(extract_features_task.output)
    serve(llm_ft_task.output)
```

### Build System

Using build systems is critical for enhancing the development and maintenance of the Kubeflow SDK.
It provides dependency management, reproducibility, automation, modularity, etc.

We are currently evaluating different build systems for the Kubeflow SDK as part of this tracking issue: [kubeflow/trainer#2462](https://github.com/kubeflow/trainer/issues/2462)

One option we are considering is [`uv`](https://github.com/astral-sh/uv), due to its speed and extensive functionality.

### Packaging

Kubeflow SDK will contain multiple components Trainer, Optimizer, Pipelines, etc. Installing all
components as a single package will make the SDK wheel large. Kubeflow SDK might utilize Python
extras which will enable ML Users to choose what exactly they want to install and what to exclude.

### Ownership of Kubeflow SDK

The Kubeflow SDK will be developed collaboratively by all Kubeflow Working Groups, as it provides
client APIs for nearly every Kubeflow project. To manage ownership effectively, we can
leverage `OWNERS` files within sub-folders to designate maintainers for each project.

For example:

```
python/
│── kubeflow/
│   │── trainer/
│   │   │── OWNERS       <------ Kubeflow Trainer contributors
│   │── pipelines/
│   │   │── OWNERS       <------ Kubeflow Pipelines contributors
. . .
```

However, from the Working Group point of view the Kubeflow SDK will be in scope of newly formed
ML Experience WG.

## Implementation History

- Draft KEP: February 17th 2025

## Test Plan

### Unit Test

We will implement the unit tests for every client using the `pytest` framework. The test files
must be located within the actual files. For example:

```
python/
│── kubeflow/
│   │── trainer/
│   │   │── api/
│   │   │   │── trainer_client.py
│   │   │   │── trainer_client_test.py
. . .
```

That should help us maintain consistency in tests across the control plane and SDK while keeping them easy to locate.

### E2E Test

For E2E testing, we will create two set of Jupyter Notebook examples:

- **Single-Project Notebooks** – Demonstrating how to use the Kubeflow SDK with individual projects
  (e.g., Kubeflow Trainer). These will be located within their respective project GitHub repositories
  (e.g., `kubeflow/trainer`).
- **Multi-Project Notebooks** – Showcasing the integration of the Kubeflow SDK across multiple
  projects (e.g., Kubeflow Trainer + Kubeflow Optimizer). These will be located in
  the `kubeflow/sdk` GitHub repository.

We will use **[Papermill](https://github.com/nteract/papermill)** to execute these notebooks as
E2E tests, ensuring the functionality of both the control plane and the Kubeflow SDK.

## Alternatives

### Develop SDK for every Kubeflow project

Maintain an individual SDK for every Kubeflow project (e.g. `kubeflow_trainer`, `kubeflow_optimizer`).
The downside of this approach is that it will be hard to manage common code across all of these SDKs.

Additionally, users need to deal with version control across all of the control planes and
client versions, rather than Kubeflow community provide compatibility table.

### Integrate Kubeflow SDK capabilities into KFP

We can integrate Kubeflow SDK clients directly into KFP. However, a key drawback of this approach
is that many users rely on individual Kubeflow components (e.g., Spark Operator, Trainer)
without using KFP. To better support these users, we aim to provide a modular and composable
SDK that does not require installing the entire Kubeflow control plane.

In the future, we will consolidate `kfp` and `kubeflow` SDKs together.
