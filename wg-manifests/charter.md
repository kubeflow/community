# WG Manifests Charter

This charter adheres to the conventions, roles and organization management
outlined in [wg-governance].

## Scope

- Provide a catalog (centralized repository) of Kubeflow application manifests.
- Provide a catalog of third-party apps for common services.

### In scope

#### Code, Binaries and Services

- Maintain tooling to automate copying manifests from upstream app repos.
- Maintain a catalog that will allow users to install Kubeflow apps and
  common services easily on Kubernetes, either on the cloud or on-prem, without
  depending on external cloud services or closed source solutions. Those
  manifests are deployed using `kubectl` and `kustomize` and include:
    1. A common set of manifests for the current official Kubeflow applications:
        - Training Operators
        - Kubeflow Pipelines (KFP)
        - Notebooks
        - KFServing
        - Katib
        - Central Dashboard
        - Profile Controller
        - PodDefaults Controller
    1. Manifests for a set of specific common services:
        - Istio
        - KNative
        - Dex
        - Cert-Manager

#### Cross-cutting and Externally Facing Processes

##### With Application Owners

- Aid applications owners in creating kustomize manifests for their application,
  inside the app repo, if those don't exist already.
- Communicate with application owners to agree upon the version they want to be
  included in the next Kubeflow release.

##### With Distribution Owners

- Coordinate with distribution owners, to make sure they are in-sync about the
  release schedule and have time to test and bring their distributions
  up-to-date.

### Out of scope

This WG is NOT going to:
- Maintain deployment-specific tools like `kfctl`.
- Maintain distribution-specific manifests.
- Decide which applications to include in Kubeflow.
- Decide which variant of an application to include (e.g., KFP Standalone vs
  KFP with Istio).
- Create and maintain one or more Kubeflow distributions.
- Support configurations with environment-specific requirements, like special
  hardware, different versions of third-party apps (e.g., Istio, KNative, etc.)
  or custom OIDC providers.
- Support and promote a specific deployment tool (e.g., `kfctl`). Opinionated
  deployment tools can extend the base kustomizations to create manifests that
  support their methods.
    - For example, people invested in `kfctl` can create overlays that enable
      the use of `kfctl`'s parameter substitution, which expects a specific
      folder structure (`params.env`).

## Roles and Organization Management

This WG adheres to the Roles and Organization Management outlined in
[wg-governance] and opts-in to updates and modifications to [wg-governance].

[wg-governance]: ../wg-governance.md
[wg-subprojects]: https://github.com/Kubeflow/community/blob/master/wg-YOURWG/README.md#subprojects
[Kubeflow Charter README]: https://github.com/Kubeflow/community/blob/master/committee-steering/governance/README.md