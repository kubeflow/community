# WG Manifests Charter

This charter adheres to the conventions, roles and organization management
outlined in [wg-governance].

## Scope

- Provide a catalog (centralized repository) of Kubeflow application manifests.
- Provide a catalog of third-party apps for common services.
- Provide documentation to help users install a set, or all of the included
  apps.

### In scope

#### Code, Binaries and Services

- Maintain a set of manifests that will allow users to install Kubeflow apps and
  common services easily on Kubernetes, either on the cloud or on-prem, without
  depending on external cloud services or closed source solutions. These
  manifests will be developed with certain principles in mind, which are
  outlined in the last bullet. Those include:
    1. A common set of manifests for the current five (5) official Kubeflow
       applications:
        - Training Operators
        - Kubeflow Pipelines (KFP)
        - Notebooks
        - KFServing
        - Katib
    1. Manifests for a set of specific common services:
       - Istio
       - KNative
       - Dex
       - Cert-Manager
    1. Manifests for common, currently unmaintained, apps:
        - Central Dashboard
        - Profile Controller
        - PodDefaults Controller
- Maintain documentation and instructions for installing a set or all of the
  apps. Documentation will not depend on any opinionated deployment tool. It
  will only depend on `kustomize` and `kubectl`. This way, users and platform
  owners can easily build on top and use their favorite opinionated deployment
  tool (e.g., Argo, kapp, kpt, kfctl, FluxCD, etc.) with Kubeflow.
- The maintained manifests will follow certain principles:
    - The flow of work / separation of responsibilities will be the following:
        1. Application owners publish manifests in their repos.
        1. WG copies and tracks upstream manifests in the manifests repo. They
           form a base `kustomization`.
        1. All kubeflow-specific changes (e.g., change the namespace) are done
           in `kustomize` overlays and they don't touch the upstream files.
        1. Periodically, the upstream manifests are updated by copying from a
           later commit.
    - Contrasted with the current state, in the aforementioned workflow:
        - App owners are not required to do anything other than maintain working
          installation manifests in their repo. This is something all app owners
          already do, as it's needed for testing and developing the app.
        - Manifests depend on the frequently updated manifests of the app repo,
          instead of the out-of-date, kfctl-specific manifests in the current
          `kubeflow/manifests` repo. [A recent proposal](https://www.google.com/url?q=http://bit.ly/kf_kustomize_v3&sa=D&ust=1603724692328000&usg=AOvVaw2qgtPzKUz5zqIjpn3Yoas7)
          tried to make all of our manifests kustomize-native. However, it
          reused the outdated kfctl-specific bases, instead of establishing a
          procedure where upstream changes can easily find their way in
          `kubeflow/manifests`. Thus, it suffered from poor maintainability.
    - Users (ML Engineers) and platform owners can extend and re-use
      kustomizations to integrate better with their platforms.

#### Cross-cutting and Externally Facing Processes

##### With Application Owners

- Communicate with application owners to agree upon the version they want to be
  included in the next Kubeflow release.

##### With Platform Owners

- Coordinate with platform owners, to make sure they are in-sync about the
  release schedule and have time to test and bring their platforms up-to-date.

### Out of scope

This WG is NOT going to:
- Maintain deployment-specific tools like `kfctl`.
- Maintain platform-specific manifests.
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