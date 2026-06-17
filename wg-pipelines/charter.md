# ML Pipelines Charter

This charter adheres to the conventions, roles and organization management outlined in [wg-governance].

## Scope

The goal of the Kubeflow Pipelines project is to build a Kubernetes optimized stack for creating and deploying ML Pipelines and enabling a rich ecosystem of pipelines components and tools. ML Pipelines project has the goal of enabling simple and reliable productionalization of autonomous ML workflows, advancing the standards of ML Engineering and making them available to a large community of users across various Kubernetes deployment options.

### In scope

#### Code, Binaries and Services

##### Backend Servers

- ML Pipelines user facing APIs
- Storage abstraction and integration components for pipelines
- Pipelines Orchestration Engine
- Pipeline job scheduling controller, and continuous pipeline execution services

##### FE and UI

- Pipelines Templates UI
- Experiment tracking and run exploration UI
- Metadata Tracking and Lineage Exploration UI
- Metadata metric visualization

##### Tools

- Authoring SDK for components and pipelines
- Tools for pipeline creation and deployment
- CLI for interacting with Pipelines API

##### Deployment

- Deployment scripts and tools for deploying ML Pipeline service components on Kubernetes engines of various cloud providers and on-prem deployments

##### Pipeline Content

- Cloud specific integration components
- HW and SW vendor specific components
- Pipeline examples for different ML use cases

##### Documentation

- Concepts documentation
- Cloud provider specific documentation
- Documentation for the SDK and REST API
- Documentation for the sample components and pipelines

#### Cross-cutting and Externally Facing Processes

##### ML Pipelines WG defines the following processes for the included projects:

- Community meetings
- Release and validation processes
- Issue triaging and prioritization (focusing on decision making process)
- Feature and roadmap planning
- Integration process with other external projects
- Extensibility points and extension development by the community. (e.g pipeline components, system extensions such as schedulers, metadata stores, etc)

## Roles and Organization Management

This WG adheres to the Roles and Organization Management outlined in [wg-governance] and opts-in to updates and modifications to wg-governance.

The positions of the Chairs and TLs are granted to the organizations and companies participating in the workgroup governance. If an individual leaves the organization to which that position was designated - the organization will have the right to appoint others to these roles.

### Subproject Creation

New subprojects need to be reviewed and approved by the WG Leads.

[wg-governance]: ../committee-steering/wg-governance.md
[wg-subprojects]: https://github.com/Kubeflow/community/blob/master/wgs/wg-pipelines/README.md#subprojects
