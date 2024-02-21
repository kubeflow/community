# KSC Decision Log

This file documents decisions by the Kubeflow Steering Committee.

Template for decisions:

```
### Subject

#### Date
mm/dd/yyyy

#### Context
TBA

#### Decision
TBA

#### Rationale
TBA

#### Dissenting Opinions
TBA

#### Approvers
* Yuan Tang
* James Wu
* Josh Bottum
* Andrey Velichkevich
* Johnu George
```

## Decisions

### Switch from Google CLA to DCO

#### Date
02/08/2024

#### Context
Now that the Kubeflow is part of CNCF, we may consider switching to [DCO](https://developercertificate.org/) from Google CLA.

#### Decision
We will move from the current Google Individual and Corporate CLAs to DCO and add [DCO App](https://github.com/apps/dco/) in every repository.

#### Rationale
* CNCF provides support for implementing both the DCO and CLA. Choice of one over the other is left to each CNCF project. Neither is currently viewed as providing stronger legal protection than the other.
* The Linux kernel as well as most CNCF projects use the DCO. The DCO is viewed as a more developer-friendly alternative to the CLA.

#### Dissenting Opinions
None.

#### Approvers
* Yuan Tang
* James Wu
* Josh Bottum
* Andrey Velichkevich
* Johnu George

### Transition to CNCF Slack

#### Date
02/01/2024

#### Context
We are currently using Kubeflow Slack workspace but we should consider switching to the existing CNCF Slack.

#### Decision
We will transition to CNCF Slack. During the transition, we will keep the existing Kubeflow Slack workspace as is and gradually turn it down based on a schedule (details TBD).

#### Rationale
* Kubeflow Slack workspace is under a free plan and users can only see messages within 90 days.
* Messages on CNCF Slack workspace are persisted and visible to everyone.
* It's easier to collaborate with other projects in the CNCF ecosystem.

#### Dissenting Opinions
None.

#### Approvers
* Yuan Tang
* James Wu
* Josh Bottum
* Andrey Velichkevich
* Johnu George
