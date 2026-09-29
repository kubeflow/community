# Infrastructure: Kubeflow Oracle Cloud Infrastructure (OCI) Tenancy

Infrastructure available in the `cncfkubeflow` tenancy for Kubeflow
development and testing. Region: **us-ashburn-1** (3 availability domains,
only subscribed region). Requests follow the [KEP-939 process](README.md).
Full shape specifications:
[OCI Compute Shapes](https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm).

Quotas below are verified from the tenancy service limits (last checked:
2026-08-26).

## Available Infrastructure

| Resource | OCI Shape / Service | Specs | Tenancy Quota |
| --- | --- | --- | --- |
| GPU VM (single GPU) | `VM.GPU.A10.1` | 1× NVIDIA A10 (24 GB VRAM), 15 OCPU, 240 GB RAM | 80 A10 GPUs total (32/32/16 per AD, shared across all A10 shapes) |
| GPU VM (dual GPU) | `VM.GPU.A10.2` | 2× NVIDIA A10 (48 GB VRAM), 30 OCPU, 480 GB RAM | shares the A10 quota above |
| GPU cluster node | OKE node pool with `VM.GPU.A10.1` / `VM.GPU.A10.2` | Same as above, as Kubernetes worker nodes | shares the A10 quota above |
| Other GPU shapes | `VM.GPU3.1/2/4` (V100), `BM.GPU4.8` (8× A100, AD-3 only), `VM.GPU2.1` (P100, AD-1 only) | See shape docs | 96 V100, 32 A100, 100 P100 GPUs |
| Shared Kubernetes cluster | OKE with `VM.Standard.E5.Flex` workers | 8 OCPU / 64 GB RAM per worker, 3–4 workers | 13.8k E5 cores per AD |
| ARM64 VM / node pool | `VM.Standard.A1.Flex` (Ampere) | Flexible; 8 OCPU / 64 GB RAM typical | 41k+ A1 cores (effectively unconstrained) |
| x86 utility VM | `VM.Standard.E5.Flex` (also E6, E2, E3, Standard3) | Flexible; 2–4 OCPU typical | 13.8k E5 cores per AD |
| Object storage | OCI Object Storage | ~1 TB | — |

Note: the tenancy currently has **no quota** for newer GPU classes (H100,
H200, L40S, A100-v2, B200, MI300X) or for `VM.Standard.E4.Flex` — request
E3/E5/E6 shapes for x86 workloads.

## Currently Deployed

Live resources in the tenancy as of the last-checked date above. 5 of the 80
A10 GPUs are currently in use.

| Resource | Compartment | Kubernetes | Nodes | Purpose |
| --- | --- | --- | --- | --- |
| `GSOC-2026` (OKE) | `gsoc-2026` | v1.35.2 | 3× `VM.Standard.E3.Flex` + 2× `VM.GPU.A10.1` | GSoC 2026 projects |
| `ampere-demo-cluster` (OKE) | `gsoc-2026` | v1.34.2 | 3× `VM.Standard.A1.Flex` (ARM64) | ARM64 validation / demo |
| `docs-agent-cluster` (OKE) | `test-deploy-kubeflow` | v1.34.2 | 2× `VM.Standard.E5.Flex` + 2× `VM.GPU.A10.1` | Kubeflow documentation AI agent |
