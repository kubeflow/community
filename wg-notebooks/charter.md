# WG Notebooks Charter

This charter adheres to the conventions, roles and organization management outlined in [wg-governance].

## Scope

WG Notebooks is responsible for the user experience around Notebooks and their integrations with Kubeflow. The WG covers launching and managing Notebooks on Kubeflow as well as workflows that Notebook extensions enable.

### In scope

#### Code, Web apps, Controllers and Services

- APIs and tools used for launching Notebooks (e.g. Notebooks CRD/Controller).
- Web UI to manage and connect to Notebook instances (e.g. Notebook Manager UI)
- SDKs and integrations from inside the Notebooks (e.g. Git inside Notebooks)
- Documentation for detailed description of using Notebooks in Kubeflow.
- Notebook images that will be working out of the box with Kubeflow.

#### Cross-cutting and Externally Facing Processes

- Coordinating with Manifests WG to ensure that Notebooks manifests are properly deployed with Kubeflow.
- Coordinating with Central Dashboard WG to ensure the integration with the Notebook Manager UI is up-to-date.
- Coordinating with Training and AutoML WG to ensure that corresponding SDK is properly working in Kubeflow Notebooks
- Ensuring that Kubeflow's Notebook images are continuously built and released.
- Ensuring that the Notebook Manager UI images are continuously built and released.
- Ensuring that the Notebook Controller images are continuously built and released.

### Out of scope

- Developing and maintaining libraries allowing users to utilize other (non-)Kubeflow components (e.g. AutoML Experiments, Pipelines DSL, Fairing)

## Roles and Organization Management

This WG adheres to the Roles and Organization Management outlined in [wg-governance]
and opts-in to updates and modifications to [wg-governance].

### Subproject Creation

WG Technical Leads.

[wg-governance]: ../wg-governance.md
