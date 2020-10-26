# SIG Feature Store Charter

This charter adheres to the conventions, roles and organization management outlined in [wg-governance].

## Scope

SIG Feature Store covers the definition, management, storage, discovery, and serving of features to models.

### In scope

#### Product Functionality

This SIG aims to coordinate projects and technologies necessary to enable the core functionality required to deploy and operate a feature store in Kubeflow.

- Ensure that users have a registry to define and manage features and their related metadata.
- Ensure that users have a means of data ingestion, management, and storage for the purposes of model training and online serving.
- Ensure that users have a unified feature serving layer for both model training and online serving.
- Ensure that users have the ability to both generate and validate feature statistics.
- Ensure that users have operational instrumentation necessary to safely run a feature store in production.
- Ensure that users have the documentation and tutorials necessary to both deploy, operate, and use a feature store.
- Ensure that Kubeflow maintains a cohesive data tooling vision with respect to feature stores.

#### Cross-cutting and Externally Facing Processes

- Coordinating with Pipelines/KFData WG to ensure both datasets and streams can be ingested, persisted, and served.
- Coordinating with Training WG to make sure that its possible to create training datasets using the feature store.
- Coordinating with Serving WG to make sure that its possible to retrieve online feature data from the feature store.
- Coordinating with Manifests WG to ensure that feature store manifests are properly deployed with Kubeflow.
- Coordinating with release teams to ensure that the feature store functionality can be released properly.

### Out of scope

- Data pipelining, immutability, and lineage.

## Roles and Organization Management

This SIG follows adheres to the Roles and Organization Management outlined in [wg-governance]
and opts-in to updates and modifications to [wg-governance].

### Subproject Creation

SIG Technical Leads.

[wg-governance]: ../wgs/wg-governance.md
