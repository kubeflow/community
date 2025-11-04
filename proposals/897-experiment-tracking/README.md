# KEP-897: Centralize Experiment Tracking in Kubeflow

## Summary

This proposal aims to resolve the current fragmented and limited experiment tracking experience by expanding the
**Kubeflow Model Registry** into a unified, centralized metadata store. Currently, experiment tracking is scattered
across components like Kubeflow Pipelines (which requires pipeline execution for tracking) and Katib (limited to
hyperparameter tuning). This leads to challenges such as **limited flexibility** for direct logging from Python scripts
or Jupyter notebooks, a **fragmented user experience** across multiple interfaces, and **maintenance difficulties** due
to reliance on the inactive MLMD project.

The proposal tackles these issues by:

- **Expanding Model Registry** into a central experiment tracking store for experiments, runs, metrics, and artifacts
  across all Kubeflow components.
- Providing **MLFlow SDK compatibility**, enabling users to leverage familiar APIs while storing data in Kubeflow.
- Implementing **multitenancy** with Kubernetes namespace-level isolation.
- Offering a **unified UI** for comprehensive experiment management and visualization.

This approach will enable users to log experiments and compare runs from various sources in a single interface while
maintaining consistent metadata throughout the ML lifecycle. This has the added benefit of eliminating technical debt
associated with Kubeflow Pipelines' heavy reliance on MLMD.

This KEP is a high-level proposal with the expectation that each impacted component will have their own KEP for detailed
design.

## Motivation

Currently, experiment tracking in Kubeflow is fragmented and tightly coupled to specific components. Kubeflow Pipelines
requires users to run everything through pipelines to track experiments, while Katib's experiments are limited to
hyperparameter tuning scenarios. This fragmentation creates several challenges:

1. **Limited flexibility**: Users cannot log experiments directly from Python scripts, Jupyter Notebooks, or other
   Kubeflow components without forcing everything through pipelines. This restriction often drives users to seek
   solutions outside the Kubeflow ecosystem.
1. **Fragmented experience**: Users must navigate multiple interfaces to correlate run results and evaluation data,
   depending on which Kubeflow project they use (e.g., Pipeline runs, Katib experiments, Training Operator results).
1. **No unified tracking**: Users cannot easily compare runs, share insights, or maintain consistent metadata across the
   entire Kubeflow ecosystem.
1. **Maintenance challenges**: The Kubeflow Pipelines dependency on MLMD creates technical debt and limits future
   flexibility due to its lack of active maintenance. MLMD also overlaps with the Model Registry objectives defined in
   the
   [Model Registry overview](https://www.kubeflow.org/docs/components/model-registry/overview/#use-case-2-experimenting-with-different-model-weights-to-optimize-model-accuracy),
   creating separate metadata store experiences.

These limitations make it difficult to effectively manage the machine learning lifecycle across Kubeflow.

### Background and History

- 2019 — Creation of a dedicated metadata effort was proposed to make metadata management a first-class Kubeflow
  component for designs, APIs, schemas, and implementations. See
  [Create a kubeflow/metadata repository (Issue #238)](https://github.com/kubeflow/community/issues/238).
- 2022 — The community revisited unified metadata and artifact tracking across Kubeflow components, proposing a
  lightweight, unified interface and optional use of ML Metadata (MLMD) as a backend rather than maintaining a
  standalone store. See
  [Kubeflow component integration with ML Metadata (Issue #783)](https://github.com/kubeflow/community/issues/783).
- The original Kubeflow Metadata project was later archived, leaving Kubeflow Pipelines’ MLMD usage as the de facto
  approach and creating fragmentation across components (as noted in
  [Issue #783](https://github.com/kubeflow/community/issues/783)).

This KEP builds on that history by centralizing experiment tracking within Model Registry, aligning the data model
across Kubeflow components, and decoupling Kubeflow Pipelines from a hard dependency on MLMD while allowing optional
interoperability.

### Goals

1. **Add decoupled experiment tracking to Kubeflow**: Transform the existing Model Registry component into a centralized
   experiment tracking system that operates independently from Kubeflow Pipelines, emphasizing separation of concerns.
   This unified metadata store will handle experiments, runs, metrics, and artifacts across the entire Kubeflow
   ecosystem, enabling experiments to be logged and managed without requiring pipeline execution.
1. **Pipelines refactoring for externalized experiment tracking**: Refactor Kubeflow Pipelines to externalize experiment
   tracking functionality, removing the built-in MLMD dependency (technical debt) and enabling integration with both
   Model Registry, MLMD, and third-party experiment tracking systems. This decoupling allows pipelines to focus on
   orchestration while experiment tracking becomes a pluggable component.
1. **Extend SDK capabilities for experiment tracking**: Enhance the Kubeflow SDK to support direct logging of
   experiments, runs, metrics, and artifacts without requiring pipeline execution.
1. **MLFlow SDK Integration**: Develop an
   [MLFlow tracking store plugin](https://mlflow.org/docs/latest/ml/plugins/#storage-plugins) that enables users to
   continue using familiar MLFlow APIs while storing experiment data in Kubeflow's centralized tracking system. This
   approach provides seamless integration for existing MLFlow workflows and positions Kubeflow's SDK and Kubeflow's
   Model Registry SDK as complementary to the MLFlow SDK rather than competitive alternatives.
1. **Implement multitenancy in Model Registry**: Add multitenancy support to Model Registry to enable isolation at the
   Kubernetes namespace level like Kubeflow Pipelines does today. This resolves the multitenancy gap that exists with
   MLMD today.
1. **Differentiate Katib experiments in the Kubeflow dashboard**: Update the Kubeflow dashboard to clearly distinguish
   between Katib's hyperparameter tuning experiments and general Kubeflow experiments, improving user experience and
   reducing confusion.

### Non-Goals

1. **Decoupling Katib's experiments from their current implementation**: While the Kubeflow community can revisit
   integration with Katib after the initial implementation, we are not targeting the decoupling of Katib's existing
   experiment tracking system as part of this proposal. The initial focus is on the SDK and Pipelines experience.
1. **MLFlow UI support**: Although the MLFlow plugin should enable MLFlow UI compatibility, providing direct MLFlow UI
   support is not a targeted goal of this proposal.
1. **Automatic experiment tracking from the Kubeflow Trainer**: While users can leverage the new functionality through
   the Kubeflow SDK or MLFlow plugin, we are not implementing automatic experiment tracking directly from the Kubeflow
   Trainer as part of this proposal. The community should revisit integrations at a later date.

## Proposal

### Model Registry Expansion

Model Registry was designed to be a centralized metadata store for Kubeflow. It currently focuses on managing metadata
for the lifecycle of machine learning models, from registration and versioning through deployment and serving. This
proposal expands its scope by adding new metadata resource types to cover experiment tracking. As part of this
expansion, we could consider renaming Model Registry to better reflect its broader scope.

The expanded Model Registry will support:

- **Experiments and Runs**: Centralized tracking of experiments and their associated runs across all Kubeflow components
- **Multi-tenancy**: Namespace-level isolation using Kubernetes RBAC
- **Artifact Management**: Metadata storage of models, datasets, and other ML artifacts
- **Unified Metadata**: Consistent metadata schema across the entire Kubeflow ecosystem

### Kubeflow Pipelines Integration

The integration of Kubeflow Pipelines with the centralized experiment tracking system will be implemented in two phases:

#### Phase 1: Dual Registration and Unified Experiment View

- Enable Kubeflow Pipelines to register experiment metadata in both MLMD and Model Registry simultaneously
- Provide users with a unified view of experiments across the entire Kubeflow ecosystem
- Maintain backward compatibility with existing MLMD-dependent tooling and existing Kubeflow Pipelines UI

#### Phase 2: Complete MLMD Decoupling

- Eliminate the MLMD dependency by migrating all Kubeflow Pipelines (KFP) metadata storage to the KFP database and
  external metadata trackers
- Provide configuration options allowing users to choose between Model Registry and MLMD for experiment tracking
- Kubeflow Pipelines UI enhancements with more direct integration with Model Registry if that mode is chosen

### SDK Integration

#### MLFlow SDK Compatibility

- Implement MLFlow plugins to connect to the Model Registry backend
- Enable users to leverage MLFlow's familiar APIs while storing data in centralized Kubeflow infrastructure
- Support automatic logging for popular ML frameworks (TensorFlow, PyTorch, scikit-learn, etc.) through MLFlow's SDK

#### Kubeflow SDK Enhancement

- Provide native experiment tracking capabilities within the Kubeflow SDK
- Simplify experiment tracking setup and configuration
- Enable seamless integration with Model Registry for unified metadata management
- Support both local and remote experiment tracking workflows

### Experiment Tracking UI

The expanded Model Registry UI will provide a comprehensive interface for experiment management and visualization with
feature parity to the existing Kubeflow Pipelines run comparison functionality, while extending support to all run
sources generically.

Key UI components will include:

- Experiments overview page with filtering and sorting capabilities
- Experiment detail view with hierarchical run structures
- Run management interface with advanced filtering options
- Compare runs with multiple chart types

### User Stories

#### Story 1a: Data Scientist Using Kubeflow SDK for Native Integration

As a data scientist working with Kubeflow, I want to use the Kubeflow SDK for experiment tracking so that I can record
run metadata from Jupyter notebooks, Python scripts, or Kubeflow Trainer jobs alongside pipeline runs.

#### Story 1b: Data Scientist Using Existing MLFlow Workflows

As a data scientist adopting Kubeflow, I want to continue using my existing MLFlow code so that I can seamlessly
integrate my current experiment tracking workflow into the Kubeflow ecosystem. I should be able to use the same MLFlow
SDK APIs I'm already familiar with (mlflow.log_metric, mlflow.log_param, mlflow.log_artifact) and have my experiments
automatically appear in the unified Kubeflow dashboard alongside pipeline runs.

#### Story 2: ML Engineer Comparing Runs Across Different Sources

As an ML engineer, I want to compare experiment runs that come from different sources (Jupyter notebooks, pipeline runs,
training jobs) in a single unified interface, so that I can make informed decisions about model performance regardless
of how the experiments were executed. I should be able to filter runs by experiment, parameters, metrics, and source,
then visualize comparisons using parallel coordinates plots, scatter plots, and other chart types.

#### Story 3: Platform Administrator Managing Multi-tenant Experiment Tracking

As a platform administrator, I want to ensure that experiment tracking data is properly isolated by Kubernetes namespace
using RBAC, so that different teams can securely share the same Kubeflow cluster without data leakage. I should be able
to configure namespace-level access controls for experiments, runs, and artifacts, while maintaining the ability to
provide global visibility for cross-team collaboration when needed.

### Risks and Mitigations

1. **Migration Challenges**: The proposal involves migrating away from MLMD, which is currently used by Kubeflow
   Pipelines. This migration process could be complex and risky, potentially breaking existing workflows. To mitigate
   this risk, we will implement extensive testing and maintain an extended transition period where Kubeflow Pipelines
   registers to both MLMD and Model Registry.
1. **Dependency on External Plugin**: The proposal relies heavily on MLFlow SDK compatibility through plugins, creating
   a dependency on MLFlow's plugin architecture. This dependency could become fragile if MLFlow changes their plugin
   APIs or if the plugins don't work as expected. To mitigate this risk, the Kubeflow SDK will also support these APIs,
   allowing us to move away from wrapping MLFlow without breaking user code. Furthermore, popular plugins such as from
   [Microsoft Azure](http://docs.azure.cn/en-us/machine-learning/how-to-use-mlflow-configure-tracking) would cause
   significant disruption for the MLFlow community if they were to change their SDK plugin stance, making such changes
   unlikely.

## Design Details

### Model Registry Domain Models

The expanded Model Registry will include the following domain models, heavily influenced by the API design in
[kubeflow/model-registry#1224](https://github.com/kubeflow/model-registry/issues/1224#issuecomment-3068005968). This is
meant to be a high-level design with further refinement being done in a Model Registry specific KEP or design document.

1. **Experiments**: A group of related runs. This would replace experiments in Pipelines and could potentially map to
   experiments in Katib.
1. **Users**: A user to associate runs, metrics, artifacts, etc. for auditing. This will generally map to the Kubernetes
   identity.
1. **Runs**: An execution in the machine learning workflow. In Pipelines, this maps to a pipeline run. In Katib, this
   could map to a trial. Each run has a name, status, timestamps, source (e.g. pipelines), the user that created it, and
   can have associated artifacts, metrics, parameters, and arbitrary metadata/tags as key-value pairs.
1. **Nested runs**: When a run represents a workflow with multiple sequential and/or parallel steps (such as a
   pipeline), a nested run represents each individual step. These are essentially runs with a parent. In pipelines, each
   DAG node is represented by one or more nested runs. A nested run's parent can also be another nested run.
1. **Metrics**: A key-value pair where the key is the metric name and the value is a numeric value.
1. **Parameters**: A key-value pair where the key is the parameter name. This maps to a run ID.
1. **Generic artifacts**: An artifact with a name, URI, and metadata. This would be used to represent files such as JSON
   files, logs, CSV files, and other data files.
1. **Unregistered Models**: Model Registry currently has the concept of registered model versions, but there is an
   intermediate state that needs to be represented where a run produces an output model that isn't yet registered. It
   has a name, URI, and arbitrary metadata/tags as key-value pairs.
1. **Datasets**: An artifact used for representing input data for training, evaluation, RAG, and other machine learning
   tasks.
1. **Images**: An artifact used to represent an image to be rendered directly in the browser. This will be mainly used
   for custom visualizations not available natively in the UI.

### Filtering Requirements

Some basic level of filtering is required for initial UI rendering. This includes but is not limited to:

- Filter all entities by namespace
- Filter runs by experiment name
- Filter runs by parameter name
- Filter runs by metric name
- Filter runs by parent run
- Filter runs by status
- Filter runs by metadata fields/tags
- Filter runs by source
- Filter all entities by user that created it
- Filter by timestamps (before, after)
- Fuzzy searching on entity names

### Multi-tenancy Implementation

Model Registry's current authorization model gates access at the API level through a proxy rather than at the individual
resource or namespace level. This approach prevents the same Model Registry instance from being shared across teams that
require isolation. This limitation conflicts with Kubeflow Pipelines' multiuser mode, which is the default deployment
strategy for the Kubeflow platform. MLMD has the same limitation, so adding multi-tenancy support to Model Registry
would address this gap for all of Kubeflow's metadata needs.

This proposal introduces an optional/configurable authorization mode for Model Registry that leverages Kubernetes
subject access review without adding custom resource definitions or modifying the existing API concepts. Instead, it
maps Kubernetes RBAC concepts to the existing REST API entities at the namespace level.

To illustrate how this authorization mode could work, consider a scenario where entities are mapped to Kubernetes
resources on the cluster to provide namespace-level isolation. For example, when a user calls
"/api/model_registry/v1alpha3/experiments/1" to access an experiment named "my-experiment" in the namespace
"my-project", the Model Registry API server would make a subject access review call on the following resource:

```go
authorizationv1.ResourceAttributes{
   Namespace: "my-project",
   Name:      "my-experiment",
   Verb:      "get",
   Group:     "modelregistry.kubeflow.org",
   Version:   "v1alpha3",
   Resource:  "experiments",
}
```

**Example Kubernetes Role:**

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: my-project
  name: model-registry-reader
rules:
  - apiGroups: ['modelregistry.kubeflow.org']
    resources: ['experiments']
    verbs: ['get', 'list']
    resourceNames: ['my-experiment'] # Optional: restrict to a specific experiment
```

This aligns with how Kubeflow Pipelines works today and would integrate well with Kubeflow profiles.

### Kubeflow Pipelines Integration Details

#### Phase 1: Dual Registration and Unified Experiment View

**Objective**: Enable Kubeflow Pipelines to register experiment metadata in both MLMD and Model Registry simultaneously,
while providing users with a unified view of experiments across the entire Kubeflow ecosystem.

**Implementation Details**:

- Kubeflow Pipelines will maintain its existing MLMD integration for backward compatibility
- Add an optional configuration flag to enable dual registration to Model Registry
- When dual registration is enabled, pipeline runs will be automatically registered in Model Registry with appropriate
  metadata mapping
- Modify the Kubeflow Pipelines UI to link to Model Registry's experiment tracking experience but keep the current MLMD
  experience

**Benefits**:

- Users can immediately benefit from centralized experiment tracking without breaking existing workflows
- Gradual migration path that doesn't require immediate MLMD deprecation
- Global experiment visibility across all Kubeflow components
- Maintains backward compatibility with existing MLMD-dependent tooling

#### Phase 2: Complete MLMD Decoupling

**Objective**: Makes MLMD optional by migrating all Kubeflow Pipelines metadata storage to either the KFP database and
Model Registry/MLMD (user chooses), providing users with flexibility in their experiment tracking solution.

**Implementation Details**:

- Migrate all MLMD-stored state beyond experiment tracking to the Kubeflow Pipelines database
- Provide configuration options allowing users to choose between Model Registry and MLMD as their experiment tracking
  backend
- Modify the KFP UI to be more integrated with Model Registry

**Benefits**:

- Eliminates a hard dependency on the not actively maintained MLMD project
- Provides users with choice between Model Registry and MLMD based on their specific needs
- Reduces technical debt and maintenance burden
- Aligns with the broader Kubeflow ecosystem's metadata strategy

### SDK Implementation Details

#### MLFlow Model Registry Plugin

The MLFlow SDK has achieved remarkable adoption in the machine learning community, with over
[747 million downloads](https://pepy.tech/projects/mlflow?timeRange=threeMonths) on PyPI as of this writing. This
widespread popularity makes MLFlow SDK compatibility essential for Kubeflow's experiment tracking solution to gain
traction among the AI/ML community. The MLFlow SDK's extensible
[plugin architecture](https://mlflow.org/docs/latest/ml/plugins/#storage-plugins) allows developers to swap out the
underlying backend storage while maintaining the familiar MLFlow API surface.

To enable seamless integration, we will implement two key MLFlow plugins that connect to the Model Registry backend:

1. **Tracking Store Plugin**: This plugin will handle experiment and run metadata, metrics, parameters, and tags. It
   will map MLFlow's tracking concepts to the Model Registry's domain models (Experiments, Runs, Users, Metrics, etc.)
   while excluding tracing functionality for the initial implementation.

2. **Artifact Repository Plugin**: This plugin will manage artifact storage and retrieval, leveraging the Model
   Registry's artifact management capabilities to store model files, datasets, and other ML artifacts.

With these plugins in place, users will be able to use the MLFlow SDK with minimal changes to their existing code. They
simply need to install an additional Python package and specify the Model Registry API as their tracking URI. This
approach enables users to leverage MLFlow's powerful
[automatic logging](https://mlflow.org/docs/latest/ml/tracking/autolog/) functionality for popular ML frameworks
(TensorFlow, PyTorch, scikit-learn, etc.) while storing all data in the centralized Kubeflow Model Registry.

**Future Enhancements**: In subsequent phases, we may extend the plugin architecture to include:

- **Tracing Support**: Adding tracing capabilities akin to [MLflow](https://mlflow.org/docs/latest/genai/tracing/) would
  require new domain models in Model Registry.
- **Model Registry Store**: Further development could expose the Model Registry model registration functionality in the
  MLFlow SDK.

The primary objective remains enabling users to leverage MLFlow's mature ecosystem and familiar APIs while benefiting
from Kubeflow's centralized experiment tracking infrastructure.

#### Kubeflow SDK Implementation

Building on the MLFlow Model Registry plugin, we can enhance the Kubeflow SDK to provide a native Kubeflow-centric
experience. The initial implementation would focus on simplifying setup by automatically configuring the MLFlow Model
Registry plugin and creating convenient wrapper functions around the supported MLFlow SDK APIs. This integration should
feel cohesive with the existing Model Registry SDK functionality for registering models.

Enhancements could include:

- **Authentication**: Provide helpers for handling authentication with the Model Registry service, such as generating
  Kubernetes tokens.
- **Integrated UI Access**: Provide direct links to the Model Registry UI from within the Kubeflow SDK, making it easier
  for users to visualize and manage their experiments.
- **Discovery Services**: Automatically detect available Model Registry installations on the cluster and allow users to
  select one.
- **Local Experiments**: Enable users to work with local experiments and selectively publish them to the remote Model
  Registry backend.

This approach maintains compatibility with the mature MLFlow ecosystem while delivering a more cohesive experience that
feels native to the Kubeflow platform.

An example of the Kubeflow SDK with the MLFlow plugin could be the following:

```python
from kubeflow import tracking
import lm_eval
from lm_eval.utils import make_table
from transformers import AutoModelForCausalLM
import os

tracking.set_tracking_uri('modelregistry+https://model-registry.domain.local')

model = "vllm"
model_args = {
    "add_bos_token": True,
    "dtype": "bfloat16",
    "device": "auto",
    "max_model_len": 4096,
    "gpu_memory_utilization": 0.8,
    "pretrained": "my-model",
}

tracking.set_experiment("compression-eval")
with tracking.start_run(run_name="uncompressed-eval"):
    tracking.log_params({"model_id": "my-model", "limit": limit, "num_fewshot": num_fewshot, "tasks": "wikitext,gsm8k", "batch_size": "auto"})
    results = lm_eval.simple_evaluate(
        model=model,
        model_args=model_args,
        limit=1000,
        tasks=["wikitext", "gsm8k"],
        num_fewshot=2,
        batch_size="auto",
        log_samples=True,
    )
    print("lm_eval finished:\n", make_table(results))

    for task_name, task_results in results['results'].items():
        print(f"Processing metrics for task: {task_name}")
        print(f"Available metrics: {list(task_results.keys())}")

        # Log all available metrics for this task
        for metric_name, metric_value in task_results.items():
            if isinstance(metric_value, (int, float)):
                metric_key = f"{task_name}_{metric_name}"
                tracking.log_metric(metric_key, metric_value)
                print(f"Logged metric: {metric_key} = {metric_value}")
            elif isinstance(metric_value, dict):
                for sub_metric_name, sub_metric_value in metric_value.items():
                    if isinstance(sub_metric_value, (int, float)):
                        metric_key = f"{task_name}_{metric_name}_{sub_metric_name}"
                        tracking.log_metric(metric_key, sub_metric_value)
                        print(f"Logged nested metric: {metric_key} = {sub_metric_value}")
```

### Experiment Tracking UI Implementation

While the detailed design of the experiment tracking UI is beyond the scope of this proposal, the initial implementation
should provide a comprehensive interface for experiment management and visualization. The UI should have feature parity
with the existing Kubeflow Pipelines run comparison functionality while extending it to support all run sources
generically.

**Core UI Components:**

- **Experiments Overview Page**: A table-based interface listing all experiments with filtering capabilities (by name,
  creation date, metadata/tags, etc.) and sorting options. This serves as the primary entry point for users to discover
  and manage their experiments.

- **Experiment Detail View**: Clicking on an experiment navigates to a dedicated runs page that displays all runs
  associated with that experiment. The interface should support hierarchical run structures, allowing users to expand
  and collapse nested runs for better organization.

- **Run Management Interface**: The runs page should provide filtering capabilities including:

  - Fuzzy search by run name
  - Status-based filtering (running, completed, failed, etc.)
  - Time-based filtering (last hour, last day, custom date ranges)
  - Parameter and metric-based filtering

- **Visualizations**: The UI should offer multiple visualization options to help users analyze their experiments:
  - **Parallel Coordinates Plot**: Allow users to select specific runs, parameters, and metrics for multi-dimensional
    analysis
  - **Scatter Plots**: Visualize relationships between different parameters and metrics
  - **Radar Charts**: Compare multiple runs across different dimensions
  - **Custom Visualizations**: Support for rendering user-uploaded visualization artifacts (plots, charts, etc.)
    directly in the UI

### Test Plan

This is a high-level design with the intention that the test plans are covered in additional KEPs.

### Graduation Criteria

This is a high-level design with the intention that the each component covers graduation criteria in their respective
KEPs.

## Implementation History

N/A

## Drawbacks

1. **Complexity and Scope Creep**: Expanding Model Registry from a focused model lifecycle management tool to a
   comprehensive metadata store significantly increases its complexity and scope. This could make the system harder to
   understand, maintain, and debug.
1. **Competition**: There is a lot of competition in the experiment tracking space, but being an open-source project
   part of a Kubernetes native platform is a significant advantage for enterprise users.
1. **Resource Requirements**: The expanded Model Registry would require more computational resources, storage, and
   maintenance overhead compared to the current focused scope.

## Alternatives

### Just Leverage MLFlow

Instead of building our own experiment tracking solution, we could simply adopt MLFlow as the de facto experiment
tracking system for Kubeflow. This approach would involve integrating MLFlow directly into the Kubeflow ecosystem and
configuring it to work with Kubeflow's existing infrastructure.

**Advantages:**

- **Mature ecosystem**: MLFlow has a well-established community with over 747 million downloads and extensive
  documentation
- **Rich feature set**: MLFlow provides comprehensive experiment tracking, model registry, and deployment capabilities
  out of the box
- **Framework support**: Excellent integration with popular ML frameworks through automatic logging
- **Active development**: Unlike MLMD, MLFlow is actively maintained and regularly updated

**Challenges and Limitations:**

**Experience With MLMD**: While MLFlow is actively maintained, the current Kubeflow Pipelines dependency on MLMD creates
technical debt. MLMD has been in maintenance mode, limiting our ability to evolve the experiment tracking experience.
Simply switching to MLFlow would not address the core issue of being dependent on external projects outside the Kubeflow
ecosystem.

**RBAC/Multitenancy Approach Differences**: MLFlow's default multitenancy model differs significantly from Kubeflow's
namespace-based isolation approach. Kubeflow Pipelines currently provides namespace-level isolation using Kubernetes
RBAC, which is essential for enterprise deployments.

**Reduced Flexibility**: By fully adopting MLFlow, we would lose the ability to tailor the experiment tracking
experience specifically for Kubeflow's unique requirements. Having our own solution allows us to integrate more deeply
with other Kubeflow components and adapt to the community's evolving needs.

**Vendor Lock-in Concerns**: MLFlow is primarily maintained by Databricks, which could create concerns about vendor
lock-in and dependency on a single company's roadmap. While MLFlow is open source, the primary maintainers being from a
single vendor could influence the project's direction in ways that may not align with Kubeflow's community-driven
approach.

**Overlap With Model Registry**: Model Registry already has overlapping functionality with MLFlow, so changing course
now would require deprecating Model Registry and helping users migrate to MLFlow.

### Separate Service for Experiment Tracking

Instead of integrating experiment tracking into Model Registry, we could develop a completely independent experiment
tracking service within the Kubeflow ecosystem. This approach would create a dedicated service with its own API, UI, and
data storage, separate from the existing Model Registry infrastructure.

**Advantages:**

**Clean Architecture Separation**: A dedicated experiment tracking service would have a purpose-built schema and API
design, free from the legacy of Model Registry having adopted MLMD-based schemas.

**Preserved Model Registry Identity**: Model Registry could maintain its focused scope on model lifecycle management
without the complexity of experiment tracking features. This prevents scope creep and keeps the service's purpose clear
for users.

**Independent Evolution**: The experiment tracking service could evolve independently without being constrained by Model
Registry's existing API patterns, multitenancy models, or data storage requirements. This enables faster iteration and
feature development.

**Challenges and Limitations:**

**Increased Operational Overhead**: Kubeflow administrators would need to deploy, configure, and maintain yet another
service in their infrastructure. This adds complexity to the overall Kubeflow deployment and increases the learning
curve for new users.

**Fragmented User Experience**: Having experiment tracking as a separate service creates a disjointed experience where
users must navigate between different UIs and APIs to manage their ML workflows. This could lead to confusion and
reduced productivity.

**Metadata Silos**: The Kubeflow ecosystem would have multiple places where metadata is stored (Model Registry,
experiment tracking service, potentially others), making it difficult to establish relationships between experiments,
models, and deployments. This fragmentation could limit the ability to provide comprehensive ML lifecycle management.

**Adoption Barriers**: Existing Model Registry users would not automatically benefit from experiment tracking
capabilities. They would need to explicitly install and configure the new service, creating a barrier to adoption and
potentially leaving valuable functionality unused.

**Development Investment**: Building a separate service requires significant development resources, including API
design, UI development, data storage design, and integration with other Kubeflow components. This represents a
substantial investment compared to extending Model Registry.

**Ecosystem Fragmentation**: The Kubeflow ecosystem already has multiple services that users need to understand and
manage. Adding another service increases the cognitive load and could make Kubeflow appear more complex to potential
adopters.
