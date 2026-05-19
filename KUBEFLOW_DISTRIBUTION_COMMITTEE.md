# Kubeflow Community Distribution

## Charter

The Kubeflow Distribution Committee (KDC) is a vendor-neutral body dedicated to supporting a healthy ecosystem of solutions by prioritizing the development, sustainability, interoperability, and distribution of individual Kubeflow sub-projects. While the primary focus of the KDC is to empower these sub-projects as modular, high-quality components, the Kubeflow Community Distribution serves as a primary example of this effort – providing a validated community supported implementation that demonstrates the collective power of these projects in a unified environment. By maintaining this distribution, the KDC aims to lower the barrier to entry for users and provide a streamlined path to adoption, while ensuring that sub-projects remain robust and valuable.

## In Scope
1. Promote the Kubeflow community’s vision, values, and mission in collaboration with the KSC, KOC, and WG Leads.
2. Validate, report on, and advocate for the consumability of Kubeflow sub-projects by establishing requirements for portability and ease of deployment across heterogeneous environments; this includes identifying integration gaps—such as unexposed configurations or packaging hurdles—and opening issues with sub-project maintainers to help prioritize improvements necessary for the projects to be effectively integrated into the community distribution and the broader vendor ecosystem.
3. Define and maintain the requirements for external projects and distributions of Kubeflow sub-project to be eligible to use the Kubeflow Conformant mark.
4. Validate and impose requirements on the Kubeflow Community Distribution, which provides a reference deployment of all Kubeflow sub-projects that is vendor neutral, multi-tenant, secure, and provide an integrated experience between components.

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

### Out of Scope (Limitations)

- Anti-Ecosystem-Competitive Actions: Engaging in or permitting actions that undermine the longevity of the community or violate vendor-neutral sovereignty. This includes, but is not limited to:
      - **Proprietary Lock-in:** Mandating that sub-projects or the distribution depend on proprietary APIs or closed-source components when general, open-source alternatives exist.
       - **Core Fragmentation:** Implementing core functionality that is not upstreamed, as the KDC’s goal is to maintain a Kubernetes-native, portable, and extensible foundation.
       - **Exclusionary Integration:** Forcing dependencies that intentionally disadvantage specific vendors or environments.
       - **Note on Compatibility:** This does not exclude the development of community-supported or vendor-contributed adapters (e.g., data exporters, storage drivers, or external dependencies) designed to support specific environments, provided they remain external to the project's core functionality and do not compromise the portability of the base ecosystem.

### Voting

1. 30% - Votes by Appointment
    - 4 seats appointed by KSC for 1 year term
    - Only vendor representative.
    - Is NOT allowed to vote on Kubeflow Community Distribution (KCD) topics

2. 70% - Votes by Right
    - 35% - KCD maintainers - 1-2 seats - appointed by KSC
    - 35% - Every sub-project gets 1 seat, all votes are weighted by 35%
    - Is allowed to vote on Kubeflow Community Distribution (KCD) topics
    - When voting decisions happen on KCD topics, maintainers and sub-project owners get 50% / 50% voting power.

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
