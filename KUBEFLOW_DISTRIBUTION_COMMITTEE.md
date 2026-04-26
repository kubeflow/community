# Kubeflow Community Distribution committee charter

The Kubeflow Community Distribution is a committee dedicated to provide a tested and integrated platform experience for the Kubeflow community.
The governance of the Kubeflow Community Distribution committee will evolve as the community grows, ensuring that the platform remains relevant and impactful.

## Scope

- Automatically synchronize the application and dependencies manifests to then elaborately combine (configure) them for a full platform experience.
- Prioritize and provide a consistent, tested, and end-to-end multi-tenant experience. Enable the consumer and distributions to install, extend, and maintain Kubeflow as an end-to-end multi-tenant platform for multiple tenants on the same Kubernetes / Kubeflow installation.
- Maintain an extensive testing suite in order to cover scenarios that the community member and consumer expects from a platform designed for artificial intelligence and machine learning orchestration. This includes dependencies, security efforts, and exemplary integration with popular tools and frameworks and making sure via integration tests that the components work end-to-end together as a multi-tenant platform. 
- There is the evolving and not exhaustive list of included dependencies for a proper multi-tenant platform installation: Istio, KNative, Dex, Oauth2-proxy, Cert-Manager, ... 
- There is the evolving and not exhaustive list of included applications: Kubeflow Pipelines, Trainer, Dashboard, Workspaces / Notebooks, KServe, Spark, ...
- Provide documentation that covers (but is not limited to) installation, extension, security, and architecture decisions in order to enable the consumer to run a machine learning platform on Kubernetes (whatever form that may take).
- Ensure that the consumer can leverage and modify our integrated platform in order to create an opinionated distribution that satisfies his individual requirements. He may also choose to install individual components without the benefits of the platform. Everyone is free to create his own distribution for any number of customers or companies in private or in public by deriving from Kubeflow Community Distribution or building from scratch
- Release tested releases of the Kubeflow Community Distribution for downstream consumption.
- Try to be compatible with the popular Kubernetes clusters (Kind, Rancher, Azure Kubernetes Service, Elastic Kubernetes Service, Google Kubernetes Engine, ...).
- Provide hints and experimental examples how the consumer could integrate non-default external authentication (e.g., companies' Identity Provider) and popular non-default services on his own.
- Document the installation of Kubeflow as a platform and/or individual components including common problems and architectural overviews.

### Out of scope

- We do not enforce a specific deployment tool (e.g., ArgoCD, Flux), but we also do not want to block the usage of ArgoCD.
- The default installation shall not contain deep integration with external cloud services or closed source solutions; instead, we aim for Kubernetes-native solutions and light authentication and authorization integration with external identity providers.

### Collaboration with maintainers of kubeflow projects (e.g. KFP, Trainer, ...)

- Aid the kubeflow project maintainer in creating manifests (Helm, Kustomize) for his application.
- Aid the kubeflow project maintainer regarding security best practices.
- Communicate with the kubeflow project maintainer regarding releases and versioning.

## Roles and Organization Management

Kubeflow's [governance model](https://github.com/kubeflow/community/blob/master/wgs/wg-governance.md) includes a plethora of different leadership roles and is quite complex and designed for larger committes. This section aims to set requirements and expectations regarding tasks, roles and promotions.

**Subproject Owner**, **Technology Lead** or **Chair** roles were defined by trying
to provide different responsibility levels for repository owners. For the Kubeflow Community Distribution committee, the root approvers ([OWNERS](https://github.com/kubeflow/manifests/blob/master/OWNERS)) aka maintainers will be "**Subproject Owner**, **Technology Lead** and **Chair**" and the root reviewers ([OWNERS](https://github.com/kubeflow/manifests/blob/master/OWNERS)) will be "**Technology Lead**".

### Kubeflow Community Distribution Committee reviewer and approver requirements

The requirements for a promotion to root reviewer or approver comes from the processes and work required to be done in this repository. The main goal with having multiple Leads is to ensure
that in case there's an absence of one of the Leads the rest is able to ensure
the established processes and the health of the repository will be preserved.

With the above the main pillars of work and responsibilities that we have seen for
this repository throughout the years are the following:
1. Being involved with the release team, since the [release process](https://github.com/kubeflow/community/tree/master/releases) is tightly intertwined with the manifests/platform repository
2. Testing methodologies (GitHub Actions)
3. Processes regarding the [experimental](https://github.com/kubeflow/manifests/blob/master/experimental) components
4. [Platform manifests](https://github.com/kubeflow/manifests/tree/master/common) maintained directly by Manifests/Platform WG (Istio, Knative, Cert Manager etc.)
5. Community and health of the project

Root approvers, or Kubeflow Community Distribution maintainers, are expected to have expertise and be able to drive all the above areas. Root reviewers on the other hand are expected to
have knowledge in all the above and have as a goal to grow into the approvers
role by helping with reviews throughout the project.

#### Root Reviewer requirements

* Primary reviewer for at least 2 PRs in `/common`
* Primary reviewer for at least 1 PR in `/tests`
* Primary reviewer for at least 1 PR in `/experimental`

#### Root Approver requirements

The goal of the requirements is to quantify the main pillars that we documented
above. The high level reasoning is that approvers should have lead efforts and
have expertise in the different processes and artefacts maintained in this repository
as well as be invested in the community of the WG.

* Needs to be a root reviewer
* Has been a WG liaison for a KF release
* Has at least 3 substantial PRs merged for `/common`
    * I.e. updating the versions of Istio, Dex or Knative
    * I.e. update manifests to work with newer versions of kustomize
* Has at least 2 substantial PRs merged for `/tests`
* Has at least 1 substantial PR merged for `/proposals`
* Has been an active participant in issues and PRs for at least 3 months
* Has attended at least 50% of Platform/Manifests WG meetings
* Is endorsed by existing root approvers
