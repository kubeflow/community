# Kubeflow Distribution Committee

The Kubeflow Distribution Committee (KDC) is a vendor-neutral body dedicated to supporting a healthy ecosystem of solutions by prioritizing the development, sustainability, interoperability, and distribution of individual Kubeflow sub-projects. While the primary focus of the KDC is to empower these sub-projects as modular, high-quality components, the Kubeflow Community Distribution serves as a primary example of this effort – providing a validated community supported implementation that demonstrates the collective power of these projects in a unified platform.

## Charter

### Goals

The committee will approve policies and decisions to bound the Kubeflow subprojects that will pursue the following goals:

1. Promote the Kubeflow community’s vision, values, and mission in collaboration with the KSC, KOC, and WG Chairs.
2. Validate, report on, and advocate for the consumability of Kubeflow sub-projects by establishing requirements for portability and ease of deployment across heterogeneous environments; this includes identifying integration gaps—such as unexposed configurations or packaging hurdles—and opening issues with sub-project maintainers to help prioritize improvements necessary for the projects to be effectively integrated into the community distribution and the broader vendor ecosystem.
3. Define and maintain the requirements for external projects and distributions of Kubeflow sub-project to be eligible to use the Kubeflow Conformant mark.
4. Collaborate with Kubeflow Community Distribution maintainers

### Restrictions

- Anti-Ecosystem-Competitive Actions: Engaging in or permitting actions that undermine the longevity of the community or violate vendor-neutral sovereignty. This includes, but is not limited to:
- **Proprietary Lock-in:** Mandating that sub-projects or the distribution depend on proprietary APIs or closed-source components when general, open-source alternatives exist.
- **Core Fragmentation:** Implementing core functionality that is not upstreamed, as the KDC’s goal is to maintain a Kubernetes-native, portable, and extensible foundation.
- **Exclusionary Integration:** Forcing dependencies that intentionally disadvantage specific vendors or environments.
- **Note on Compatibility:** This does not exclude the development of community-supported or vendor-contributed adapters (e.g., data exporters, storage drivers, or external dependencies) designed to support specific environments, provided they remain external to the project's core functionality and do not compromise the portability of the base ecosystem.

## Committee Structure

### Committee Roles

Currently, all representatives are appointed by a normal decision process of the KSC.

1. 40% - Votes by Appointment
   - 3-4 seats appointed by KSC for 1 year term
   - Only vendor representative.
   - Is NOT allowed to vote on Kubeflow Community Distribution (KCD) topics

2. 60% - Votes by Right
   - 30% - KCD maintainers - 1-2 seats, all votes are weighted in total by 30%
   - 30% - Every sub-project gets 1 seat, all votes are weighted in total by 30%
   - Is allowed to vote on Kubeflow Community Distribution (KCD) topics
   - When voting decisions happen on KCD topics, maintainers and sub-project owners get 50% / 50% voting power

### Decision Process

#### Normal Decision Process

Decisions requiring a vote include:

- Any decisions on requirements for Kubeflow conformance program
- Any decisions on requirements for Kubeflow subprojects portability and ease of deployment
- Any other decisions that at least half of the chairs (rounded down) present decide requires a vote

All representatives are allowed to vote on these topics.

Decisions are made with pull requests to the community repository, must be documented in the [`decision-log.md`](decision-log.md), and vote publicly on GitHub. Votes may only pass when at least 50% of the binding vote weight have been cast.

The decisions is adopted if more then half of the votes (rounded up) support it, taking into account the weighting of those votes.

#### KCD Decision Process

Some issues related to KCD requires a special decision process. Issues include:

- Any decisions on requirements for KCD
- Propose projects for KSC to be included in KCD. List of projects that are included in KCD
  must be defined in [`PROJECTS.md`](PROJECTS.md)

Only KCD and subprojects representatives are allowed to vote on these topics.

Decisions are made with pull requests to the community repository, must be documented in the [`decision-log-kcd.md`](decision-log-kcd.md), and vote publicly on GitHub. Votes may only pass when at least 50% of the binding vote weight have been cast.

The decisions is adopted if more then half of the votes (rounded up) support it, taking into account the weighting of those votes.

### Limitations on Company Representation

No more than one maintainer or vendor seat may be held by employees of the same organization (or conglomerate, in the case of companies owning each other). The organization seat may be transferred within members of the same organization during the 1 year term, if KSC approves it.

If employers change because of job changes, acquisitions, or other events, in a way that would be in violation of the proceeding limits, sufficient members of the committee must resign their positions until the requirements are satisfied. If it is impossible to find sufficient members to resign, all employees of that organization will be removed and the vacancies will be filled using the normal process.

In the event of a question of company membership (for example evaluating independence of corporate subsidiaries) a majority of all non-involved KSC members will decide.

## Kubeflow Community Distribution maintainers
Kubeflow Community Distribution (KCD) is community-maintained reference deployment of all Kubeflow sub-projects that is vendor neutral, multi-tenant, secure, and provides an integrated experience between components.
### In Scope (minimal expectations)

- The Kubeflow Community Distribution must be Kubeflow Conformant.
- Synchronize the application and dependencies manifests to then elaborately combine (configure) them for a consistent, secure and end-to-end multi-tenant enterprise platform experience.
  Enable the consumer and distributions to install, extend, modify and maintain Kubeflow Community Distribution installations by providing documentation, automation and configurability.
- Maintain an extensive testing suite in order to cover scenarios that the community member and consumer expects from an AI/ML platform. This includes dependencies, security efforts, and exemplary integration with popular tools and frameworks and making sure via integration tests that the components work end-to-end together as a secure and multi-tenant platform.
- Maintain the evolving and not exhaustive list of included dependencies for a proper multi-tenant platform installation: Istio, KNative, Dex, Oauth2-proxy, Cert-Manager, ... as well as Kubeflow sub-projects, Kubeflow Ecosystem projects and disabled by default experimental integrations.
- Release tested releases of the Kubeflow Community Distribution for downstream consumption.
- Provide guidance and examples how the consumer could integrate non-default external authentication (e.g., companies' Identity Provider) and popular non-default services on his own.
- Make Kubeflow Community Distribution compatible with the popular Kubernetes clusters (Kind, Rancher, AKS, GKE, EKS, OpenShift, MicroK8s)
- Aid the Kubeflow subproject maintainers in creating manifests (Helm, Kustomize), security best practices, maintain releases and versioning for their application.

### Kubeflow Community Distribution maintainer requirements

The requirements for a promotion to root reviewer or approver comes from the processes and work required to be done in manifests/Distribution repository.

With the above the main pillars of work and responsibilities that we have seen for this repository throughout the years are the following:

1. Being involved with the release team, since the [release process](https://github.com/kubeflow/community/tree/master/releases) is tightly intertwined with the manifests/distribution repository
2. Testing methodologies (GitHub Actions) and Kubernetes security
3. Processes regarding the [applications](https://github.com/kubeflow/manifests/blob/master/applications).
4. [Platform manifests](https://github.com/kubeflow/manifests/tree/master/common) maintained directly by Manifests/Platform WG (Istio, Knative, Cert Manager etc.)
5. Community and health of the project

Root approvers, or Kubeflow Community Distribution maintainers, are expected to have expertise and be able to drive all the above areas. Root reviewers on the other hand are expected to have knowledge in all the above and have as a goal to grow into the approvers role by helping with reviews throughout the project.

#### Root Reviewer requirements

https://www.kubeflow.org/docs/about/membership/#reviewer

#### Root Approver requirements

The high level reasoning is that approvers should have lead efforts and have expertise in the different processes and artefacts maintained in the manifests/distribution repository as well as be invested in the community of the WG/Committee.

https://www.kubeflow.org/docs/about/membership/#approver requirements should be consistently proven for at least the last 12 months.

## Changes to the Charter

Changes to the KDC charter can be proposed by any community member via a GitHub PR. Amendments will be subject to approval by a standard decision of the KSC. Proposals will be available for at least one week for community comments before a vote occurs.
