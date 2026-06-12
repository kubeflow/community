# Kubeflow Subproject Status Level Requirements

This document establishes criteria for different maturity levels for Kubeflow subprojects.

## Maturity Levels

Kubeflow maintainers and WG leads MUST define maturity level for their projects by following below
criteria.

When projects are switched levels, the following document must be updated:

- [PROJECTS.md](PROJECTS.md) document
- [Kubeflow installation page](https://www.kubeflow.org/docs/started/installing-kubeflow/)

A subproject's maturity level reflects the overall project status. Individual APIs, features, or
components within a subproject MAY have their own stability levels that differ from the
subproject's overall level. For example, a Graduated subproject may include a Stable API alongside a
newer API that is still in Development. Subproject maintainers are responsible for documenting the
stability level of individual APIs, features, or components in their documentation websites.

### Graduated

The project is ready for general availability and MUST be included in the Kubeflow Community Distribution.
Bugs and performance problems SHOULD be reported, and there's an expectation that the maintainers
will work on them. Breaking changes, including configuration options and the project's output,
are only allowed under special circumstances.

### Incubating

Not all pieces of the project are in place yet, and it might not be available for users yet. Issues
and performance enhancements are expected to be reported. User feedback around the UX of the project
is desired, such as for Custom Resource Definition APIs, technical implementation details, and
planned use-cases for the project. Configuration options might break often depending on how things
evolve. The project NOT SHOULDbe used in production. The project MAY be removed without prior notice.

### Deprecated

Development of this project is halted and no new versions are planned. New issues will likely not
be worked on except for critical security issues. Projects assets that are included in the releases
are expected to exist for at least **two minor** releases or **one year**, whichever happens later.
Project MUST be excluded from the Kubeflow Community Distribution using the same timeline. Maintainers
also MUST communicate in which version they will archive project, either in terms of a concrete
version number or the date of a release.

### Archived

A project identified as archived does not have an active code owner. The GitHub repository is
archived or corresponding branch is not maintained.

## Kubeflow's Custom Resource Definition APIs

Some Kubeflow projects maintain Kubernetes
[Custom Resource Definition](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) APIs.
These APIs follow [Kubernetes standards](https://kubernetes.io/docs/concepts/overview/kubernetes-api/#api-changes)
for API changes including alpha, beta, and v1 policies.

## Changes to the Maturity Levels

Changes to the maturity levels may be proposed through a Pull Request on this document by a Kubeflow community member.

Amendments are accepted following the Kubeflow Steering Committee's [Normal Decision Process](../committee-steering/charter.md#normal-decision-process).

Proposals and amendments to the application process are available for at least a period of one week for comments and questions before a vote will occur.
