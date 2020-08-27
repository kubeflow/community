# WG Deployment Charter

This charter adheres to the conventions, roles and organization management outlined in [wg-governance].

## Scope

Manage manifests for deploying and operating Kubeflow.
Develop and maintain tools like kfctl (CLI + operator) for using the manifests to deploy Kubeflow.

### In scope

#### Code, Binaries and Services

- kfctl
- kfdef for each platform

#### Cross-cutting and Externally Facing Processes

- Cutting releases on both the manifests and kfctl repos
- Qualifying a Kubeflow release for each platform
- Co-ordinating with application OWNERs before a release to qualify application releases

### Out of scope

- Maintaining or bug fixes to the individual applications themselves.

## Roles and Organization Management

This WG adheres to the Roles and Organization Management outlined in [wg-governance]
and opts-in to updates and modifications to [wg-governance].


[wg-governance]: ../wgs/wg-governance.md
[wg-subprojects]: https://github.com/kubeflow/community/blob/master/wg-deployment/README.md#subprojects
[Kubeflow Charter README]: https://github.com/Kubeflow/community/blob/master/committee-steering/governance/README.md