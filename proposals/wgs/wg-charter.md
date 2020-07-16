# WG Charter Guide

All Kubeflow WGs must define a charter defining the scope and governance of the WG.

- The scope must define what areas the WG is responsible for directing and maintaining.
- The governance must outline the responsibilities within the WG as well as the roles
  owning those responsibilities.

## Steps to create a WG charter

1. Copy [the template][Short Template] into a new file under community/wg-*YOURWG*/charter.md ([sig-architecture example])
2. Read the [Recommendations and requirements] so you have context for the template
3. Fill out the template for your WG
4. Update [wgs.yaml] with the individuals holding the roles as defined in the template.
5. Add subprojects owned by your WG in the [wgs.yaml]
5. Create a pull request with a draft of your charter.md and wgs.yaml changes.  Communicate it within your WG
   and get feedback as needed.
6. Send the WG Charter out for review to steering@kubeflow.org.  Include the subject "WG Charter Proposal: YOURWG"
   and a link to the PR in the body.   
7. Typically expect feedback within a week of sending your draft.  Expect longer time if it falls over an
   event such as KubeCon/CloudNativeCon or holidays.  Make any necessary changes.
8. Once accepted, the steering committee will ratify the PR by merging it.

## Steps to update an existing WG charter

- For significant changes, or any changes that could impact other WGs, such as the scope, create a
  PR and send it to the steering committee for review with the subject: "WG Charter Update: YOURWG"
- For minor updates to that only impact issues or areas within the scope of the WG the WG Chairs should
  facilitate the change.

## WG Charter approval process

When introducing a WG charter or modification of a charter the following process should be used.
As part of this we will define roles for the [OARP] process (Owners, Approvers, Reviewers, Participants)

- Identify a small set of Owners from the WG to drive the changes.
  Most typically this will be the WG chairs.
- Work with the rest of the WG in question (Reviewers) to craft the changes.
  Make sure to keep the WG in the loop as discussions progress with the Steering Committee (next step).
  Including the WG mailing list in communications with the steering committee would work for this.
- Work with the steering committee (Approvers) to gain approval.
  This can simply be submitting a PR and sending mail to [steering@kubeflow.org].
  If more substantial changes are desired it is advisable to socialize those before drafting a PR.
    - The steering committee will be looking to ensure the scope of the WG as represented in the charter is reasonable (and within the scope of Kubeflow) and that processes are fair.
- For large changes alert the rest of the Kubeflow community (Participants) as the scope of the changes becomes clear.
  Sending mail to [kubeflow-discuss@googlegroups.com] and/or announcing at the community meeting are a good ways to do this.

If there are questions about this process please reach out to the steering committee at [steering@kubeflow.org].

## How to use the templates

WG should use [the template][Short Template] as a starting point. This document links to the recommended [WG Governance][wg-governance] but WGs may optionally record deviations from these defaults in their charter.


## Goals

The primary goal of the charters is to define the scope of the WG within Kubeflow and how the WG leaders exercise ownership of these areas by taking care of their responsibilities. A majority of the effort should be spent on these concerns.


[OARP]: https://stumblingabout.com/tag/oarp/
[Recommendations and requirements]: wg-governance-requirements.md
[wg-governance]: wg-governance.md
[Short Template]: /templates/wg-charter-template.md
[wgs.yaml]: /templates/wgs.yaml
[sig-architecture example]: ../../sig-architecture/charter.md
[steering@kubeflow.org]: mailto:steering@kubeflow.org
[kubeflow-discuss@googlegroups.com]: mailto:kubeflow-discuss@googlegroups.com