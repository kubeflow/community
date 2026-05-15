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

1. Create a GitHub Issue with a Google Document outlining your proposal (please allow for commentary). The document should include:
   - Authors
   - Motivation
   - Benefits for Kubeflow
   - Benefits for the project's community
   - Community metrics
   - Contributor metrics
   - Maintainers
   - Migration plan
   - Other related projects
2. Provide a demo during the Kubeflow Community Call.
3. Submit a Pull Request to the [`kubeflow/community`](https://github.com/kubeflow/community) repository that adds a new directory `subprojects/<issue-number>-<your-project-name>/` (using the issue number from step 1) containing a populated copy of [`TEMPLATE.md`](TEMPLATE.md) saved as `README.md`.
4. Add your proposal to the Kubeflow Community Call to introduce it and collect feedback.
5. Work with the Kubeflow Outreach Committee to send an announcement email to `kubeflow-discuss` and publish messages on Slack, LinkedIn, X/Twitter, and other Kubeflow social resources.
6. Schedule a meeting with the Kubeflow Steering Committee for an initial vote and to collect feedback.
7. Identify the appropriate Kubeflow Working Group that should oversee the project.
8. Merge or close the Pull Request depending on the outcome of the final vote.

## Changes to the Application Process

Changes to the application process charter may be proposed through a Pull Request on this document by a Kubeflow community member.

Amendments are accepted following the Kubeflow Steering Committee's [Normal Decision Process](../KUBEFLOW-STEERING-COMMITTEE.md#normal-decision-process).

Proposals and amendments to the application process are available for at least a period of one week for comments and questions before a vote will occur.
