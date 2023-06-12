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

The positions of the Chairs and TLs are granted to the organizations and companies participating in the workgroup governance. If an individual leaves the organization to which that position was designated - the organization will have the right to appoint others to these roles.

Kubeflow's [governance model](https://github.com/kubeflow/community/blob/master/wgs/wg-governance.md)
includes a plethora of different leadership roles.
This section aims to provide a clear description of what these roles mean for
this repo, as well as set expectations from people with these roles and requirements
for people to be promoted in a role.

A Working Group lead is considered someone that has either the role of
**Subproject Owner**, **Tech Lead** or **Chair**. These roles were defined by trying
to provide different responsibility levels for repo owners. For the Manifests WG
we'd like to start by treating *approvers* in the root [OWNERS](https://github.com/kubeflow/manifests/blob/master/OWNERS),
as Subproject Owners, Tech Leads and Chairs. This is done to ensure we have a
simple enough model to start that people can understand and get used to. So for
the Manifests WG we only have Manifests WG Leads, which are the root approvers.

The following sections will aim to define the requirements for someone to become
a reviewer and an approver in the root OWNERS file (Manifests WG Lead).

### Manifests WG Lead Requirements

The requirements for someone to be a Lead come from the processes and work required
to be done in this repo. The main goal with having multiple Leads is to ensure
that in case there's an absence of one of the Leads the rest will be able to ensure
the established processes and the health of the repo will be preserved.

With the above the main pillars of work and responsibilities that we've seen for
this repo throughout the years are the following:
1. Being involved with the release team, since the [release process](https://github.com/kubeflow/community/tree/master/releases) is tightly intertwined with the manifests repo
2. Testing methodologies (GitHub Actions, E2E testing with AWS resources etc)
3. Processes regarding the [contrib/addon](https://github.com/kubeflow/manifests/blob/master/contrib) components
4. [Common manifests](https://github.com/kubeflow/manifests/tree/master/common)  maintained by Manifests WG (Istio, Knative, Cert Manager etc)
5. Community and health of the project

Root approvers, or Manifests WG Leads, are expected to have expertise and be able
to drive all the above areas. Root reviewers on the other hand are expected to
have knowledge in all the above and have as a goal to grow into the approvers
role by helping with reviews throughout the project.

#### Root Reviewer requirements

* Primary reviewer for at least 2 PRs in `/common`
* Primary reviewer for at least 1 PR in `/tests`
* Primary reviewer for at least 1 PR in `/contrib`

#### Root Approver requirements

The goal of the requirements is to quantify the main pillars that we documented
above. The high level reasoning is that approvers should have lead efforts and
have expertise in the different processes and artefacts maintained in this repo
as well as be invested in the community of the WG.

* Need to be a root reviewer
* Have been a WG liaison for a KF release
* Has at least 3 substantial PRs merged for `/common`
    * I.e. updating the versions of Istio, Dex or Knative
    * I.e. update manifests to work with newer versions of kustomize
* Has at least 2 substantial PRs merged for `/testing`
* Has at least 1 substantial PR merged for `/proposals`
* Has been an active participant in issues and PRs for at least 3 months
* Has attended at least 50% of Manifests WG meetings


[wg-governance]: ../wg-governance.md
[wg-subprojects]: https://github.com/Kubeflow/community/blob/master/wg-YOURWG/README.md#subprojects
[Kubeflow Charter README]: https://github.com/Kubeflow/community/blob/master/committee-steering/governance/README.md
