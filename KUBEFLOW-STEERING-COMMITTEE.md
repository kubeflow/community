# Kubeflow Steering Committee

The Kubeflow Steering Committee (KSC) is the governing body of the Kubeflow project, providing decision-making and oversight pertaining to the Kubeflow project policies, sub-organizations, and financial planning, and defines the project values and structure.

The governance of Kubeflow is an open, living document, and will continue to evolve as the community and project change.

### Charter

1. Define, evolve, and promote the vision, values, and mission of the Kubeflow project.
1. Define and evolve project and group governance structures and policies, including election rules, working group policies, and project roles.
1. Steward, control access, delegate access, and establish processes regarding all Kubeflow project resources and have the final say in the disposition of those resources.
1. Define and evolve the scope of the Kubeflow community, including acceptance of new projects into Kubeflow.
1. Define Kubeflow trademark policy and conformance criteria.
1. Receive and handle reports about code of conduct violations and maintain confidentiality.
1. Act as the final escalation point and arbitrator for any disputes, issues, clarifications, or escalations within the project scope.

## Committee Meetings

KSC currently meets at least bi-weekly, or as-needed. Meetings are open to the public and held online, unless they pertain to sensitive or privileged matters. Examples of such matters are:

- Privacy related issues
- Private emails to the committee
- Code of conduct violations
- Certain Escalations
- Disputes between members
- Security reports

Meeting notes are available to members of the kubeflow-discuss mailing list, unless community member privacy requires otherwise. Public meetings will be recorded and the recordings made available publicly.

Questions and proposals for changes to governance are posted as issues in the kubeflow/community repo, and the KSC invites your feedback there. See [Getting in touch](#getting-in-touch) for other options.

## Committee members

KSC is composed of 5 (five) members. They are elected according to [the election policy](elections/kubeflow-steering-committee-elections-2024.md)/
Seats on the Steering Committee are held by an individual, not by their employer.

The current membership of the committee is (listed alphabetically by first name):

| Name                | Organization         | GitHub                                                           | Term Start | Term End   |
| ------------------- | -------------------- | ---------------------------------------------------------------- | ---------- | ---------- |
| Andrey Velichkevich | Apple                | [andreyvelich](https://github.com/andreyvelich/)                 | 02/01/2024 | 02/01/2026 |
| Francisco Arceo     | Red Hat              | [franciscojavierarceo](https://github.com/franciscojavierarceo/) | 02/01/2025 | 02/01/2027 |
| Johnu George        | Nutanix              | [johnugeorge](https://github.com/johnugeorge/)                   | 02/01/2024 | 02/01/2026 |
| Julius von Kohout   | DHL Data & Analytics | [juliusvonkohout](https://github.com/juliusvonkohout/)           | 02/01/2025 | 02/01/2027 |
| Yuan Tang           | Red Hat              | [terrytangyuan](https://github.com/terrytangyuan/)               | 02/01/2024 | 02/01/2026 |

## Emeritus Committee Members

| Name        | Organization | GitHub                                     | Term Start | Term End   |
| ----------- | ------------ | ------------------------------------------ | ---------- | ---------- |
| Josh Bottum | Independent  | [jbottum](https://github.com/jbottum/)     | 02/01/2024 | 02/01/2025 |
| James Wu    | Google       | [james-jwu](https://github.com/james-jwu/) | 02/01/2024 | 02/01/2025 |

## Ownership Transfer

KSC members hold administrative ownership of Kubeflow assets. When new members of the KSC are elected,
a GitHub issue must be created to facilitate the transfer to the incoming members.

GitHub issue name: Transfer Ownership to KSC 2025

GitHub issue content:

- [ ] Update this document with the new members and emeritus members.
- [ ] Archive the current Slack channel (e.g. `#archived-ksc-2024`) and create the new Slack channel (e.g. `kubeflow-steering-committee`).
- [ ] Schedule weekly calls with the new members.
- [ ] Update [admins for Kubeflow GitHub org](https://github.com/kubeflow/internal-acls/blob/master/github-orgs/kubeflow/org.yaml#L7).
- [ ] Update the [`kubeflow-steering-committee` GitHub team](https://github.com/kubeflow/internal-acls/blob/master/github-orgs/kubeflow/org.yaml).
- [ ] Update approvers for the following OWNERS files (e.g the past members should be moved to `emeritus_approvers`):
  - `kubeflow/kubeflow` [OWNERS file](https://github.com/kubeflow/kubeflow/blob/master/OWNERS).
  - `kubeflow/community` [OWNERS file](https://github.com/kubeflow/community/blob/master/OWNERS).
  - `kubeflow/internal-acls` [OWNERS file](https://github.com/kubeflow/internal-acls/blob/master/OWNERS).
  - `kubeflow/website` [OWNERS file](https://github.com/kubeflow/website/blob/master/OWNERS).
  - `kubeflow/blog` [OWNERS file](https://github.com/kubeflow/blog/blob/master/OWNERS).
- [ ] Kubeflow [Google Group](https://groups.google.com/g/kubeflow-discuss).
- [ ] Kubeflow GCP projects under `kubeflow.org` for calendar, ACL, DNS management.
- [ ] Access to Kubeflow 1password account.
- [ ] Kubeflow social media resources.
  - Kubeflow [LinkedIn](https://www.linkedin.com/company/kubeflow/)
  - Kubeflow [Twitter](https://x.com/kubeflow).
  - Kubeflow [BlueSky](https://bsky.app/profile/kubefloworg.bsky.social).
  - [Kubeflow Community](https://www.youtube.com/@KubeflowCommunity) YouTube channel.
  - [Kubeflow](https://www.youtube.com/@Kubeflow) YouTube channel.

## Decision process

The steering committee desires to always reach consensus.

### Normal decision process

Decisions requiring a vote include:

- Issuing written policy
- Amending existing written policy
- Accepting, or removing a Kubeflow component
- Creating, removing, or modifying a working group
- All spending, hiring, and contracting decisions
- Official responses to publicly raised issues
- Any other decisions that at least half of the members (rounded down) present decide require a vote

Decisions are made in meetings when a quorum of the members are present and may pass with at least half the members (rounded up) of the committee supporting it.

Quorum is considered reached when at least half of the members (rounded up) are present.  
Members of KSC may abstain from a vote. Abstaining members will only be considered as contributing to quorum, in the event that a vote is called in a meeting.

### Special decision process

Issues that impacts the KSC governance requires a special decision process. Issues include:

- Changes to the KSC charter
- KSC voting rules
- Election rules

The issue may pass with 70% of the members (rounded up) of the committee supporting it.

One organization may cast 1 vote. Votes cast by members from the same organization are equally weighted. Example:

- If KSC is made up of employees from organizations A, A, B, C, D, each vote from organization A is weighted by a factor of 0.5. The total number of votes is 4, and 3 votes (70% rounded up) is required to pass a proposal. This rule is designed to remove organization A's ability to defeat a proposal that is supported by all other KSC members.
- Similarly, if KSC is made up of employees from organizations A, A, B, B, C, the total number of votes is 3, and 2.5 votes is required to pass a proposal.

### Results

The results of the decision process are recorded and made publicly available, unless they pertain to sensitive or privileged matters. The results will include:

- Description of the issue
- Names of members who supported, opposed, and abstained from the vote.

## Getting in touch

There are two ways to raise issues to the steering committee for decision:

1. Emailing the steering committee at `ksc@kubeflow.org`. This is a private discussion list to which all members of the committee have access.
1. Open an issue on a kubeflow/community repository and indicate that you would like attention from the steering committee using GitHub tag `@kubeflow/kubeflow-steering-committee`.

## Changes to the charter

Changes to the KSC charter may be proposed via a PR on the charter itself by a Kubeflow community member. Amendments are accepted following the [Special Decision Process](#special-decision-process) detailed above.

Proposals and amendments to the charter are available for at least a period of one week for comments and questions before a vote will occur.
