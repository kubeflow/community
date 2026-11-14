# KEP-960: Kubeflow Community Badges

**Author:** Akash Jaiswal ([@jaiakash](https://github.com/jaiakash))

**Tracking issue:** [kubeflow/community#960](https://github.com/kubeflow/community/issues/960)

## Summary

Kubeflow values every type of contribution and already recognizes contributors in several ways, such as the [Contributor of the Month](https://www.kubeflow.org/docs/about/contributor-of-the-month/) program and inviting maintainers and contributors to speak at events. This KEP proposes digital badges as an additional form of recognition, giving contributors a new way to showcase their contributions inside and outside the community and encouraging more people to contribute to the project.

As a CNCF Graduated project, Kubeflow can request up to four custom [Credly](https://info.credly.com/) badges per year through the [CNCF hosted tools program](https://contribute.cncf.io/resources/services/hosted-tools/#credly). This KEP uses two of them now and reserves the other two for the future.

## Motivation

[Issue #960](https://github.com/kubeflow/community/issues/960) suggested giving Kubeflow contributors a way to showcase their work beyond their GitHub activity graphs, especially for non-code contributions. Other open source communities already run badge programs for this purpose, for example [Fedora Badges](https://badges.fedoraproject.org/) and CNCF projects such as Linkerd, which issues a "Linkerd Hero" badge through Credly.

The issue originally suggested building a self-hosted badge platform. Using the CNCF-provided Credly service instead gives us the same outcome without building or maintaining new infrastructure, and recipients can share their badges directly on LinkedIn and other professional platforms.

Badges complement the recognition Kubeflow already provides rather than replacing it. Some contributions, such as speaking at events, already have their own recognition through CNCF, so Kubeflow will not issue badges for them to avoid overlap. Instead, the badges focus on roles specific to Kubeflow, starting with Contributor of the Month and Kubeflow mentors.

### Goals

- Add badges as an extra form of recognition alongside existing programs, starting with Contributor of the Month winners and Kubeflow mentors.
- Encourage the community to contribute more by giving contributors something they can share.
- Define a simple and transparent policy for who receives each badge and how it is issued.

### Non-Goals

- Replacing existing recognition, such as the Contributor of the Month program or speaking opportunities.
- Replacing the CNCF guidelines or the CNCF badges that are already provided.

## Proposal

Kubeflow will request the following badges from CNCF:

| Badge | Awarded to | Criteria |
| ----- | ---------- | -------- |
| Kubeflow Contributor of the Month | Each Contributor of the Month winner | Selected through the existing [Contributor of the Month](../../committee-outreach/contributor-month.md) process. |
| Kubeflow Mentor | Mentors of Kubeflow projects in the LFX Mentorship program or Google Summer of Code (GSoC) | The mentor was listed on a Kubeflow LFX or GSoC project and completed the mentorship term. |
| Reserved | To be decided | Pending. The slot will be defined in the future by amending this KEP. |
| Reserved | To be decided | Pending. |

## Design Details

### Ownership

The [Kubeflow Outreach Committee (KOC)](../../committee-outreach/README.md) owns the badge program. KOC members are responsible for:

- requesting the badges from CNCF staff each year through the [CNCF Service Desk](https://cncfservicedesk.atlassian.net/servicedesk/customer/portal/1);
- keeping the badge criteria in sync with this KEP;
- issuing badges to recipients.

### Issuance

Badges are awarded at the end of each month:

- **Contributor of the Month:** the winner receives the badge once they are announced.
- **Kubeflow Mentor:** mentors receive the badge at the end of the month in which their LFX or GSoC mentorship term completes.

### Yearly Cycle

CNCF badges expire annually, so badge names include the year, for example "Kubeflow Mentor 2027". Every December, the KOC reviews the badge program, including the badge criteria and the reserved slots, and then requests the next year's badges through the CNCF Service Desk.

New badge types do not have to wait for the December review. While fewer than four badge types are in use, the KOC can request a new one at any time by amending this KEP. If all four are in use, an existing badge type must be retired before a new one is added, which is normally done during the December review.

## Implementation History

- 2026-09-30: KEP created.
