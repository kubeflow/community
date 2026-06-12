# Kubeflow Subproject Status Level Requirements

This document establishes criteria for different maturity levels for Kubeflow subprojects.

## Maturity Levels

A project moves to a new level by a decision of the Kubeflow Steering Committee (KSC): the project's
maintainers demonstrate that the project meets the criteria below, and the KSC approves the move.

When projects are switched levels, maintainers demonstrate , the following documents must be updated:

- [PROJECTS.md](PROJECTS.md) document
- [Kubeflow installation page](https://www.kubeflow.org/docs/started/installing-kubeflow/)

A subproject's maturity level reflects the overall project status. Individual APIs, features, or
components within a subproject MAY have their own stability levels that differ from the
subproject's overall level. For example, a Graduated subproject may include a Stable API alongside a
newer API that is still in Development. Subproject maintainers are responsible for documenting the
stability level of individual APIs, features, or components in their documentation websites.

The Graduated, Incubating, and Experimental levels each impose a cumulative set of requirements. If
a project stops meeting these criteria, the KSC reviews it and MAY move it to Deprecated if
the gaps are not resolved within 180 days.

### Graduated

The project is stable and ready for general availability. Breaking changes are only allowed
following the defined feature lifecycle for the project.

#### Requirements

- The project MUST meet all Incubating requirements
- The project MUST have had a major version (v1 or higher) released for at least 90 days that has
  been adopted by at least 3 companies
- The project MUST be included in the Kubeflow Community Distribution
- The project MUST have a defined feature lifecycle and a history of following it
- The project MUST achieve the OpenSSF Best Practices badge
- The project MUST have a history of consistently following its security policies

### Incubating

The project is actively developed, broadly usable, and on track for Graduation. While most core
functionality is stable, it is still maturing toward a final release. Our maintainers prioritize
fixing bugs and optimizing performance. APIs and configuration options may change between releases.
We recommend thoroughly testing the project before deploying it to a production environment.

#### Requirements

- The project MUST meet all Experimental requirements
- The project MUST must be used by at least 1 company
- The project MUST have a minimum of 2 core maintainers who have been active over the last 180 days
- The project MUST have a minimum of 3 active contributors over the last 180 days
- The project MUST have a demonstrable, working CI workflow for all declared architectures
- The project MUST have a documentation website that clearly explains its features and how to use them
- The project MUST have a SECURITY.md that defines its security processes and how reports are handled

### Experimental

Not all pieces of the project are in place yet, and it might not be available for users yet. User
feedback around the UX of the project is desired, such as for Custom Resource Definition APIs,
technical implementation details, and planned use-cases for the project. Maintainer may remove the
project without prior notice.

#### Requirements

- The project MUST have at least 1 core maintainer
- The project MUST have a minimum of 1 contributor active over the last 180 days

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
