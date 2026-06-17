# Community Membership

This document outlines the various responsibilities of contributor roles in Kubeflow. Kubeflow
is divided into working groups (WG) that have stewardship over different [Kubeflow subprojects](subprojects).

Responsibilities for most roles are scoped to these repositories.

| Role       | Responsibilities                                         | Requirements                                                                 | Defined by                        |
| ---------- | -------------------------------------------------------- | ---------------------------------------------------------------------------- | --------------------------------- |
| Member     | Active contributor in the community                      | Sponsored by 2 Kubeflow members                                              | Kubeflow GitHub org member        |
| Reviewer   | Review contributions from others                         | History of contributions in a subproject                                     | [OWNERS] file reviewer entry      |
| Approver   | Contributions acceptance approval                        | Highly experienced active contributor to a subproject                        | [OWNERS] file approver entry      |
| WG Lead    | Technical leadership for a WG                            | Have sufficient domain knowledge to provide effective technical leadership   | [wgs.yaml] entry                  |
| WG Chair   | Overall leadership and direction for a WG                | Have sufficient domain knowledge to provide effective leadership             | [wgs.yaml] entry                  |
| KOC Member | [KOC Charter](committee-outreach/charter.md#charter)     | [Committee Structure](committee-outreach/charter.md#committee-structure)     | [Members](committee-outreach)     |
| KDC Member | [KDC Charter](committee-distribution/charter.md#charter) | [Committee Structure](committee-distribution/charter.md#committee-structure) | [Members](committee-distribution) |
| KSC Member | [KSC Charter](committee-steering/charter.md#charter)     | [Committee Structure](committee-steering/charter.md#committee-structure)     | [Members](committee-steering)     |

## New contributors

[New contributors] should be welcomed to the community by existing members, helped with PR workflow,
and directed to the relevant documentation and communication channels.

## Established community members

Established community members are expected to demonstrate their adherence to the principles in this document,
familiarity with project organization, roles, policies, procedures, conventions, etc.,
and technical and/or writing ability. Role-specific expectations, responsibilities, and requirements
are enumerated below.

## Member

Members are [continuously active](#inactive-members) contributors in the community. They can have
issues and PRs assigned to them and tests are automatically run for their PRs. Members are expected
to remain active contributors to the community.

**Defined by:** Member of the Kubeflow GitHub organization

### Requirements

- Enabled [two-factor authentication](https://docs.github.com/en/authentication/securing-your-account-with-two-factor-authentication-2fa/about-two-factor-authentication)
  on their GitHub account
- Have made **at least** 2-3 [code contributions](https://contribute.cncf.io/contributors/getting-started/#code-contributors)
  or [non-code contributions](https://contribute.cncf.io/contributors/getting-started/#non-code-contributors)
  to the project or community
- Have read the [contributor guide](https://www.kubeflow.org/docs/about/contributing/)
- Sponsored by 2 Kubeflow members. **Note the following requirements for sponsors**:
  - Open an issue with [the membership template](https://github.com/kubeflow/internal-acls/blob/master/.github/ISSUE_TEMPLATE/join_org.md) against the
    `kubeflow/internal-acls repo`
  - Ensure your sponsors are `@mentioned` on the issue
- Open a pull request against the `kubeflow/internal-acls` repo
  - Complete every item on the checklist, [preview the current version of the template][https://github.com/kubeflow/internal-acls/blob/master/.github/ISSUE_TEMPLATE/join_org.md]
  - Make sure that the list of contributions included is representative of your work on the project
- Have your sponsoring reviewers reply confirmation of sponsorship
- Once your sponsors have responded, your request will be reviewed by the Kubeflow Steering Committee (KSC). Any missing information will be requested
- After your PR is merged, you will get an email (to your GitHub-associated email address) inviting you to the Kubeflow GitHub org. Follow the instructions to accept your membership
- To confirm that the membership acceptance process has completed, you can search for your GitHub username at https://github.com/orgs/kubeflow/people

### Responsibilities & Privileges

- Subscribed to [`kubeflow-discuss` Google group](https://groups.google.com/g/kubeflow-discuss)
- Responsive to issues and PRs assigned to them
- Active participants in the Kubeflow community by participating in:
  - WG Meetings
  - Slack Discussions
  - Project Discussions
- Active owner of code they have contributed (unless ownership is explicitly transferred)
  - Code is well tested and tests pass
  - Addresses bugs or issues discovered after code is accepted
- Members can do `/lgtm` on open PRs
- They can be assigned to issues and PRs, and people can ask members for reviews with a `/cc @username`.
- They are eligible to be appointed as a Kubeflow Community Distribution release managers
- Tests can be run against their PRs automatically. No `/ok-to-test` needed.
- Members can do `/ok-to-test` for PRs, and use commands like `/close` to close PRs/Issues as well.
  A complete list of commands can be found in [the Prow documentation](https://prow.k8s.io/command-help)

> [!NOTE]
> Members who frequently contribute code are expected to proactively perform code reviews and work
> towards becoming a primary _reviewer_ for the Kubeflow subproject that they are active in.

## Reviewer

Reviewers are able to review code for quality and correctness on some part of a Kubeflow subproject.
They are knowledgeable about both the codebase and software engineering principles.

Reviewer status can be scoped to either parts of the codebase or the root directory for
the entire Kubeflow subproject.

**Defined by:** _reviewers_ entry in an `OWNERS` file in a repo owned by the Kubeflow organization.

> [!NOTE]
> Acceptance of code contributions requires at least one approver in addition to the assigned reviewers.

### Requirements

The following apply to the part of codebase for which one would be a reviewer in an `OWNERS` file.

- [Member](#member) for at least 3 months
- Primary reviewer for at least 5 PRs to the codebase
- Reviewed or merged at least 15 substantial PRs to the codebase
- Knowledgeable about the codebase
- Active engagement with the Kubeflow community by answering user questions in GitHub issues and Slack
- Sponsored by a subproject approver
  - With no objections from other approvers, WG leads, or chairs
- May either self-nominate or be nominated by other Kubeflow member

> [!NOTE]
> WG chairs may nominate and approve reviewers that don't meet these requirements due
> to exceptional circumstances. While acceptable in the short term, WG chairs should
> ensure that these reviewers eventually meet the requirements

### Responsibilities & Privileges

- All responsibilities that community members have
- Reviewer status may be a precondition to accepting large code contributions
- Responsible for project quality control via code reviews
  - Focus on code quality and correctness, including testing and refactoring
  - May also review for more holistic issues, but not a requirement
- Expected to be responsive to review requests
- Expected to actively engage with the community by answering questions in GitHub issues and Slack
- Assigned PRs to review related to subproject of expertise
- All Privileges that community members have
- May get a badge on PR and issue comments

## Approver

Approvers are able to both review and approve code contributions. While code review is focused
on code quality and correctness, approval is focused on holistic acceptance of a contribution
including: backwards / forwards compatibility, adhering to API and flag conventions, subtle
performance and correctness issues, integrations with other parts of the system, overall code test
coverage, etc.

Approver status can be scoped to either parts of the codebase or the root directory for the entire codebase.

**Defined by:** _approvers_ entry in an `OWNERS` file in a repo owned by the Kubeflow organization.

### Requirements

The following apply to the part of codebase for which one would be an approver in an `OWNERS` file.

- [Reviewer](#reviewer) for at least 3 months
- Primary reviewer for at least 10 substantial PRs to the codebase
- Reviewed or merged at least 30 PRs to the codebase
- Sponsored by a subproject approver
  - With no objections from other approvers, WG leads, or chairs
- May either self-nominate or be nominated by other Kubeflow member

> [!NOTE]
> WG chairs may nominate and approve approvers that don't meet these requirements due
> to exceptional circumstances. While acceptable in the short term, WG chairs should
> ensure that these approvers eventually meet the requirements

### Responsibilities & Privileges

- All responsibilities that reviewers have
- Demonstrate sound technical judgement
- Responsible for project quality control via code reviews
  - Focus on holistic acceptance of contribution such as dependencies with other features,
    backwards / forwards compatibility, APIs, and feature flag definitions, etc.
- Expected to be responsive to merge requests for pull requests when reviewed
- Mentor contributors and reviewers
- All privileges that reviewers have
- May approve code contributions for acceptance

## WG Lead

WG Lead provides technical leadership for a working group and Kubeflow subprojects they own.

You can find requirements, responsibilities, and privileges in [this governance document](committee-steering/wg-governance.md#asd)

## WG Chair

WG Chairs provide overall leadership for a working group.

You can find requirements, responsibilities, and privileges in [this governance document](committee-steering/wg-governance.md#asd)

## Kubeflow Outreach Committee Member

The Kubeflow Outreach Committee is a committee dedicated to fostering growth, engagement, and
community outreach for the Kubeflow project.

You can find requirements, responsibilities, and privileges in [this charter](committee-outreach/charter.md).

## Kubeflow Distribution Committee Member

You can find requirements, responsibilities, and privileges in [this charter](committee-distribution/charter.md).

## Kubeflow Steering Committee Member

You can find requirements, responsibilities, and privileges in [this charter](committee-steering/charter.md).

## Inactive members

_Kubeflow Community Members are continuously active contributors in the community._

A core principle in maintaining a healthy community is encouraging active participation. It is
inevitable that people's focuses will change over time and they are not expected to be actively
contributing forever.

However, being a member of one of the Kubeflow GitHub organizations comes with an elevated set of
permissions. These capabilities should not be used by those that are not familiar with the current
state of the Kubeflow organization.

Therefore members with an extended period: **1 year** away from the organization with no activity
will be removed from the Kubeflow GitHub Organizations and will be required to go through the org
membership process again after re-familiarizing themselves with the current state.

If anyone listed in `OWNERS` files should become inactive, here is what we will do:

- If the person is in reviewers section, their GitHub id will be removed from the section.
- If the person is in approvers section, their GitHub id will be moved
  [the `emeritus_approvers` section](https://www.kubeflow.org/docs/about/contributing/#emeritus).

### How inactivity is measured

Inactive members are defined as members of one of the Kubeflow Organizations with **no** technical
and non-technical contributions across any organization within **1 year**.

[DevStats](https://kubeflow.devstats.cncf.io/d/66/developer-activity-counts-by-companies?orgId=1&var-period_name=Last%20year&var-metric=contributions&var-repogroup_name=All&var-country_name=All&var-companies=All)
offers an easy way to determine contributions to Kubeflow subprojects.

After an extended period away from the project with no activity those members would need to
re-familiarize themselves with the current state before being able to contribute effectively.

[OWNERS]: https://www.kubeflow.org/docs/about/contributing/#owners-files-and-pr-workflow
[wgs.yaml]: https://github.com/kubeflow/community/blob/master/wgs.yaml
[New contributors]: https://www.kubeflow.org/docs/about/contributing/
[continuously active]: #inactive-members
