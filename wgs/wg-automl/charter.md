# WG AutoML Charter

This charter adheres to the conventions, roles and organization management outlined in [wg-governance].

## Scope

WG AutoML is responsible for all aspects of Automated Machine Learning technologies on Kubeflow.
The WG covers researching, developing and operating various targets of ML automation for Kubeflow.

### In scope

#### Code, Binaries and Services

- APIs and tools used for running AutoML experiments (e.g. Experiment, Suggestion, Trial CRD/Controller).
- Web UI to enhance user experience with AutoML techniques.
- Database manager to analyse and store experiments metrics.
- Documentation for detailed description of using AutoML in Kubeflow.

#### Cross-cutting and Externally Facing Processes

- Coordinating with Training WG to make sure that all distributed training jobs can be used in AutoML experiments.
- Coordinating with Control Plane WG to ensure that AutoML manifests are properly deployed with Kubeflow.
- Coordinating with Central Dashboard WG to correct integration with AutoML UI.
- Coordinating with release teams to ensure that the AutoML features can be released properly.

### Out of scope

- APIs used for running Training Jobs (Trials) (this is related to Training WG).

## Roles and Organization Management

This WG follows adheres to the Roles and Organization Management outlined in [wg-governance]
and opts-in to updates and modifications to [wg-governance].

### Subproject Creation

WG Technical Leads.

[wg-governance]: ../wg-governance.md
