# Kubeflow Working Group Governance

This document defines the roles, organizational governance, charter process, and lifecycle of
Kubeflow Working Groups (WGs). A major pillar of the Kubeflow's governance model is WGs.

Every Kubeflow subproject MUST be owned by a WG, as defined in the [wgs.yaml].

Each WG defines a [charter](#wg-charter) that links to this document as the default
governance. A WG MAY record deviations from these defaults in its own charter.

## Operating Requirements

In order to standardize WG efforts, create maximum transparency, and route contributors to the
appropriate WG, WGs SHOULD follow these guidelines:

- Create a charter and have it approved according to the [WG charter process](#wg-charter).
- Meet regularly across working group or subproject discussions
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

Kubeflow WGs are composed of several leads.

### WG Leads

WG Lead provides technical leadership for a working group and Kubeflow subprojects they own. This is
an optional role – if not present, WG chairs assume these responsibilities.

- Number: 2+
- Membership tracked in [wgs.yaml]

#### Requirements

- MUST be at least a [Member](../community-membership.md#member) on the contributor ladder
- SHOULD hold some documented role in at least one subproject (e.g. reviewer or approver)
- SHOULD should sustained contributions to at least one subproject
- Have sufficient domain knowledge to provide effective technical leadership
- Sponsored by a Kubeflow member and supported by [super-majority] vote of chairs.

#### Responsibilities & Privileges

- Remain active and responsive in their roles
- When taking an extended leave of 1 or more months leads SHOULD coordinate with other leads and chairs
  to ensure the role is adequately staffed during the leave.
- Establish new subprojects within the WG
- Decommission existing subprojects
- Have write access to the Kubeflow subprojects

### WG Chairs

WG Chairs provide overall leadership for a WG. They are responsible for running operations and
processes governing the WG.

- Number: 2+
- Membership tracked in [wgs.yaml]

#### Requirements

- All requirements that WG leads have
- Sponsored by a Kubeflow member and supported by [super-majority] vote of chairs.

#### Responsibilities & Privileges

- All responsibilities that WG leads have
- Establish new subprojects
- Decommission existing subprojects
- Resolve cross-subproject technical issues and decisions
- Vote on changes to the WG charter
- Provide yearly updates to the `kubeflow-discuss` mailing list and the community meeting.
- Chairs SHOULD remove any other lead or chair roles that have not communicated a leave of absence
  and either cannot be reached for more than 1 month or are not fulfilling their documented
  responsibilities for more than 1 month.
  - This may be done through a [super-majority] vote of chairs.

### Escalations

- WG Leads membership disagreements MAY be escalated to the WG Chairs. WG Chair membership
  disagreements may be escalated to the Kubeflow Steering Committee.

## Subprojects

### Subproject Creation

- Subprojects may be created by [Kubeflow Enhancement Proposal](proposals) and accepted by
  [lazy-consensus] with fallback on majority vote of the WG Chairs. The result SHOULD be supported by the
  majority of WG Leads.
  - The proposal MUST establish the subproject's reviewers and approvers.
  - [wgs.yaml] MUST be updated to include subproject information and [OWNERS] files with
    the subproject's reviewers and approvers.
- Once subprojects are approved, [similar steps](../subprojects/README.md#-migration-checklist)
  SHOULD be completed to create a new project.

### Technical Processes

Subprojects of the WG MUST use the following processes:

- Follow the [Kubeflow Enhancement Proposal](../proposals) process to propose large feature requests
- Maintain workable CI/CD

## WG Lifecycle

This section covers the creation and retirement of a working group. Subproject creation is
covered under [Subprojects](#subprojects).

### Creation

### Prerequisites for a WG

- [ ] Read this governance document.
- [ ] Ensure all WG chairs and leads are [community members](../community-membership.md).
- [ ] Send an email to the `kubeflow-discuss` mailing list to scope the WG and get provisional approval.
- [ ] Follow the [WG charter process](#wg-charter) to propose and obtain approval for a
      charter.
- [ ] Coordinate with Kubeflow Outreach Team to announce creation of WG

### WG Charter

All Kubeflow WGs must define a charter defining the scope and governance of the WG.

- The scope must define what areas the WG is responsible for directing and maintaining
- The governance must outline the responsibilities within the WG as well as the roles
  owning those responsibilities

1. Copy [the template](wg-charter-template.md) into a new file under
   `community/wg-*YOURWG*/charter.md` ([example](/wg-training/charter.md)) and fill out template
1. Read the [Governance Requirements](#governance-requirements) so you have context for the
   template
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

### Steps to Update an Existing WG Charter

- For significant changes, or any changes that could impact other WGs (such as the scope),
  create a PR and send it to the Kubeflow Steering Committee for review.
- For minor updates that only impact issues or areas within the scope of the WG, the WG
  Chairs SHOULD facilitate the change.

### Creation

#### GitHub

- Submit a PR that:
  - adds rows to [wgs.yaml]
  - runs `make generate` to autogenerate docs
- You'll need:
  - WG Name
  - Charter
  - Directory URL
  - Mission Statement
  - Chair Information
  - Meeting Information
  - Contact Methods
  - Any Subproject Stakeholders

### Retirement

Sometimes it might be necessary to sunset a Working Group, either by disbandment or by
merging with an existing WG when deemed appropriate (which can save project overhead
in the long run).

A WG should be retired when it is unable to regularly establish consistent quorum or
otherwise fulfill its organizational management responsibilities:

- after 3 or more months it _SHOULD_ be retired;
- after 6 or more months it _MUST_ be retired.

A WG may also be retired once it has completed its mission.

#### Retirement Steps

- [ ] Send an email to `kubeflow-discuss` Google group alerting the community of your
      intentions to disband or merge.
- [ ] Move the existing WG directory into the archive in `kubeflow/community`.
- [ ] Kubeflow subprojects transactions:
  - [ ] Each subproject a WG owns must transfer ownership to a new WG, transfer project outside of
        Kubeflow org, or be archived.l.
  - [ ] Remove [all GitHub teams](https://github.com/kubeflow/internal-acls/blob/master/github-orgs/kubeflow/org.yaml)
        that refer to the WG.
  - [ ] Update [wgs.yaml] to remove WG.

[wgs.yaml]: /wgs.yaml
[super-majority]: https://en.wikipedia.org/wiki/Supermajority#Two-thirds_vote
