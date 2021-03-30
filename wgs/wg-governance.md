# Working Group(WG) Roles and Organizational Governance

This charter adheres to the conventions described in the [Kubeflow Charter doc](wg-charter.md).
It will be updated as needed to meet the current needs of the Kubeflow project.

In order to standardize Working Group efforts, create maximum
transparency, and route contributors to the appropriate WG, WGs should follow
these guidelines:

- Create a charter and have it approved according to the [WG charter process]
- Meet regularly, at least for 30 minutes every 3 weeks, except November and
December
- Keep up-to-date meeting notes, linked from the WG's page in the community
repo
- Record meetings and make them publicly available in Drive
- Report activity with the community via the kubeflow-discuss mailing list at
least once a quarter. Whichever format the WG uses should _always_ be reported
to the kubeflow-discuss mailing list as this is the list the community depends on
for WG updates.    
- Participate in release planning meetings and retrospectives, and burndown
meetings, as needed
- Ensure related work happens in a project-owned github org and repository, with
 code and tests explicitly owned and supported by the WG, including issue
 triage, PR reviews, test-failure response, bug fixes, etc.
- Use the [forums provided] as the primary means of working, communicating, and
collaborating, as opposed to private emails and meetings  
- Ensure contributing instructions (CONTRIBUTING.md) are defined in the WGs
folder located in the kubeflow/community repo if the groups contributor steps
and experience are different or more in-depth than the documentation listed in
the general [contributor guide].  
- Help and sponsor special interest groups(SIGs) that the WG is interested in investing in  
- Track and identify all WG features in the current release

The process for setting up a Working Group (WG) is listed in the
[wg-lifecycle] document.

## Roles

### Notes on Roles

Within this section "Lead" refers to someone who is a member of the union
 of a Chair, Tech Lead or Subproject Owner role. There is no one lead to any
 Kubeflow community group. Leads have specific decision making power over some
 part of a group and thus additional accountability. Each role is detailed below.  

- Initial roles are defined at the founding of the WG or Subproject as part
of the acceptance of that WG or Subproject.

#### Activity Expectations  

- Leads *SHOULD* remain active and responsive in their Roles.
- Leads taking an extended leave of 1 or more months *SHOULD* coordinate with other leads to ensure the role is adequately staffed during the leave.
- Leads going on leave for 1-3 months *MAY* work with other Leads to identify a temporary replacement.
- Leads of a role *SHOULD* remove any other leads or roles that have not communicated a leave of absence and either cannot be reached for more than 1 month or are not fulfilling their documented responsibilities for more than 1 month.
  - This may be done through a [super-majority] vote of Leads. If there are not enough *active* Leads, then a [super-majority] vote between Chairs, Tech Leads and Subproject Owners may decide the removal of the Lead.

#### Requirements

- Leads *MUST* be at least a ["member" on our contributor ladder] to
be eligible to hold a leadership role within a WG.
- WG *MAY* prefer various levels of domain knowledge depending on the
role. This should be documented.  
- People management interests - there's a lot of us!

#### Escalations

- Lead membership disagreements *MAY* be escalated to the WG Chairs. WG Chair
membership disagreements may be escalated to the Steering Committee.

#### On-boarding and Off-boarding Leads

- Leads *MAY* decide to step down at anytime and propose a replacement.  Use
lazy consensus amongst other Leads with fallback on majority vote to accept
proposal.  The candidate *SHOULD* be supported by a majority of WG contributors
 or the Subproject contributors (as applicable).
- Leads *MAY* select additional leads through a [super-majority] vote
amongst leads. This *SHOULD* be supported by a majority of WG contributors or
Subproject contributors (as applicable).

### Chair

- Number: 2-3
- Membership tracked in [wg.yaml]  
  - If no tech lead role is present, Chair assumes responsibilities from [#tech-lead] section.
  
  In addition, run operations and processes governing the WG:

- *SHOULD* define how priorities and commitments are managed and delegate to other leads as needed
- *SHOULD* drive charter changes (including creation) to get community buy-in but *MAY* delegate content creation to WG contributors
- *SHOULD* identify, track, and maintain the WGs enhancements for current
  release and serve as point of contact for the release team, but *MAY* delegate
   to another Lead to fulfill these responsibilities
  - *MAY* delegate the creation of a WG roadmap to other Leads
  - *MUST* organize a main group meeting and make sure [wg.yaml] is up to date
  including subprojects and their meeting information but *SHOULD* delegate the
  need for subproject meetings to subproject owners  
  - *SHOULD* facilitate meetings but *MAY* delegate to other Leads or future
  chairs/chairs in training
  - *MUST* ensure there is a maintained CONTRIBUTING.md document in the
  appropriate WG folder if the contributor experience or on-boarding knowledge
  is different than in the general [contributor guide]. *MAY* delegate to
  contributors to create or update.
  - *MUST* ensure meetings are recorded and made available
  - *MUST* report activity with the community via kubeflow-discuss mailing list at least
  once a quarter (slides, video from kubecon, etc)
  - *MUST* coordinate sponsored SIG updates to the WG and the wider
  community  
- *MUST* coordinate communication and be a connector with other community
 groups like WGs and the Steering Committee but *MAY* delegate the actual
 communication and creation of content to other contributors where
 appropriate  
- *MUST* provide quarterly updates through our community channels: twice a year
to Kubeflow-discuss@googlegroups.com mailing list and twice a year presenting at
the weekly community meeting  

### Tech Lead

- *Optional Role*: WG Technical Leads
  - Establish new subprojects
  - Decommission existing subprojects
  - Resolve X-Subproject technical issues and decisions
  - Number: 2-3
  - Membership tracked in [wg.yaml]

### Subproject Owner

- Subproject Owners
  - Scoped to a subproject defined in [wg.yaml]
  - Seed leads and contributors established at subproject founding
  - *SHOULD* be an escalation point for technical discussions and decisions in
  the subproject
  - *SHOULD* set milestone priorities or delegate this responsibility
  - Number: 2-3
  - Membership tracked in [wg.yaml]

### All Leads

- *SHOULD* maintain health of at least one subproject or the health of the WG
- *SHOULD* show sustained contributions to at least one subproject or to the
  WG
- *SHOULD* hold some documented role or responsibility in the WG and / or at
  least one subproject
    (e.g. reviewer, approver, etc)
- *MAY* build new functionality for subprojects
- *MAY* participate in decision making for the subprojects they hold roles in
- Includes all reviewers and approvers in [OWNERS] files for subprojects


#### Subproject Creation

---

Option 1: by WG Technical Leads

- Subprojects may be created by Kubeflow proposal and accepted by [lazy-consensus] with fallback on majority vote of
  WG Technical Leads.  The result *SHOULD* be supported by the majority of WG Leads.
  - Proposal *MUST* establish subproject owners
  - [wg.yaml] *MUST* be updated to include subproject information and [OWNERS] files with subproject owners
  - Where subprojects processes differ from the WG governance, they must document how
    - e.g. if subprojects release separately - they must document how release and planning is performed

Option 2: by Federation of Subprojects

- Subprojects may be created by Kubeflow proposal and accepted by [lazy-consensus] with fallback on majority vote of
  subproject owners in the WG.  The result *SHOULD* be supported by the majority of leads.
  - Kubeflow proposal *MUST* establish subproject owners
  - [wg.yaml] *MUST* be updated to include subproject information and [OWNERS] files with subproject owners
  - Where subprojects processes differ from the WG governance, they must document how
    - e.g. if subprojects release separately - they must document how release and planning is performed

---

- Subprojects must define how releases are performed and milestones are set.  Example:

> - Release milestones
>   - Follows the Kubeflow/Kubeflow release milestones and schedule
>   - Priorities for upcoming release are discussed during the WG meeting following the preceding release and shared through a PR. Priorities are finalized before feature freeze.
> - Code and artifacts are published as part of the Kubeflow/Kubeflow release

### Technical processes

Subprojects of the WG *MUST* use the following processes unless explicitly following alternatives
they have defined.

- Proposing and making decisions
  - Proposals sent as [KEP] PRs and published to googlegroup as announcement
  - Follow [KEP] decision making process

- Test health
  - Canonical health of code.
  - Consistently broken tests automatically send an alert to their google group.
  - WG contributors are responsible for responding to broken tests alert. PRs that break tests should be rolled back if not fixed within 24 hours (business hours).
  - Test dashboard checked and reviewed at start of each WG meeting.  Owners assigned for any broken tests and followed up during the next WG meeting.

Issues impacting multiple subprojects in the WG should be resolved by either:

- Option 1: WG Technical Leads
- Option 2: Federation of Subproject Owners

### WG Retirement

- In the event that the WG is unable to regularly establish consistent quorum
  or otherwise fulfill its Organizational Management responsibilities
  - after 3 or more months it *SHOULD* be retired
  - after 6 or more months it *MUST* be retired

[k/enhancements]: https://github.com/kubeflow/community/tree/master/proposals
[forums provided]: /communication/README.md
[lazy-consensus]: http://en.osswiki.info/concepts/lazy_consensus
[super-majority]: https://en.wikipedia.org/wiki/Supermajority#Two-thirds_vote
[KEP]: https://github.com/kubeflow/community/blob/master/proposals/TEMPLATE.md
[wgs.yaml]: templates/wgs.yaml
[WG Charter process]: /wg-charter.md
[Kubeflow Charter README]: /wg-charter.md
[wg-lifecycle]: /sig-wg-lifecycle.md
["member" on our contributor ladder]: https://docs.google.com/document/d/1HKB662Ju6URVdzw0Neq9OFnxM6RMXFu4Dd04q9E3kGk/edit#heading=h.5p9yntdhi7yr
[contributor guide]: https://www.kubeflow.org/docs/about/contributing/
[Google group]: https://groups.google.com/forum/#!forum/kubeflow-discuss
[dashboard]: https://k8s-testgrid.appspot.com/sig-big-data
