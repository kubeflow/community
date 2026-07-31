# Kubeflow Distribution Committee

The Kubeflow Distribution Committee (KDC) is a vendor-neutral body dedicated to supporting a healthy ecosystem of solutions by prioritizing the development, sustainability, interoperability, and distribution of individual Kubeflow Subprojects. 

While the primary focus of the KDC is to empower the Kubeflow Subprojects as modular, high-quality components, the Kubeflow Community Distribution (KCD) serves as a primary example of this effort – providing a validated community-supported implementation that demonstrates the collective power of these projects in a unified platform.

## Charter

### Goals

The committee will only approve policies and decisions that support the following goals:

1. Promote the Kubeflow community’s vision, values, and mission in collaboration with the KSC, KOC, and WG Chairs.
2. Validate, report on, and advocate for the consumability of Kubeflow Subprojects by defining requirements for portability and ease of deployment across heterogeneous environments. This includes identifying integration-gaps such as unexposed configurations or packaging hurdles—and opening issues with maintainers to help prioritize improvements necessary for the Kubeflow Subprojects to be effectively integrated into the KCD and the broader vendor ecosystem.
3. Define and maintain the requirements for external projects and distributions of Kubeflow Subprojects to be eligible to use the Kubeflow Conformant mark.
4. Define and maintain the requirements for the Kubeflow Community Distribution. Subject to the _KCD Decision Process_.

### Restrictions

The committee will not approve policies or decisions that violate the following restrictions:

- **Anti-Ecosystem Actions:** Actions that undermine the longevity of the Kubeflow Community or violate vendor-neutral principles, such as intentionally fragmenting the ecosystem or creating barriers to entry for new vendors or contributors.
- **Proprietary Lock-in:** Mandating that Kubeflow Subprojects or the KCD depend on proprietary APIs or closed-source components when general, open-source alternatives exist.
- **Exclusionary Integration:** Forcing dependencies that intentionally disadvantage specific vendors or environments.

These restrictions do not exclude the development of community-supported or vendor-contributed adapters (e.g., data exporters, storage drivers, or external dependencies) designed to support specific environments, provided they remain external to the project's core functionality and do not compromise the portability of the base ecosystem.

## Committee Structure

The KDC is composed of multiple types of representatives.
Each type of representative has specific voting rights and responsibilities.

### Vendor Representatives

- Number of Seats: 3-4
- Eligibility:
   - Employees of an organization with a meaningful commercial interest in the goals of the KDC.
- Appointment:
   - Nominated by the vendor organization.
   - Appointed for 1-year term by the normal decision process of the KSC.
   - May be transferred to another member of the same organization during the 1-year term, if KSC approves it.
- Voting:
   - Together, the vendor representatives have __40%__ of the binding vote weight for [Normal Decision Process](#normal-decision-process) votes, and __0%__ of the binding vote weight for [KCD Decision Process](#kcd-decision-process) votes.
   - Each representative votes independently, with an equal share of their group's total vote weight (e.g., if there are 4 representatives, each has 10% of the total binding vote weight for _Normal Decision Process_ votes).

### Kubeflow Community Distribution Representatives

- Number of Seats: 1-2
- Eligibility:
   - Individuals who are [members](../community-membership.md) of the Kubeflow GitHub organization.
- Appointment:
   - Nominated by the _root approvers_ of the Kubeflow Community Distribution repository.
   - Appointed for 1-year term by the normal decision process of the KSC.
   - May be transferred to another individual during the 1-year term, if KSC approves it.
- Voting:
   - Together, the community distribution representatives have __30%__ of the binding vote weight for [Normal Decision Process](#normal-decision-process) votes, and __50%__ of the binding vote weight for [KCD Decision Process](#kcd-decision-process) votes.
   - Each representative votes independently, with an equal share of their group's total vote weight (e.g., if there are 2 representatives, each has 15% of the total binding vote weight for _Normal Decision Process_ votes).

### Kubeflow Subproject Representatives

- Number of Seats: _1 per graduated Kubeflow Subproject_
- Eligibility:
   - Individuals who are [members](../community-membership.md) of the Kubeflow GitHub organization.
- Appointment:
   - Nominated by the __chairs__ of the Kubeflow Working Group that owns the __graduated__ Kubeflow Subproject being represented.
   - Appointed for 1-year term by the normal decision process of the KSC.
   - May be transferred to another individual during the 1-year term, if KSC approves it.
- Voting:
   - Together, the subproject representatives have __30%__ of the binding vote weight for [Normal Decision Process](#normal-decision-process) votes, and __50%__ of the binding vote weight for [KCD Decision Process](#kcd-decision-process) votes.
   - Each representative votes independently, with an equal share of their group's total vote weight (e.g., if there are 5 representatives, each has 6% of the total binding vote weight for _Normal Decision Process_ votes).

### Limitations on Company Representation

No more than one representative seat may be held by employees of the same organization (or conglomerate, in the case of companies owning each other). 

If employers change because of job changes, acquisitions, or other events, in a way that would be in violation of the proceeding limits, sufficient members of the committee must resign their positions until the requirements are satisfied. 
If it is impossible to find sufficient members to resign, all employees of that organization will be removed and the vacancies will be filled using the normal process.

In the event of a question of company membership (for example evaluating independence of corporate subsidiaries) a majority of all non-involved KSC members will decide.

## Decision Process

### Normal Decision Process

Decisions requiring the normal decision process include:

- Any decisions on requirements for Kubeflow Subprojects
- Any decisions relating to the Kubeflow Conformant mark
- Any decisions on that are not covered by the KCD Decision Process

Rules for voting:

- All types of representative are allowed to vote on these topics.
- Decisions are made with pull requests to the community repository, must be documented in the [`decision-log.md`](decision-log.md), and vote publicly on GitHub.
- The decision is adopted if more than 50% of the TOTAL vote weight (rounded up) support it.
- Votes may only pass when at least 50% of the TOTAL vote weight (rounding down) have been cast.
- Votes expire if they are not adopted within 30 days of the vote being opened.

### KCD Decision Process

Decisions requiring the KCD decision process include:

- Any decisions on requirements for Kubeflow Community Distribution (KCD)
- Changes to the list of projects that are included in KCD, defined in [`PROJECTS.md`](PROJECTS.md)

Rules for voting:

- Only _Kubeflow Community Distribution_ and _Kubeflow Subproject_ representatives are allowed to vote on these topics.
- Decisions are made with pull requests to the community repository, must be documented in the [`decision-log-kcd.md`](decision-log-kcd.md), and vote publicly on GitHub.
- The decision is adopted if more than 50% of the TOTAL vote weight (rounded up) support it.
- Votes may only pass when at least 50% of the TOTAL vote weight (rounding down) have been cast.
- Votes expire if they are not adopted within 30 days of the vote being opened.

---

## Kubeflow Community Distribution maintainers

The Kubeflow Community Distribution (KCD) is the community-maintained reference deployment of all Kubeflow Subprojects and is vendor neutral, multi-tenant, secure, and provides an integrated experience between components.

### In Scope (minimal expectations)

- The Kubeflow Community Distribution must be Kubeflow Conformant.
- Synchronize the application and dependencies manifests to then elaborately combine (configure) them for a consistent, secure and end-to-end multi-tenant enterprise platform experience.
  Enable the consumer and distributions to install, extend, modify and maintain Kubeflow Community Distribution installations by providing documentation, automation and configurability.
- Maintain an extensive testing suite in order to cover scenarios that the community member and consumer expects from an AI/ML platform. This includes dependencies, security efforts, and exemplary integration with popular tools and frameworks and making sure via integration tests that the components work end-to-end together as a secure and multi-tenant platform.
- Maintain the evolving and not exhaustive list of included dependencies for a proper multi-tenant platform installation: Istio, KNative, Dex, Oauth2-proxy, Cert-Manager, ... as well as Kubeflow Subprojects, Kubeflow Ecosystem projects and disabled by default experimental integrations.
- Release tested releases of the Kubeflow Community Distribution for downstream consumption.
- Provide guidance and examples how the consumer could integrate non-default external authentication (e.g., companies' Identity Provider) and popular non-default services on his own.
- Make Kubeflow Community Distribution compatible with the popular Kubernetes clusters (Kind, Rancher, AKS, GKE, EKS, OpenShift, MicroK8s)
- Aid the Kubeflow Subproject maintainers in creating manifests (Helm, Kustomize), security best practices, maintain releases and versioning for their application.

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

---

## Changes to the Charter

Changes to the KDC charter can be proposed by any community member via a GitHub PR. 
Amendments will be subject to approval by a standard decision of the KSC. 
Proposals will be available for at least one week for community comments before a vote occurs.