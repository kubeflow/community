# WG Deployment Charter

This charter adheres to the conventions, roles and organization management outlined in [wg-governance].

## Scope

WG Deployment is responsible for Kubeflow release and tooling to deploy apps from the catalog (e.g kfctl).

### In scope

#### Responsibilities

- Provide tooling to deploy Kubeflow applications from the catalog.
- Work with Working Group / Application Owners and Platform Owners to make the integration and release process easier.

#### Code, Binaries and Services

- kfctl (including operator)
- manifests

#### Cross-cutting and Externally Facing Processes

##### With Application Owners
- Co-ordinating with application OWNERs before a release to qualify application releases
- Ensure application manifests are up to date with the latest changes.

##### With Platform Owners
- Ensure platform-specific deployment artifacts (manifests, KFDefs, kpt functions) are up-to-date.

### Out of scope

- Maintaining or bug fixes to the individual applications catalogs or the applications.
- Maintain or fix bugs in the platform specific distributions (KFDefs, kpt functions).

## Roles and Organization Management

This WG adheres to the Roles and Organization Management outlined in [wg-governance]
and opts-in to updates and modifications to [wg-governance].


[wg-governance]: ../wgs/wg-governance.md
[wg-subprojects]: https://github.com/kubeflow/community/blob/master/wg-deployment/README.md#subprojects
[Kubeflow Charter README]: https://github.com/Kubeflow/community/blob/master/committee-steering/governance/README.md
