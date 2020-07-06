# WG Training Charter

This charter adheres to the conventions, roles and organization management outlined in [wg-governance].

## Scope

WG Training covers developing, deploying, and operating training jobs on Kubeflow.

### In scope

#### Code, Binaries and Services

- APIs used for running distributed training jobs (e.g., TFJob API)
- Tools and documentation to aid in ecosystem tool interoperability around distributed training jobs (e.g., TFJob CRD/Controller)

#### Cross-cutting and Externally Facing Processes

- Coordinating with WG Pipeline to make sure distributed training jobs can interact well with pipelines
- Coordinating with release teams to ensure that the distributed training features can be released properly

### Out of scope

- APIs used for running inference/serving tasks (this falls under the purview of WG Serving).

## Roles and Organization Management

This WG follows adheres to the Roles and Organization Management outlined in [wg-governance]
and opts-in to updates and modifications to [wg-governance].

### Subproject Creation

WG Technical Leads

[wg-governance]: ../wg-governance.md
[wg-subprojects]: https://github.com/Kubeflow/community/blob/master/wg-YOURWG/README.md#subprojects
[Kubeflow Charter README]: https://github.com/Kubeflow/community/blob/master/committee-steering/governance/README.md