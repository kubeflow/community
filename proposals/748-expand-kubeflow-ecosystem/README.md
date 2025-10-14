# KEP-748: Expanding the Kubeflow Ecosystem with a New OSS Project

## Summary
This KEP outlines how OSS projects can join the Kubeflow Ecosystem.


Note: this process followed the Kubeflow Steering Committee's [Normal decision process](../KUBEFLOW-STEERING-COMMITTEE.md#normal-decision-process) 

## Motivation
As Kubeflow has become a well established ecosystem and community, several
projects may want to join the Kubeflow ecosystem to explicitly be a part of our 
community. 

Kubeflow's goal is to cover the entire AI/ML lifecycle and new projects can help 
address missing stages in that lifecycle.

### Goals
This goal of this process is to give clear guidelines and set expectations 
for community members about how to be formally included into the Kubeflow Ecosystem and 
the application process.

The decision making process will be separate from the application process and is at the 
discretion of the Kubeflow Steering Committee. The application and data provided are 
critical for the KSC to make an informed decision that is best for the longetivity 
of the project and community.

### Non-Goals
- Give specific recommendations for evaluating any individual project.
- Supporting project add-ons.

## Proposal
The process to join the Kubeflow Ecosystem is intended to be simple but thorough.

Project owners or maintainers will apply to join by following a four
step process. 

The process is outlined in six steps:

1. Create a GitHub Issue with a Google Document outlining your proposal (please allow for commentary), the document should have a rough outline with:
    - Authors
    - Motivation
    - Benefits for Kubeflow
    - Benefits for the Project's Community
    - Community Metrics
    - Contributor Metrics
    - Maintainers
    - Migration  Plan
    - Other Related Projects
2. Provide a demo during the Kubeflow Community Call
3. Submit a Pull Request with the [../proposals/new-project-join-process.md](application form).
4. Add your proposal to the Kubeflow Community call to introduce and collect feedback on
the application.
5. Work with the Kubeflow Outreach Committee to send an announcement email in `kubeflow-discuss` and publish messages on Slack, LinkedIn, X/Twitter, and other Kubeflow social resources
6. Schedule meeting with Kubeflow Steering Committee for initial vote and to collect feedback.
7. Identify the appropriate Kubeflow Working Group that should control the project.
8. Merge or close the Pull Request depending upon the outcome of the final vote.

### Notes/Constraints/Caveats (Optional)

Note that this application does not guarantee acceptance of the proposed project to Kubeflow.

### Risks and Mitigations

Two major risks for Kubeflow accepting projects are:
1. Accepting projects that do not have active contributors or a healthy user base
- This is why metrics are meant to capture this
2. Impacting the delivery speed of Kubeflow releases
- It will be expected that the maintainers invest in incorporating the project into the manifest or it will be removed
3. Additional infrastructure support
- It will be expected that the maintainers invest in providing this support

## Drawbacks

How could this new project harm the Kubeflow community?

## Alternatives

What other open source projects are there like the one proposed? 
Why should Kubeflow accept the one proposed?
