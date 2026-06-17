# Kubeflow Working Group Governance

This document defines the requirements, roles, lifecycle, and charter process of
Kubeflow Working Groups (WGs). A major pillar of the Kubeflow's governance model is WGs.

Every Kubeflow subproject _MUST_ be owned by a WG, as defined in the [wgs.yaml].

Each WG defines a [charter](#wg-charter) that links to this document as the default
governance.

## Working Group Requirements

In order to standardize WG efforts, create maximum transparency, and route contributors to the
appropriate WG, WGs _SHOULD_ follow these guidelines:

- Create a charter and have it approved according to the [WG charter process](#wg-charter).
- Meet regularly across WG and subproject discussions
- Record meetings and make them publicly available in [the YouTube channel](https://www.youtube.com/@KubeflowCommunity).
- Keep up-to-date meeting notes, linked from the WG's page in the community repo.
- Report activity with the community via [the `kubeflow-discuss`](https://groups.google.com/g/kubeflow-discuss)
  mailing list at least once a quarter.
- Participate in Kubeflow Community Distribution release planning meetings and retrospectives
- Ensure related work happens in a Kubeflow subprojects, with code and tests explicitly owned and
  supported by the WG, including issue triage, PR reviews, bug fixes, etc.
- Ensure `CONTRIBUTING.md` instructions are defined in the subprojects repositories with the reference
  to the main [Kubeflow contributing guide](https://www.kubeflow.org/docs/about/contributing/)

## WG Structure

Kubeflow WGs are composed of several Chairs.

### WG Chairs

WG Chairs provide overall leadership for a WG. They are responsible for running operations and
processes governing the WG.

WG Chair membership disagreements may be escalated to the Kubeflow Steering Committee.

- Number: 2+
- Membership tracked in [wgs.yaml]

#### Requirements

- _MUST_ be at least a [Member](../community-membership.md#member) on the contributor ladder
- _SHOULD_ hold some documented role in at least one subproject (e.g. reviewer or approver)
- _SHOULD_ have sustained contributions to at least one subproject
- _SHOULD_ have sufficient domain knowledge to provide effective technical leadership
- Sponsored by a Kubeflow member and supported by [super-majority] vote of chairs.

#### Responsibilities & Privileges

- Remain active and responsive in their roles
- Establish new subprojects within the WG
- Decommission existing subprojects
- Resolve cross-subproject technical issues and decisions
- Vote on changes to the WG charter
- Provide yearly updates to the `kubeflow-discuss` mailing list and the community meeting.
- Chairs _SHOULD_ remove any other Chairs that have not communicated a leave of absence
  and either cannot be reached for more than 1 year or are not fulfilling their documented
  responsibilities for more than 1 year.
  - This may be done through a [super-majority] vote of Chairs.
- Have write access to the Kubeflow subprojects

## Subprojects

### Subproject Creation

- Subprojects may be created by [Kubeflow Enhancement Proposal](../proposals) and accepted by
  [lazy-consensus] with fallback on majority vote of the WG Chairs. The result _SHOULD_ be supported by the
  majority of WG Chairs.
  - The proposal _MUST_ establish the subproject's reviewers and approvers.
  - [wgs.yaml] _MUST_ be updated to include subproject information and [OWNERS] files with
    the subproject's reviewers and approvers.
- Once subprojects are approved, [similar steps](../subprojects/README.md#-migration-checklist)
  _SHOULD_ be completed to create a new project.

### Technical Processes

Subprojects of the WG _MUST_ use the following processes:

- Follow the [Kubeflow Enhancement Proposal](../proposals) process to propose large feature requests
- Maintain workable CI/CD

## WG Lifecycle

This section covers the creation and retirement of a WG. Subproject creation is
covered under [Subprojects](#subprojects).

### Creation

Follow these steps to propose a new WG:

- [ ] Read this governance document.
- [ ] Ensure all WG chairs are [community members](../community-membership.md).
- [ ] Send an email to the `kubeflow-discuss` mailing list to scope the WG and get provisional approval.
- [ ] Follow the [WG charter process](#wg-charter) to propose and obtain approval for a
      charter.
- [ ] Submit a PR that adds rows to [wgs.yaml] and run `make generate` to autogenerate docs. You'll need:
  - WG Name
  - Mission Statement
  - Charter
  - Chairs information
  - Subproject list
  - Meeting information
  - Slack channels
  - GitHub teams
- [ ] If WG is approved, coordinate with Kubeflow Outreach Team to announce it

### WG Charter

All Kubeflow WGs must define a charter defining the scope and governance of the WG.

- The scope must define what areas the WG is responsible for directing and maintaining
- The governance must outline the responsibilities within the WG as well as the roles
  owning those responsibilities

1. Copy [the template](wg-charter-template.md) into a new file under
   `community/wg-*YOURWG*/charter.md` ([example](/wg-training/charter.md)) and fill out template
1. Update [wgs.yaml] with the individuals holding the roles as defined in the template
1. Add subprojects owned by your WG in [wgs.yaml]
1. Create a pull request with a draft of your charter.md and wgs.yaml changes. Communicate
   it within your WG and get feedback as needed.
1. Send the WG Charter out for review to steering@kubeflow.org. Include the subject "WG
   Charter Proposal: YOURWG" and a link to the PR in the body.
1. Typically expect feedback within a week of sending your draft. Expect a longer time if
   it falls over an event such as KubeCon/CloudNativeCon or holidays. Make any necessary
   changes.
1. Once accepted, the steering committee will ratify the PR by merging it.

#### Steps to Update an Existing WG Charter

- For significant changes, or any changes that could impact other WGs (such as the scope),
  create a PR and send it to the Kubeflow Steering Committee for review.
- For minor updates that only impact issues or areas within the scope of the WG, the WG
  Chairs _SHOULD_ facilitate the change.

### Retirement

Sometimes it might be necessary to sunset a WG, either by disbandment or by
merging with an existing WG when deemed appropriate (which can save project overhead
in the long run).

A WG should be retired when it is unable to regularly establish consistent quorum or
otherwise fulfill its organizational management responsibilities:

- after 3 or more months it _SHOULD_ be retired;
- after 6 or more months it _MUST_ be retired.

A WG may also be retired once it has completed its mission.

#### Retirement Steps

- [ ] Send an email to `kubeflow-discuss` mailing list alerting the community of your
      intentions to disband or merge.
- [ ] Move the existing WG directory into the archive in `kubeflow/community`.
- [ ] Kubeflow subprojects transactions:
  - [ ] Each subproject a WG owns must transfer ownership to a new WG, transfer project outside of
        Kubeflow org, or be archived.
  - [ ] Remove [all GitHub teams](https://github.com/kubeflow/internal-acls/blob/master/github-orgs/kubeflow/org.yaml)
        that refer to the WG.
  - [ ] Update [wgs.yaml] to remove WG.

## Changes to the WG Governance

Changes to the WG Governance may be proposed through a Pull Requests on this document by a
Kubeflow community member.

Amendments are accepted following the Kubeflow Steering Committee's [Normal Decision Process](../committee-steering/charter.md#normal-decision-process).

Proposals and amendments to the application process are available for at least a period of one week for comments and questions before a vote will occur.

[wgs.yaml]: /wgs.yaml
[super-majority]: https://en.wikipedia.org/wiki/Supermajority#Two-thirds_vote
[lazy-consensus]: http://en.osswiki.info/concepts/lazy_consensus
[OWNERS]: https://www.kubeflow.org/docs/about/contributing/#owners
