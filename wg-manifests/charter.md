# WG Manifests Charter


This charter adheres to the conventions, roles and organization management
outlined in [wg-governance].

## Scope

We simply (automatically) synchronize the application and dependencies manifests to then elaborately combine (configure)them for full platform experience.
Providing a consistent and tested end-to-end multi-tenant experience is the most important task of the platform/manifests WG.
To achieve this we maintain an extensive testing suite that covers most basic scenarios users would expect from a Platform for ML orchestration.
We also provide the documentation regarding, but not limited to installation, extension, security and architecture to enable users to run their own ML Platform on Kubernetes.
Users may choose to derive from platform/manifests to create so called distributions, which are opinionated to satisfy individual requirements.
Users may also choose to install individual components without the benefits of the platform.

### In scope

#### Code, Binaries and Services

- Enable users / distributions to install, extend and maintain Kubeflow as a end-to-end multi-tenant platform for multiple users
- This includes dependencies, security efforts and exemplary integration with popular tools and frameworks.
- Users can also install individual components without the benefits of the platform, but then they could also just directly fetch them from the WG releases.
- Synchronize the manifests between working groups and make sure via integration tests that the components work end-to-end together as multi-tenant platform
- Release tested releases of the Kubeflow platform for downstream consumption
- We try to be compatible with the popular Kubernetes clusters (Kind, Rancher, AKS, EKS, GKE, ...)
- We provide hints and experimental examples how a user / distribution could integrate non-default external authentication (e.g. companies Identity Provider) and popular non-default services on his own
- We in general document the installation of Kubeflow as a platform and / or  individual components including common problems and architectural overviews.
- There is the evolving and not exhaustive list of dependencies for a proper multi-tenant platform installation: Istio, KNative, Dex, Oauth2-proxy, Cert-Manager, ...
- There is the evolving and not exhaustive list of applications:  KFP, Trainer, Dashboard, Workspaces / Noteboks, Kserve, Spark, ...

## Cross-cutting and Externally Facing Processes

### With Application Owners

- Aid the application owner in creating manifests (Helm, Kustomize) for his application
- Aid the application owner regarding security best practices
- Communicate with the application owner regarding releases and versioning

### With Users / Distribution Owners
- Distributions are opinionated derivatives of Kubeflow platform/manifests, for example replacing all databases with closed source managed databases from AWS, GKE, Azure, ...
- A distribution can be created by an arbitrary amount of users / companies in private or in public by deriving from Kubeflow platform/manifests, see the definition above
- Coordinate with "distribution owners" / users to take part in the testing of Kubeflow releases.

### Out of scope

- We do not support a specific deployment tool (e.g., ArgoCD, Flux)
- The default installation shall not contain deep integration with external cloud services or closed source solutions, instead we aim for Kubernetes-native solutions and light authentication and authorization integration with external IDPs

## Roles and Organization Management

This WG adheres to the Roles and Organization Management outlined in
[wg-governance] and opts-in to updates and modifications to [wg-governance].

The positions of the Chairs and TLs are granted to the organizations and companies participating in the workgroup governance. If an individual leaves the organization to which that position was designated - the organization will have the right to appoint others to these roles.

Kubeflow's [governance model](https://github.com/kubeflow/community/blob/master/wgs/wg-governance.md)
includes a plethora of different leadership roles.
This section aims to provide a clear description of what these roles mean for
this repository, as well as set expectations from people with these roles and requirements
for people to be promoted in a role.

A Working Group lead is considered someone that has either the role of
**Subproject Owner**, **Tech Lead** or **Chair**. These roles were defined by trying
to provide different responsibility levels for repository owners. For the Manifests WG
we would like to start by treating *approvers* in the root [OWNERS](https://github.com/kubeflow/manifests/blob/master/OWNERS),
as Subproject Owners, Tech Leads and Chairs. This is done to ensure we have a
simple enough model to start that people can understand and get used to. So for
the Manifests WG we only have Manifests WG Leads, which are the root approvers.

The following sections will aim to define the requirements for someone to become
a reviewer and an approver in the root OWNERS file (Manifests WG Lead).

### Platform/Manifests WG Lead Requirements

The requirements for someone to be a Lead come from the processes and work required
to be done in this repository. The main goal with having multiple Leads is to ensure
that in case there's an absence of one of the Leads the rest will be able to ensure
the established processes and the health of the repository will be preserved.

With the above the main pillars of work and responsibilities that we've seen for
this repository throughout the years are the following:
1. Being involved with the release team, since the [release process](https://github.com/kubeflow/community/tree/master/releases) is tightly intertwined with the manifests/platform repository
2. Testing methodologies (GitHub Actions)
3. Processes regarding the [experimental](https://github.com/kubeflow/manifests/blob/master/experimental) components
4. [Platform manifests](https://github.com/kubeflow/manifests/tree/master/common) maintained irectly by Manifests/Platform WG (Istio, Knative, Cert Manager etc.)
5. Community and health of the project

Root approvers, or Manifests/Platform WG Leads, are expected to have expertise and be able
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
have expertise in the different processes and artefacts maintained in this repository
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
