# How to Join Kubeflow Ecosystem

Kubeflow has always fostered a strong community-driven culture and actively supports projects
that build on, integrate with, or complement Kubeflow sub-projects. As part of this effort,
the Kubeflow community established the Kubeflow Ecosystem to highlight projects that are valuable
to the broader community and demonstrate maturity, sustainability, and excellence within their respective domains.

## Ecosystem Project Requirements

When projects are considered for the Kubeflow ecosystem, the Kubeflow Steering Committee considers
factors they believe are essential for community adoption. These criteria include the following:

### Functional Requirements

- Kubeflow sub-projects support: Project MUST demonstrate benefit to the Kubeflow community and be
  integrated with at least one Kubeflow sub-project.
- Working CI: Projects MUST have a demonstrable working CI workflow for all declared architectures
- Governance: Projects SHOULD have documented technical governance defined and implemented and it
  must be represented in their Github or Gitlab repository.
  For more details review [CNCF governance recommendations](https://contribute.cncf.io/projects/best-practices/governance/).
- User experience: The value proposition SHOULD be made clear for the project and documented in the
  README of the project repository.
- Quick start: Project SHOULD have a working and demonstrable quick start guide.
- There must be at least integration documentation, better automated continuous integration tests (whether in the community distribution or the upstream repository)
- Documentation: Projects MUST have clear and comprehensive documentation.
- Permissive licensing: Users MUST be able to utilize ecosystem projects without licensing concerns.
  e.g. BSD-3, Apache-2 and MIT licenses

### Measurable Requirements

- Core Maintainers: The project MUST have a minimum of 2 core maintainers
- Contributors: The project SHOULD have a minimum of 3 total contributors active in the last 90 days.
- Commits: The project MUST have 10 commits in the last 90 days.

### Github Layout Requirements

- LICENSE.md MUST be at the root of the repository specifying the terms and conditions for using,
  distributing, and modifying the software.
- README.md SHOULD welcome new community members to the project and explains why the project is
  useful and how to get started.
- CONTRIBUTING.md SHOULD explain how to contribute to the project. The file explains the types of
  contributions needed and how the development process works.
- OWNERS or similar file SHOULD define individuals or teams responsible for code in a repository,
  document current project owners and retired committers.
- CODE_OF_CONDUCT.md SHOULD set the ground rules for participants behavior and helps facilitate a
  friendly, welcoming environment. By default, projects SHOULD leverage the
  [CNCF Code of Conduct](https://github.com/cncf/foundation/blob/main/code-of-conduct.md) unless an
  alternate Code of Conduct is approved prior.

## Ecosystem Project Process

- Open an issue using [the ecosystem application template](https://github.com/kubeflow/community/issues/new?template=ecosystem.yaml)
  in the Kubeflow Community repository
- Attend [the Kubeflow Community Call](http://bit.ly/kf-meeting-notes) on Tuesday to present your project and why it should be accepted
  into Kubeflow ecosystem
- Projects are approved when more than 50% of Kubeflow Steering Committee members approve. Projects
  are rejected or postponed otherwise
- Add your project into [Kubeflow Ecosystem website page](https://www.kubeflow.org/docs/ecosystem/)
- Update [PROJECTS.md file](./PROJECTS.md)

## Periodic Review & Project Offboarding

Every 12 months all projects are reviewed by the Kubeflow community leadership to ensure that they
still meet the [Ecosystem Project Requirements](#ecosystem-project-requirements). Project owners
will be notified why their project no longer qualifies to be an Ecosystem project and will have 60 days to
implement the necessary changes. If the project owners do not implement the changes or do not
respond to requests, then the project will be immediately retired and will no longer be a part of
the Ecosystem and listed in an active state in [the Kubeflow Website](https://www.kubeflow.org/docs/ecosystem/).

## Changes to the Process

Changes to the Kubeflow ecosystem process can be proposed by any community member via a GitHub PR.
Amendments will be subject to approval by a standard decision of the KSC. Proposals will be
available for at least one week for community comments before a vote occurs.
