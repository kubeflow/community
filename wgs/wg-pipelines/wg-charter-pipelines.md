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
Includes Argo and Tekton based forks, as well as new versions of orchestrators
- Metadata Store that tracks pipeline artifacts, their lineage and dependencies as well as the ML Metadata Service exposing the Metadata APIs, and the Metadata collection agent
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


#### Dependencies

ML Pipeline projects may have dependencies on the following projects managed by other KF work groups:
- KF User Profiles Controller
  - Used by multi-user feature in fullset Kubeflow deployement
- KF Central UI Console
  - Used by fullset Kubeflow deployment
- Notebook and KF integration of Notebooks
  - Used by fullset Kubeflow deployment
- TF Job and other training controllers
  - Used by user's codes, e.x. certain pipeline component (one node in DAG) uses TF Job for training.
- Katib
  - Used by user's codes, e.x. certain pipeline component (one node in DAG) uses Katib for HP tuning etc.
 
#### Initial set of subprojects governed by ML Pipelines WG

>github.com/kubeflow/pipelines
- KFP Backend (mainline), incl. all backend servers
- KFP UI
- KFP SDK/DSL/CLI, including samples
- Components and pipelines content in KF repo

>github.com/kubeflow/kfp-tekton
- KFP Tekton Backend (fork, with long term intent of merging in mainstream pipelines repo)

>github.com/kubeflow/metadata
- Metadata Backend, API and UI 


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

New [wg-subprojects] need to be reviewed and approved by the WG Leads.


[wg-governance]: ../wg-governance.md
[wg-subprojects]: https://github.com/Kubeflow/community/blob/master/wgs/wg-pipelines/README.md#subprojects
