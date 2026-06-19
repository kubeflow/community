# Kubeflow Distribution Policy

[The Kubeflow Distribution](https://www.kubeflow.org/docs/started/introduction/#kubeflow-distribution)
is a vendor-provided and supported deployment of Kubeflow subprojects and integrations designed to
run on specific infrastructure or platform environments.

This document defines requirements and expectations for Kubeflow Distributions.

## Kubeflow Distribution Requirements

To ensure Kubeflow users will get the expected experience and results regardless of where
they run Kubeflow subprojects, each Kubeflow Distribution MUST meet the following criteria to be
listed in [the Kubeflow Website](https://www.kubeflow.org/docs/started/installing-kubeflow/#kubeflow-distributions):

- Be compatible with **n-2** version of Kubeflow Community Distribution
- Being listed in one of Kubeflow subprojects [`ADOPTERS.md`](https://github.com/kubeflow/community/blob/master/ADOPTERS.md)
  files
- Well defined documentation website
- Point of contact that Kubeflow community can reach out to
- Defined Kubernetes target platform

Kubeflow Distribution Committee is currently working towards the Kubeflow Conformance program.
Once this program is created, Kubeflow Distributions MUST achieve the Kubeflow Certified mark.

## Periodic Review & Distribution Removal

Every 6 months all Kubeflow Distributions are reviewed by the Kubeflow Steering Committee
and Kubeflow Distribution Committee to ensure that they still meet the requirements.

If a distribution no longer qualifies to be listed as a Kubeflow Distribution, its owners will
be notified of the reasons why via their contact details and will have 90 days to implement the
necessary changes.

If the distribution owners do not implement the changes or do not respond to requests, then the
distribution will be removed and will no longer be listed in the Kubeflow website.

## Changes to the Process

Changes to the Kubeflow Distribution policy can be proposed by any community member via a GitHub PR.
Amendments will be subject to approval by a standard decision of the Kubeflow Steering Committee.
Proposals will be available for at least one week for community comments before a vote occurs.
