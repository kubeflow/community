# WG Feature Store Charter

This charter adheres to the conventions, roles and organization management outlined in [wg-governance].

## Scope

WG Feature Store covers the definition, management, storage, discovery, and serving of features to models.

### In scope

#### Code, Binaries and Services

- Provide a unified feature serving layer for both model training and online serving.
- Provide a registry for users to define and manage features, entity types, data sources, and their related metadata.
- Provide job management for the ingestion and persistence of both datasets and streams.
- Allow for feature statistic generation and for the validation of features in production.
- Provide the operational instrumentation necessary to safely run a feature store in production.
- Provide APIs, SDKs, and a user interface for all of the above.
- Documentation and tutorials on using a feature store in different Kubeflow use cases.

#### Cross-cutting and Externally Facing Processes

- Coordinating with Pipelines/KFData WG to ensure both datasets and streams can be ingested, persisted, and served.
- Coordinating with Training WG to make sure that its possible to create training datasets using the feature store.
- Coordinating with Serving WG to make sure that its possible to retrieve online feature data from the feature store.
- Coordinating with Control Plane WG to ensure that feature store manifests are properly deployed with Kubeflow.
- Coordinating with release teams to ensure that the feature store functionality can be released properly.

### Out of scope

- Data pipelining, immutability, and lineage.

## Roles and Organization Management

This WG follows adheres to the Roles and Organization Management outlined in [wg-governance]
and opts-in to updates and modifications to [wg-governance].

### Subproject Creation

WG Technical Leads.

[wg-governance]: ../wgs/wg-governance.md
