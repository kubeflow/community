# WG Data Charter

This charter adheres to the conventions, roles, and organisation management outlined in [wg-governance] for the Working Group "Data".

## Scope

The WG "Data" is focused on enhancing the support for Data/metadata-related tasks within Kubeflow, with a specific focus on the [Spark operator](https://github.com/kubeflow/community/pull/672) and [Model Registry](https://github.com/kubeflow/kubeflow/issues/7396).
The group aims to streamline data processing workflows, facilitate efficient data lifecycle and ML models' metadata management, while ensuring seamless integration with other Kubeflow components.

An additional goal of the group is to offer a common ground for data/metadata-related topics in the MLOps orbit that didn't have a more specific working group yet, so they can "incubate as one", coherent effort.

For example: Data Preparation, Feature Store, and Model Registry have been recently discussed in the Kubeflow community while not mature enough yet to have their own working group, they can be nurtured together as part of this WG.

### In scope

#### Code, Binaries, and Services

- Onboarding and maintenance of the Spark operator for scalable and distributed data processing.
[See also](https://github.com/kubeflow/spark-operator)
- Continued development of the Model Registry to manage and version machine learning models efficiently.
[See also](https://github.com/kubeflow/model-registry)
- CLI tools and REST APIs for interacting with Kubeflow APIs related to data processing and ML models metadata management.
- CI/CD pipelines for Kubeflow subproject repositories in the scope of this WG.

#### Cross-cutting and Externally Facing Processes

- Ensuring seamless integration of these WG subprojects with the rest of the Kubeflow platform. For example:
  - Coordinating with WG Pipelines for integrations of Model Registry with KFP.
  - Coordinating with WG Serving for integrations of Model Registry with KServe and ModelMesh.
  - ...
- Coordinating with release teams to ensure that the capabilities and subprojects in scope of this WG can be released properly.
- Offer mentorship to support contributors working on data-centric projects that want to integrate with Kubeflow.

### Out of scope

- APIs and components related to: ML exploration and experimentation (covered in Notebooks/Pipelines), ML training (covered in Training), serving ML models for inference (covered in Serving), ...
- ...
- Anything else not explicitly outlined in the scope of this WG.

## Roles and Organization Management

This WG adheres to the Roles and Organization Management outlined in [wg-governance] and opts-in to updates and modifications to [wg-governance].

### Additional responsibilities of Chairs

- Coordinating and facilitating discussions on Data-related topics in scope of the WG, within the WG itself and the Kubeflow community.
- Ensuring alignment with overall Kubeflow goals and objectives in the context of data processing and ML model metadata's management.

### Additional responsibilities of Tech Leads

- Providing technical guidance and mentorship to contributors working on Spark operator, Model Registry, and the projects in scope of this WG.
- Overseeing the technical direction of the subprojects and ensuring consistency with Kubeflow's vision for data processing and metadata management.

### Deviations from [wg-governance]

This WG follows the outlined roles and governance in [wg-governance], with one derogation request:

1. Dhiraj Bokde at the time of starting this charter is not a Member of the Kubeflow community but the WG chairs recognizes their technical leadership in overseeing the architectural aspects and technical choices of the _existing_ Model Registry subproject. On these premises, an exception is requested to nominate Dhiraj Bokde as one of the Tech Leads for the Model Registry subproject.

### Subproject Creation

CHOOSE ONE
1. WG Technical Leads
2. Federation of Subprojects

[wg-governance]: ../wgs/wg-governance.md
