# How to Become Kubeflow Subproject

This directory contains applications from open-source projects that have proposed becoming Kubeflow subprojects.
Each subproject lives in its own directory (`subprojects/<issue-number>-<project-name>/`, where `<issue-number>` is the GitHub issue created in
step 1 of the [Process](#process)) and contains a populated copy of [`TEMPLATE.md`](TEMPLATE.md)
describing the project, saved as `README.md`.

For background and motivation behind this process, see [KEP-748: Expanding the Kubeflow Ecosystem with a New OSS Project](../proposals/748-expand-kubeflow-ecosystem/README.md).

This process follows the Kubeflow Steering Committee's [Normal Decision Process](../KUBEFLOW-STEERING-COMMITTEE.md#normal-decision-process).
Acceptance is at the discretion of the Kubeflow Steering Committee and is not guaranteed.

## Process

Project owners or maintainers can apply to become a Kubeflow subproject by following these steps:

1. Create a GitHub Issue with a Google Document outlining your proposal (please allow for commentary).
2. Provide a demo during the Kubeflow Community Call.
3. Submit a Pull Request to the [`kubeflow/community`](https://github.com/kubeflow/community) repository that adds a new directory `subprojects/<issue-number>-<your-project-name>/` (using the issue number from step 1) containing a populated copy of [`TEMPLATE.md`](TEMPLATE.md) saved as `README.md`.
   - If needed, you can include the technical details about your project and Kubeflow integrations after the checklist.
     Follow the [KEP](../proposals) process to understand which section to add.
4. Add your proposal to the Kubeflow Community Call to introduce it and collect feedback.
5. Work with the Kubeflow Outreach Committee to send an announcement email to `kubeflow-discuss` and publish messages on Slack, LinkedIn, X/Twitter, and other Kubeflow social resources.
6. Schedule a meeting with the Kubeflow Steering Committee for an initial vote and to collect feedback.
7. Identify the appropriate Kubeflow Working Group that should oversee the project.
8. Merge or close the Pull Request depending on the outcome of the final vote.

## Repository Setup

After your project is transferred, create the tracking issue with using the following template to complete transition.

## Chore description

This issue tracks the migration of _<PROJECT_NAME>_ from the _<ORG_NAME>_ organization to the
Kubeflow organization following official approval.

## 📋 Background

- **Status**: ✅ Approved by Kubeflow maintainers
- **Proposal**: _<LINK_TO_PR>_
- **Approval Date**: 2026-05-01
- **Target Repository**: `kubeflow/<REPO_NAME>`

## 🔄 Migration Checklist

### Repository Compliance

- [ ] Create OWNERS file with appropriate approvers/reviewers
- [ ] Update CONTRIBUTING.md with Kubeflow guidelines
- [ ] Add DCO (Developer Certificate of Origin) sign-off documentation
- [ ] Verify Apache 2.0 license formatting
- [ ] Verify if we should update copyright notices for Kubeflow ownership

### Code Quality Standards & CI/CD

- [ ] Prepare GitHub Actions workflows for Kubeflow org
- [ ] Run full test suite and ensure passing
- [ ] Run security scan and address issues
- [ ] Verify linting standards compliance
- [ ] Update pre-commit hooks for Kubeflow standards

### External References Update

- [ ] Update CI badge URLs in documentation
- [ ] Update example configurations and manifests

### Functionality Testing

- [ ] Test local development environment setup
- [ ] Verify CI/CD pipeline functionality
- [ ] Test package installation from new location

### Community Access

- [ ] Verify contributor access for existing team members
- [ ] Test issue reporting process
- [ ] Confirm PR submission workflow
- [ ] Validate release process

### 📢 Communication Plan

- [ ] Announce migration completion
- [ ] Publish updated installation/contribution guides

## Changes to the Application Process

Changes to the application process charter may be proposed through a Pull Request on this document by a Kubeflow community member.

Amendments are accepted following the Kubeflow Steering Committee's [Normal Decision Process](../KUBEFLOW-STEERING-COMMITTEE.md#normal-decision-process).

Proposals and amendments to the application process are available for at least a period of one week for comments and questions before a vote will occur.
