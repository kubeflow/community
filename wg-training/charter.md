# WG Training Charter

This charter adheres to the conventions, roles and organization management outlined in [wg-governance].

## Scope

WG Training focuses on the development, deployment, and operation of distributed AI workloads on
Kubernetes. It covers the entire model development lifecycle, including pre-training, post-training
(such as LLM fine-tuning), hyperparameter optimization, reinforcement learning, and other techniques
required to build, train, and run AI models at scale.

### In scope

#### Code, Binaries and Services

- APIs used for running distributed training jobs (e.g., TrainJob, TrainingRuntime APIs)
- APIs used for running hyperparameter tuning jobs (e.g. OptimizationJob APIs)
- Tools and documentation to aid in ecosystem tool interoperability around Trainer APIs

#### Cross-cutting and Externally Facing Processes

- Coordinating with WG Pipeline to make sure distributed training jobs can interact well with pipelines
- Coordinating with Kubeflow Distribution Committee to ensure that the Kubeflow Trainer can be deployed as part of distribution
- Coordinating with WG ML Experience to make sure Trainer is well integrated with Kubeflow SDK

### Out of scope

- Development of Kubeflow SDK (this falls under the purview of WG ML Experience).

## Roles and Organization Management

This WG follows adheres to the Roles and Organization Management outlined in [wg-governance]
and opts-in to updates and modifications to [wg-governance].

### Subproject Creation

New WG subprojects need to be reviewed and approved by the WG Chairs.

[wg-governance]: ../committee-steering/wg-governance.md
