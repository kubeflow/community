# Community membership

**Note:** This document is in progress

This doc outlines the various responsibilities of contributor roles in
Kubernetes.  The Kubernetes project is subdivided into subprojects under WGs.
Responsibilities for most roles are scoped to these subprojects.

| Role | Responsibilities | Requirements | Defined by |
| -----| ---------------- | ------------ | -------|
| Member | Active contributor in the community | Sponsored by 2 reviewers.  Multiple contributions to the project. | GitHub org member. |
| Scribe | Ensure important information is represented in working group notes | Membership | Write access to WG documentation | 
| Reviewer | Review contributions from other members | History of review and authorship in a subproject | [OWNERS] file reviewer entry. |
| Approver | Approve accepting contributions | Hghly experienced and active reviewer | [OWNERS] file approver entry|
| Working Group Technical Lead | Set priorities for a functional area and approve proposals | ? | [wgs.yaml] subproject [OWNERS] file *OWNERS* entry |
| Working Group Co-chair | Run their working group: meetings, notes, roadmap, report | ? | [wgs.yaml] subproject [OWNERS] file *OWNERS* entry | 

## New contributors

[New contributors] should be welcomed to the community by existing members,
helped with PR workflow, and directed to relevant documentation and
communication channels.

## Established community members

Established community members are expected to demonstrate their adherence to the
principles in this document, familiarity with project organization, roles,
policies, procedures, conventions, etc., and technical and/or writing ability.
Role-specific expectations, responsibilities, and requirements are enumerated
below.

## Member

Members are continuously active contributors in the community.  They can have
issues and PRs assigned to them, participate in WGs through GitHub teams, and
pre-submit tests are automatically run for their PRs. 
Members are expected to remain active contributors to the community.

All members are encouraged to help with the code review burden, although each PR
must be reviewed by an official [Approver](#approver).

When reviewing, members should focus on code quality and correctness, including
testing and factoring. 
Members might also review for more holistic issues, but this is not a requirement.

**Defined by:** Member of the Kubeflow GitHub organization

### Requirements

- Enabled [two-factor authentication] on their GitHub account
- Have made multiple contributions to the project or community.  Contribution may include, but is not limited to:
    - Authoring or reviewing PRs on GitHub
    - Filing or commenting on issues on GitHub
    - Contributing to WG, subproject, or community discussions (e.g. meetings, Slack, email discussion forums, Stack Overflow, etc)
- Subscribed to [Kubeflow-dev@googlegroups.com]
- Have read the [contributor guide]
- Actively contributing to 1 or more subprojects.
- Sponsored by 2 reviewers. **Note the following requirements for sponsors**:
    - Sponsors must have close interactions with the prospective member - e.g. code/design/proposal review, coordinating on issues, etc.
    - Sponsors must be reviewers or approvers in at least 1 OWNERS file either in any repo in the [Kubeflow org],          
- **[Open an issue][membership request] against the Kubeflow/internal-acls repo**
   - Ensure your sponsors are @mentioned on the issue
   - Complete every item on the checklist ([preview the current version of the template][membership template])
   - Make sure that the list of contributions included is representative of your work on the project.
- Have your sponsoring reviewers reply confirmation of sponsorship: `+1`
- Once your sponsors have responded, your request will be reviewed by the [Kubeflow GitHub Admin team]. Any missing information will be requested.


### Responsibilities and privileges

- Responsive to issues and PRs assigned to them.
- Responsive to mentions of WG teams they are members of. 
- Active owner of code they have contributed (unless ownership is explicitly transferred)
  - Code is well tested
  - Tests consistently pass
  - Addresses bugs or issues discovered after code is accepted
- Members can do `/lgtm` on open PRs.
- They can be assigned to issues and PRs, and people can ask members for reviews with a `/cc @username`.
- Tests can be run against their PRs automatically. No `/ok-to-test` needed.
- Members can do `/ok-to-test` for PRs that have a `needs-ok-to-test` label, and use commands like `/close` to close PRs as well.

**Note:** members who frequently contribute code are expected to proactively
perform code reviews and work towards becoming a primary *reviewer* for the
subproject that they are active in.

## Scribe

One of the most underrated roles in open source projects is the role of note
taker. 
The importance and value of this role is frequently overlooked and
underestimated. 
Since one of the core project values is transparency, we have an explicit scribe role to recognize these types of contributions. 
Working group scribes assist the Working Group leads with the mechanical processes around
Working Group meetings.

### Requirements

- Participant in the working group for at least 1 month.
- Pattern of attendance and note-taking during working group meetings and one-offs.
- Sponsored by a working group execution or technical lead.

### Responsibilities and privileges

- Attend working group meetings and one-offs whenever possible.
- Ensure that important information from meetings makes it into the WG notes.
- Post WG recordings to the team drive.

## Reviewer

Reviewers are able to review code for quality and correctness on some part of a
subproject. They are knowledgeable about both the codebase and software
engineering principles.

**Defined by:** *reviewers* entry in an OWNERS file in a repo owned by the
Kubeflow project.

Reviewer status is scoped to a part of the codebase.

**Note:** Acceptance of code contributions requires at least one approver in
addition to the assigned reviewers.

### Requirements

The following apply to the part of codebase for which one would be a reviewer in
an [OWNERS] file (for repos using the bot).

- member for at least 3 months
- Primary reviewer for at least 5 PRs to the codebase
- Reviewed or merged at least 20 substantial PRs to the codebase
- Knowledgeable about the codebase
- Sponsored by a subproject approver
  - With no objections from other approvers
  - Done through PR to update the OWNERS file
- May either self-nominate, be nominated by an approver in this subproject, or be nominated by a robot

### Responsibilities and privileges

The following apply to the part of codebase for which one would be a reviewer in
an [OWNERS] file (for repos using the bot).

- Tests are automatically run for PullRequests from members of the Kubeflow GitHub organization
- Code reviewer status may be a precondition to accepting large code contributions
- Responsible for project quality control via [code reviews]
  - Focus on code quality and correctness, including testing and factoring
  - May also review for more holistic issues, but not a requirement
- Expected to be responsive to review requests
- Assigned PRs to review related to subproject of expertise
- Assigned test bugs related to subproject of expertise
- Granted "read access" to Kubeflow repo
- May get a badge on PR and issue comments

## Approver

Code approvers are able to both review and approve code contributions.  While
code review is focused on code quality and correctness, approval is focused on
holistic acceptance of a contribution including: backwards / forwards
compatibility, adhering to API and flag conventions, subtle performance and
correctness issues, interactions with other parts of the system, etc.

**Defined by:** *approvers* entry in an OWNERS file in a repo owned by the
Kubeflow project.

Approver status is scoped to a part of the codebase.

### Requirements

The following apply to the part of codebase for which one would be an approver
in an [OWNERS] file (for repos using the bot).

- Reviewer of the codebase for at least 3 months
- Primary reviewer for at least 10 substantial PRs to the codebase
- Reviewed or merged at least 30 PRs to the codebase
- Nominated by a subproject owner
  - With no objections from other subproject owners
  - Done through PR to update the top-level OWNERS file

### Responsibilities and privileges

The following apply to the part of codebase for which one would be an approver
in an [OWNERS] file (for repos using the bot).

- Approver status may be a precondition to accepting large code contributions
- Demonstrate sound technical judgement
- Responsible for project quality control via [code reviews]
  - Focus on holistic acceptance of contribution such as dependencies with other features, backwards / forwards
    compatibility, API and flag definitions, etc
- Expected to be responsive to review requests as per [community expectations]
- Mentor contributors and reviewers
- May approve code contributions for acceptance

# Leadership Roles

## Working Group Technical Lead

Working group technical leads, or just ‘tech leads’, are approvers of an entire
area that have demonstrated good judgement and responsibility. 
Tech leads accept design proposals and approve design decisions for their area of ownership, and are responsible for the overall technical health of their functional area.

### Requirements

Getting to be a tech lead of an existing working group:

- Recognized as having expertise in the group’s subject matter.
- Approver for a relevant part of the codebase for at least 3 months.
- Member for at least 6 months.
- Primary reviewer for 20 substantial PRs.
- Reviewed or merged at least 50 PRs.
- Sponsored by the technical oversight committee.

Additional requirements for leads of a new working group:

- Originally authored or contributed major functionality to the group's area.

### Responsibilities and privileges

The following apply to the area / component for which one would be an owner.

- Design/proposal approval authority over the area / component, though
  escalation to the technical oversight committee is possible.
- Technical review of new features and design proposals
- Perform issue triage on GitHub.
- Apply/remove/create/delete GitHub labels and milestones.
- Write access to repo (assign issues/PRs, add/remove labels and milestones,
  edit issues and PRs, edit wiki, create/delete labels and milestones).
- Capable of directly applying lgtm + approve labels for any PR.
  - Expected to respect OWNERS files approvals and use
    standard procedure for merging code..
- Expected to work to holistically maintain the health of the project through:
  - Reviewing PRs.
  - Fixing bugs.
  - Identifying needed enhancements / areas for improvement / etc.
  - Execute pay-down of technical debt.
- Mentoring and guiding approvers, members, and new contributors.

## Working Group Co-Chair

Working Group co-chairs, or just ‘co-chairs’, are responsible for
the overall health and execution of the working group itself. 
Co-chairs work with tech leads to ensure that the working group is making progress toward
its goals, is aligned with the project roadmap, etc. 
The co-chair may also be the tech lead in a smaller working group, but they are distinct roles.

### Requirements

- Participant in the working group for at least 3 months, for example as scribe
  or approver.
- Recognized as having expertise in the group’s subject matter.
- Sponsored by the technical oversight committee.

### Responsibilities and privileges

- Run their working group as explained in the
  [Working Group Processes](./mechanics/WORKING-GROUP-PROCESSES.md).
  - Meetings. Prepare the agenda and run the regular working group meetings.
  - Notes. Ensure that meeting notes are kept up to date. Provide a link to the
    recorded meeting in the notes. The lead may delegate note-taking duties to
    the scribe.
  - Roadmap. Establish and maintain a roadmap for the working group outlining
    the areas of focus for the working group over the next 6 months.
  - Report. Report current status to the TOC meeting every 6 weeks.
- Holistic responsibility for their working group's [feature
  tracks](./mechanics/FEATURE-TRACKS.md): tracking, health, and execution.
- Perform issue triage on GitHub.
- Apply/remove/create/delete GitHub labels and milestones.
- Write access to repo (assign issues/PRs, add/remove labels and milestones,
  edit project, issues, and PRs, edit wiki, create/delete labels and milestones).
- Expected to work to holistically maintain the health of the working through:
  - Being a good role model
  - Be an advocate for the working group inside and outside of the community
  - Foster a welcoming and collegial environment
  - Mentoring and guiding approvers, members, and new contributors.

[code reviews]: https://github.com/kubernetes/community/blob/master//contributors/guide/expectations.md#code-review
[community expectations]: https://github.com/kubernetes/community/blob/master/contributors/guide/expectations.md
[contributor guide]: https://www.kubeflow.org/docs/about/contributing/
[Kubeflow org]: https://github.com/kubeflow
[membership request]: https://github.com/kubeflow/internal-acls/issues/new?template=join_org.md&title=REQUEST%3A%20New%20membership%20for%20%3Cyour-GH-handle%3E
[membership template]: https://github.com/kubeflow/internal-acls/blob/master/.github/ISSUE_TEMPLATE/join_org.md
[New contributors]: https://www.kubeflow.org/docs/about/contributing/
[OWNERS]: https://github.com/kubernetes/community/blob/master/contributors/guide/owners.md
[wgs.yaml]: templates/wgs.yaml
[two-factor authentication]: https://help.github.com/articles/about-two-factor-authentication
