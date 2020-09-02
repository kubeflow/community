# WG Notebooks Charter

This charter adheres to the conventions, roles and organization management outlined in [wg-governance].

## Scope

WG Notebooks is responsible for the user experience around Notebooks and other IDEs and their integrations with Kubeflow.
The WG covers launching and managing different types of Notebooks on Kubeflow as well as workflows that Notebook extensions enable.

### In scope

#### Code, Web apps, Controllers and Services

- APIs and tools used for launching Notebooks (e.g. Notebooks CRD/Controller).
- Web UI to manage and connect to Notebook instances (e.g. Notebook Manager UI)
- SDKs and integrations from inside the Notebooks (e.g. Git inside Notebooks)
- Documentation for detailed description of using Notebooks in Kubeflow.
- Notebook images that will be working out of the box with Kubeflow.

#### Cross-cutting and Externally Facing Processes

- Coordinating with Control Plane WG to ensure that Notebooks manifests are properly deployed with Kubeflow.
- Coordinating with Central Dashboard WG to ensure the integration with the Notebook Manager UI is up-to-date.
- Coordinating with release teams to ensure that the Notebooks features can be released properly.
- Coordinating with Training and AutoML WG to ensure that corresponding SDK is properly working in Kubeflow Notebooks
- Ensuring that Kubeflow's Notebook images are continuously build and released.

### Out of scope

- APIs used for running Training Jobs or AutoML Experiments (this is related to Training WG and AutoML WG).
- The Pipelines DSL that can be utilised from inside the Notebooks (this is related to Pipelines WG).
- Coordinating with Training and AutoML WG to ensure that corresponding SDK is properly working in Kubeflow Notebooks

## Roles and Organization Management

This WG adheres to the Roles and Organization Management outlined in [wg-governance]
and opts-in to updates and modifications to [wg-governance].

### Subproject Creation

WG Technical Leads.

[wg-governance]: ../wg-governance.md
