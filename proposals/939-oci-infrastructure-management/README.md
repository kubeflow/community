# KEP-939: Formalize Infrastructure Management Process for CNCF Kubeflow OCI Tenancy

## Summary

This KEP proposes a lightweight and transparent process for requesting, provisioning, managing, and decommissioning infrastructure within the CNCF Kubeflow Oracle Cloud Infrastructure (OCI) tenancy.

As Kubeflow grows — particularly with initiatives such as GSoC and architecture-specific efforts like ARM64 validation — there is a need for a clearer and more scalable process.

This proposal formalizes how maintainers, Working Group leads, and GSoC mentors can request development and testing infrastructure, and how such requests are reviewed, approved, provisioned, and eventually cleaned up. The goal is not to introduce bureaucracy, but to improve visibility, ownership, and lifecycle management of shared community infrastructure.

The OCI tenancy primarily supports development and testing use cases, including environments that may mirror official CNCF infrastructure for validation purposes. This KEP ensures that all allocated resources have a documented purpose, owner, and defined lifecycle, enabling sustainable and community-focused infrastructure management.

## Motivation

As Kubeflow continues to grow, so does the need for dedicated infrastructure to support development, testing, and validation efforts across Working Groups and community initiatives.

Recent and upcoming efforts — such as ARM64 build validation, architecture-specific CI runners, GPU-based testing, and GSoC projects — increasingly require temporary but dedicated compute resources. These use cases often need environments that are isolated, configurable, and available for a defined period of time.

The current process for requesting and managing infrastructure is informal and not standardized. As the number of contributors and infrastructure-dependent initiatives increases, this model does not scale effectively. Without a defined lifecycle and ownership model, resources may persist longer than intended, ownership can become unclear, and operational visibility becomes harder over time.

This KEP introduces a structured yet lightweight process to support Kubeflow’s continued growth, ensuring that shared infrastructure remains sustainable, transparent, and community-driven.

## Goals

## Goals

- **Define a Clear Request Workflow**  
  Establish a documented and transparent process for maintainers, Working Group leads, and GSoC mentors to request development and testing infrastructure via GitHub.

- **Enable Infrastructure for Growth Initiatives**  
  Require every provisioned resource to have a documented purpose, a linked tracking issue, and a clearly identified Point of Contact (PoC).

- **Ensure Visibility and Ownership**  
  Support efforts such as ARM64 validation, GPU-based CI runners, GSoC projects, and other architecture or integration work that requires temporary dedicated resources.

- **Introduce Default Time-Bound Allocations**  
  Provide a scalable structure that allows the OCI tenancy to support Kubeflow’s continued growth without creating operational ambiguity.

- **Maintain Sustainable Tenancy Operations**  
  Provide a scalable structure...

## Non-Goals

Managing Long-Term Production Infrastructure
This proposal focuses on development, testing, and validation environments. It does not define policies for long-running production services.

Replacing Official CNCF Infrastructure or CI
The OCI tenancy may support temporary or experimental workloads, but this KEP does not aim to replace CNCF-managed infrastructure.

Introducing Hard Quotas or Budget Controls
This proposal does not establish financial governance mechanisms or resource quota systems.

Adding Excessive Approval Overhead
The intent is to formalize lifecycle and ownership clarity — not to create unnecessary barriers for contributors.

## Proposal

We propose implementing an infrastructure management workflow centered around the `kubeflow/community` repository using GitHub Issue Templates for request tracking, alongside clear approval guidelines and lifecycle limits.

### User Stories

#### Story 1: GSoC Contributor Needs a Cluster
A GSoC student working on "End-to-End ARM64 Support" needs an ARM cluster. The student's mentor submits an "Infrastructure Request" issue. Once approved by the Steering Committee or designated OCI admins, the resources are provisioned for the duration of the GSoC term (e.g., 3-4 months). At the end of the term, the resources are automatically scheduled for decommissioning unless an extension is requested.

#### Story 2: Working Group Needs Niche Testing Environment
A WG needs to test a new component integration on a specific OS version before it is added to the primary CI pipeline. A WG lead files a request for a VM for a 30-day period. The request is reviewed, approved, and tracked. After 30 days, the environment is decommissioned, ensuring costs do not accrue indefinitely.

### Workflow Details

1. **Request Phase:** 
   * A contributor or WG Lead opens an issue in `kubeflow/community` using the "Infrastructure Request" template.
   * The template requires details: Purpose (e.g., GSoC 2026), Resource requirements (vCPUs, RAM, OS), Requested duration (e.g., 30 days, 90 days), and the responsible Point of Contact (PoC).
2. **Review & Approval:**
   * Requests are reviewed by designated the KSC/WG leads and OCI admins.
   * Approval requires at least one approving review (`/approve`) from an authorized maintainer.
3. **Provisioning:**
   * Upon approval, OCI Administrators provision the requested resources (ideally via Infrastructure as Code like Terraform, but manually if necessary initially).
   * Credentials/access are securely shared with the PoC.
4. **Lifecycle & Cleanup:**
   * Resources are tagged with their associated GitHub Issue number and expiration date.
   * If no extension is requested, the resources are decommissioned and the issue is closed.

### Risks and Mitigations

* **Risk:** Unused resources incurring costs (Zombie Infrastructure).
  * **Mitigation:** Strict enforcement of lifecycles and "expiration dates" attached to every request. Regular audits of the OCI tenancy using tagging.
* **Risk:** Security breaches through temporary environments.
  * **Mitigation:** Principle of least privilege for provisioned access. Infrastructure should be isolated, and credentials rotated or revoked immediately upon expiration.
* **Risk:** Excessive manual toil for admins.
  * **Mitigation:** Automate tracking via GitHub actions (e.g., closing issues or pinging owners) and encourage Infrastructure as Code practices for the OCI tenancy.

## Design Details

### Request Template Implementation

A new GitHub Issue template `.github/ISSUE_TEMPLATE/infrastructure-request.yml` will be added to the relevant repository (e.g., `kubeflow/community` or a dedicated infra repo). 

```yaml
name: Infrastructure Request
description: Request testing or development infrastructure in the Kubeflow OCI Tenancy
body:
  - type: dropdown
    id: purpose
    attributes:
      label: Purpose
      options:
        - GSoC / Mentorship
        - Working Group Testing
        - Architecture Validation (e.g., ARM64)
        - Other
    validations:
      required: true
  - type: textarea
    id: resource_details
    attributes:
      label: Resource Requirements
      description: Number of VMs, vCPUs, Memory, OS, etc.
    validations:
      required: true
  - type: input
    id: duration
    attributes:
      label: Requested Duration
      description: e.g., 30 days, until GSoC ends (August 2026)
    validations:
      required: true
  - type: input
    id: contact
    attributes:
      label: Point of Contact (PoC)
      description: GitHub handle of the person responsible for this infrastructure.
    validations:
      required: true
```

### Tagging Standard

All resources in the OCI tenancy must have at least the following tags:
- `owner`: GitHub handle of the PoC.
- `issue`: Link or ID of the requesting GitHub issue.
- `expiry_date`: YYYY-MM-DD format indicating when to decommission.

## Implementation History

- KEP Creation: 2026-02-22
