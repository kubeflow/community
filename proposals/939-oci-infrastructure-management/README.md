# KEP-939: Infrastructure Management Process for CNCF Kubeflow Oracle Cloud Infrastructure (OCI) Tenancy

**Authors:**

- Akash Jaiswal - [@jaiakash](https://github.com/jaiakash)
- Chase Christensen - [@chasecadet](https://github.com/chasecadet)

**Tracking Issue:** [kubeflow/community#939](https://github.com/kubeflow/community/issues/939)

---

## Summary

This KEP proposes a formal and transparent process for requesting, provisioning,
managing, and decommissioning infrastructure within the `cncfkubeflow` Oracle
Cloud Infrastructure (OCI) tenancy.

As our community grows — particularly with initiatives such as GSoC and
architecture-specific efforts — there is a need for a clearer and more scalable
process. Right now, requests are handled on an ad-hoc basis through Slack
threads or the `#kubeflow-oci-resources` channel.

This proposal formalizes how maintainers, WG leads, and GSoC mentors can request
development and testing infrastructure, and how such requests are reviewed,
approved, provisioned, and eventually cleaned up. The goal is not to introduce
bureaucracy, but to improve visibility, ownership, and lifecycle management of
shared community infrastructure.

The Oracle Cloud Infrastructure (OCI) tenancy primarily supports development
and testing use cases, including environments that may not be possible with
official CNCF infrastructure.

## Motivation

As the Kubeflow community continues to grow, so does the need for dedicated
infrastructure to support development, testing, and validation efforts across
Working Groups and community initiatives.

Recent and upcoming efforts — such as several GSoC projects, community events,
ARM64 build validation, architecture-specific CI runners, and GPU-based
testing — increasingly require temporary but dedicated compute resources. These
use cases often need environments that are configurable and available for a
defined period of time.

Some past/current examples include:

- GSoC 2025 project: [Project 7: GPU Testing for LLM Blueprints](https://summerofcode.withgoogle.com/programs/2025/projects/fwZkvPr0)
- GSoC 2026 projects: [Agentic RAG on Kubeflow — Multi-Index Retrieval with Kagent & MCP](https://summerofcode.withgoogle.com/programs/2026/projects/nBywCSvb),
  [Dynamic LLM Trainer Framework for Kubeflow — TRL Backend with Pluggable Multi-Framework Support](https://summerofcode.withgoogle.com/programs/2026/projects/ErYS3o18)
- ARM64 Validation: Architecture-specific build and validation efforts requiring
  dedicated compute resources.
- [Planned] Oracle x Kubeflow Distro Project: Future infrastructure needs for
  distribution-specific validation.
- [Planned] AI playground for Kubeflow: Proposed sandbox environments for
  community experimentation.

The current process for requesting and managing infrastructure is informal and
not standardized. As the number of contributors and infrastructure-dependent
initiatives increases, this model does not scale effectively. Without a defined
lifecycle and ownership model, resources may persist longer than intended,
ownership can become unclear, and operational visibility becomes harder over
time.

This KEP introduces a structured yet lightweight process to support Kubeflow's
continued growth, ensuring that shared infrastructure remains sustainable,
transparent, and community-driven.

### Goals

- **Define a Clear Request Workflow**
  Establish a documented and transparent process for maintainers, WG leads, and
  GSoC mentors to request development and testing infrastructure via GitHub.

- **Standardize Cluster Deployment**
  Establish the Kubeflow Community Distribution as the standard mechanism for
  deploying and upgrading all clusters to ensure consistency.

- **Ensure Auditability via Infrastructure as Code**
  Mandate the use of Terraform to establish a clear deployment lineage and audit
  trail for all infrastructure provisioning and state changes.

- **Implement GitOps Access Controls**
  Manage and grant user access securely and transparently through GitOps
  workflows.

- **Open-Source Operational Tooling**
  Open-source all Terraform configurations used to provision clusters, providing
  the broader community with real-world, production-ready reference code.

- **Publish Kubeflow Field Operations Guides**
  Translate the knowledge, architecture, and deployment methodologies gained
  from running this tenancy into practical, community-facing guides for
  production cluster management.

- **Enable Infrastructure for Growth Initiatives**
  Require every provisioned resource to have a documented purpose, a linked
  tracking issue, and a clearly identified Point of Contact (PoC).

- **Introduce Default Time-Bound Allocations & Leases**
  Provide a scalable structure leveraging leases that allows the Oracle Cloud
  Infrastructure (OCI) tenancy to support Kubeflow's continued growth without
  creating operational ambiguity or "zombie" clusters.

- **Maintain Sustainable Tenancy Operations**
  Ensure the long-term viability of shared community resources by defining clear
  infrastructure guidelines and active cost-alerting methodologies.

- **Implement Secure Deployments**
  Protect cluster infrastructure by mandating network perimeters and firewalls
  in front of all Kubeflow endpoints. Restrict access strictly to approved IP
  ranges or enforce secure connectivity via a community VPN solution to mitigate
  external exposure.

### Non-Goals

- **Managing Long-Term Production Infrastructure**
  This proposal focuses on development, testing, and validation environments. It
  does not define policies for long-running production services.

- **Replacing Official CNCF Infrastructure or CI**
  The Oracle Cloud Infrastructure (OCI) tenancy may support temporary or
  experimental workloads, but this KEP does not aim to replace CNCF-managed
  infrastructure.

- **Introducing Hard Quotas or Budget Controls**
  This proposal does not establish financial governance mechanisms or rigid
  resource quota systems, though it does introduce basic cost alerting.

- **Adding Excessive Approval Overhead**
  The intent is to formalize lifecycle and ownership clarity — not to create
  unnecessary barriers for contributors.

## Proposal

The proposed solution involves implementing a structured infrastructure
management issue tracker hosted within the `kubeflow/community` repository. This
system will leverage GitHub Issue Templates to facilitate request tracking,
coupled with transparent approval workflows, defined lifecycle boundaries, and
standardized deployment methodologies.

### Cluster Deployment Standard & Terraform Auditability

To prevent configuration drift and fragmented setups, all approved clusters must
utilize the Kubeflow Community Distribution as the standard methodology for
deployment and future upgrades.

Furthermore, we will implement deployment lineage and auditability using
Terraform. All infrastructure provisioning, modifications, and teardowns must be
managed as code. This ensures a fully reproducible and auditable trail (tied to
the GitHub issue) of how a cluster evolved during its lifecycle. No manual
infrastructure changes should occur outside of this Terraform state.

### Open-Source Code & Kubeflow Field Operations Guides

To give back to the community and lower the barrier to entry for enterprise
users, all Terraform code used to provision these clusters will be fully
open-sourced.

Alongside the raw infrastructure code, we will provide end-to-end guidance
detailing exactly how to deploy a Kubeflow cluster using these exact GitOps and
Terraform methodologies. Over time, the practical, real-world experiences,
troubleshooting, and optimizations gained from managing this community
infrastructure will be synthesized into official "Kubeflow Field Operations
Guides", serving as a blueprint for administrators running Kubeflow in
production environments elsewhere.

### Team Structure & GitOps Access Control

Managing this structured environment requires dedicated oversight. This KEP
proposes an open discussion on whether the team handling the Oracle Cloud
Infrastructure (OCI) tenancy should operate as a sub-group within the existing
Kubeflow Community Distribution team (given the shared tooling and deployment
standards) or be formed as a separate, specialized Infrastructure Management
team.

Regardless of the team structure, baseline access controls will be standardized
via GitOps:

- User access, RBAC policies, and cluster permissions will be granted and
  managed through GitOps repository workflows rather than manual cluster
  interventions.
- Maintainers and Kubeflow Steering Committee (KSC) members will receive default
  administrative access to all provisioned clusters via these GitOps
  configurations to ensure broad operational oversight and transparency.

### User Stories

#### Story 1: GSoC Contributor Needs a Cluster

A GSoC student tasked with "End-to-End ARM64 Support" requires a dedicated ARM
cluster for validation. The project mentor initiates an "Infrastructure Request"
issue. Upon approval, resources are provisioned via Terraform using the Kubeflow
Community Distribution for the GSoC term. Access is granted via a GitOps PR. The
cluster is scheduled for decommissioning at the term's conclusion unless a lease
extension is granted.

#### Story 2: Working Group Needs Niche Testing Environment

A Working Group requires a specific OS environment to validate a new component
integration. The WG lead submits a request for a 30-day VM lease. Once approved,
the environment is provisioned and its state is recorded via Terraform. To
prevent indefinite resource consumption, the system alerts the team prior to
expiration and is decommissioned after the 30-day window unless renewed.

#### Story 3: Community Administrator Seeks Deployment Best Practices

An external platform engineer wants to stand up a highly auditable Kubeflow
environment on Oracle Cloud Infrastructure (OCI) using GitOps. Instead of
starting from scratch, they reference the open-sourced community Terraform
configurations and follow the newly minted Kubeflow Field Operations Guide to
securely deploy their cluster.

### Workflow Details

1. **Request Phase:**
   Contributors or WG Leads open an issue in the `kubeflow/community` repository
   using the designated template. This requires details on purpose, resource
   specifications (vCPUs, RAM, OS), requested duration (lease term), and an
   identified Point of Contact (PoC).
2. **Review & Approval:**
   Requests undergo review by KSC members, WG leads, and Oracle Cloud
   Infrastructure (OCI) administrators. Formal approval requires at least one
   `/approve` comment from an authorized maintainer.
3. **Provisioning & Access:**
   Following approval, the team provisions the resources strictly via Terraform
   and deploys the standard Kubeflow Community Distribution. Access is then
   granted to the PoC by merging the appropriate RBAC changes into the GitOps
   repository.
4. **Lifecycle, Leases & Cleanup:**
   To maintain visibility, all resources operate on a strict lease methodology.
   Provisioned resources are tagged within Terraform with the GitHub Issue
   number, owner, and lease expiration date.
5. **Alerting:**
   Automated methodologies will be put in place to alert the management team and
   KSC on long-running clusters.
6. **Auditing & Renewal:**
   Before a lease expires, the PoC is alerted and must actively renew access.
   This triggers a brief audit to verify who currently has access and whether
   the resources are still strictly necessary, removing GitOps access when no
   longer required.

### Infrastructure Guidelines & Cost Alerts

To protect community resources, the Infrastructure team will publish a set of
Infrastructure Guidelines outlining acceptable resource boundaries for standard
requests (e.g., standard VM shapes, GPU caps).

Additionally, proactive Cost Alerts will be implemented at the Oracle Cloud
Infrastructure (OCI) compartment level. If a cluster's usage spikes or the
overall tenancy approaches a specific
threshold, alerts will automatically notify the management team and KSC,
allowing for immediate auditing and intervention before significant costs are
incurred.

### Risks and Mitigations

- **Risk:** Unused resources incurring costs (Zombie Infrastructure).
  - **Mitigation:** Strict enforcement of leases and expiration dates attached
    to every request, mandatory Terraform tagging, and automated alerts on
    long-running clusters ahead of lease expiration.
- **Risk:** Security breaches through temporary environments.
  - **Mitigation:** Network perimeters and firewalls in front of all Kubeflow
    endpoints, access restricted to approved IP ranges or via a community VPN,
    least-privilege RBAC managed through GitOps, and access removal on lease
    expiry.
- **Risk:** Excessive manual toil for admins.
  - **Mitigation:** Manage all provisioning through Terraform, automate lease
    alerts and decommissioning reminders via GitHub Actions, and handle access
    changes through GitOps PRs rather than manual cluster interventions.
- **Risk:** Configuration drift and fragmented, one-off cluster setups.
  - **Mitigation:** Mandate the Kubeflow Community Distribution as the single
    deployment standard and forbid manual infrastructure changes outside the
    Terraform state.

## Design Details

### Design Details for Alpha Phase

#### Request Template Implementation

A specialized GitHub Issue template will be established at
`.github/ISSUE_TEMPLATE/infrastructure-request.yml` within the community
repository to standardize the intake process.

#### Tagging Standard

To ensure accountability, all resources within the Oracle Cloud Infrastructure
(OCI) tenancy must adhere to a mandatory tagging schema via Terraform:

- `owner`: The GitHub handle of the responsible PoC.
- `issue`: A reference to the requesting GitHub issue ID or URL.
- `expiry_date`: The lease decommissioning date formatted as `YYYY-MM-DD`.

### Test Plan

Since this is an operational process KEP, the test plan does not require
software unit or integration tests. Instead, verification consists of:

1. **Template Dry-Run**: Verify that the GitHub issue template renders correctly
   and all mandatory fields (PoC, duration, requirements) are enforced on
   creation.
2. **Review Workflow Dry-Run**: Simulate an infrastructure request with a dummy
   issue to verify the notification flow to designated Oracle Cloud
   Infrastructure (OCI) admins and KSC members.
3. **Audit and Cleanup Dry-Run**: Perform a manual audit of existing resources
   to check that Terraform tags are properly applied and ensure they can be
   successfully queried in the Oracle Cloud Infrastructure (OCI) Console.

### Implementation Phases

#### Alpha Phase

- Oracle Cloud Infrastructure (OCI) administrators will execute resource
  provisioning through manual Terraform workflows.
- Requests will be tracked manually using the designated issue tracker within
  the `kubeflow/community` repository.
- Clusters deployed manually using the Kubeflow Community Distribution.
- Manual configuration of GitOps repository access for the requested PoCs.
- Consolidation of baseline Terraform scripts into a public community folder.
- Strict enforcement of the mandatory tagging schema within Terraform modules:
  `owner`, `issue`, and `expiry_date`.

#### Beta Phase

- Integration of GitHub Actions or webhooks to trigger automated lease alerts,
  renewal methodologies, and decommissioning reminders.
- Implementation of automated cost alerts linked to community communication
  channels (e.g., Slack).
- Formal organization of the open-source Terraform repo with clean documentation
  modules.
- Publication of the initial draft of the Kubeflow Field Operations Guides
  focusing on basic provisioning and GitOps setup.

## Implementation History

- **2026-06-03**: KEP-939 proposed.
- **2026-06-03**: GitHub Issue template designed and added.
- **2026-08-12**: KEP revised to add deployment standards, Terraform
  auditability, GitOps access controls, leases, cost alerting, and security
  requirements.

## Drawbacks

- **Administrative Overhead**: Introduces manual verification steps for WG leads
  and Oracle Cloud Infrastructure (OCI) admins to review issues, verify tags,
  and audit lease renewals.
- **Fulfillment Latency**: Contributors might experience a short delay between
  issue approval and actual resource provisioning, as provisioning is initially
  manual.

## Alternatives

### Ad-hoc Slack and Email Requests

- **Drawbacks**: Informal requests lack centralized tracking, public
  transparency, and auditability. This often results in "zombie" resources that
  persist indefinitely due to the absence of leases, a linked tracking artifact,
  or automated expiration enforcement.

### Official CNCF Cluster Requests

- **Drawbacks**: This approach won't work for the niche use cases and temporary
  architecture-specific validations that our community sometimes needs. CNCF
  resources should be reserved for production or long-term community
  infrastructure (such as
  [cncf/automation#115](https://github.com/cncf/automation/issues/115)).
