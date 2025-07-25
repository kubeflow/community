# KEP-897: First-Class MLflow Integration for Experiment Tracking in Kubeflow

<!-- toc -->

- [Summary](#summary)
- [Motivation](#motivation)
  - [Background and History](#background-and-history)
  - [Goals](#goals)
  - [Non-Goals](#non-goals)
- [Proposal](#proposal)
  - [MLflow-First Vision](#mlflow-first-vision)
  - [Donated Kubernetes Plugins](#donated-kubernetes-plugins)
  - [Kubeflow Profiles and Multi-tenancy](#kubeflow-profiles-and-multi-tenancy)
  - [Deployment and Distribution](#deployment-and-distribution)
  - [Kubeflow Component Integration Pattern](#kubeflow-component-integration-pattern)
  - [UI Strategy](#ui-strategy)
  - [User Stories](#user-stories)
- [Design Details](#design-details)
  - [Implementation Phases](#implementation-phases)
  - [Authentication and Authorization](#authentication-and-authorization)
  - [Kubeflow Deployment Configuration](#kubeflow-deployment-configuration)
- [Risks and Mitigations](#risks-and-mitigations)
- [Graduation Criteria](#graduation-criteria)
- [Implementation History](#implementation-history)
- [Drawbacks](#drawbacks)
- [Alternatives](#alternatives)
  - [Expand Model Registry](#expand-model-registry)
<!-- /toc -->

## Summary

Kubeflow should make MLflow the first-class experiment tracking experience across the platform. Rather than trying to
compete with established experiment trackers by building a new backend inside Kubeflow, the community should deeply
integrate with a strong open-source option and package it in a Kubernetes-native way that fits Kubeflow's multi-tenant
operating model.

This proposal centers on donating the Kubernetes integration work from
[opendatahub-io/mlflow-kubernetes-plugins](https://github.com/opendatahub-io/mlflow-kubernetes-plugins) into Kubeflow,
using those plugins to map MLflow workspaces to Kubernetes namespaces and authorize MLflow requests with Kubernetes
RBAC. Kubeflow should pair that with a supported MLflow image and deployment path so operators do not need to
assemble their own integration.

This direction also makes Kubeflow more relevant to the GenAI ecosystem. MLflow is investing heavily in GenAI experiment
tracking, tracing, and agent observability, so a strong Kubeflow integration helps the platform stay aligned with where
the broader open-source ML tooling ecosystem is going.

This KEP is intentionally platform-level. Component-specific behavior should be described in follow-up KEPs such as the
in-flight Kubeflow Pipelines proposal
[KEP-12862](https://github.com/kubeflow/pipelines/blob/master/proposals/12862-mlflow-integration/README.md), and other
Kubeflow components can follow the same shared MLflow conventions.

## Motivation

Experiment tracking in Kubeflow is fragmented across component-specific experiences. A user may train from a Notebook,
launch a job with Kubeflow Trainer, and orchestrate end-to-end workflows with Kubeflow Pipelines, yet still have no
standard way to view those runs together using the same tracking backend and user experience.

That fragmentation creates several problems:

1. **Limited flexibility**: Users often want to log runs directly from Python scripts, Jupyter notebooks, or training
   jobs using established experiment trackers rather than forcing everything through one Kubeflow component.
1. **Inconsistent setup**: Users who bring an external experiment tracker into Kubeflow today must manually wire
   endpoints, credentials, tenancy boundaries, and UI links for themselves.
1. **Fragmented experience**: Users must navigate different UIs and metadata conventions depending on whether the work
   came from a notebook, a pipeline, Katib, or another component.
1. **Platform gap**: Kubeflow does not yet offer a first-class platform story for shared experiment tracking.
1. **GenAI relevance gap**: As experiment tracking platforms expand into tracing and agent observability, Kubeflow risks
   feeling less relevant to modern GenAI workflows if it does not integrate deeply with one of those ecosystems.

Kubeflow does not need to invent a new backend to solve this. MLflow already provides the experiment tracking model,
ecosystem, and user workflows that many Kubeflow users expect. The missing piece is a Kubeflow-owned integration layer
that makes MLflow feel native on a multi-tenant Kubernetes platform.

### Background and History

- 2019 — The community proposed making metadata management a first-class Kubeflow concern. See
  [Create a kubeflow/metadata repository (Issue #238)](https://github.com/kubeflow/community/issues/238).
- 2022 — The community revisited unified metadata and artifact tracking across Kubeflow components. See
  [Kubeflow component integration with ML Metadata (Issue #783)](https://github.com/kubeflow/community/issues/783).
- Since then, Kubeflow components have continued to evolve with different experiment-tracking expectations. Over the
  same period, MLflow matured as a widely adopted experiment-tracking system and added
  [workspace-based multi-tenancy support](https://mlflow.org/docs/latest/self-hosting/workspaces/getting-started/) in
  [MLflow 3.10](https://mlflow.org/docs/3.10.1/). That addressed the main gap that had prevented broader adoption in
  multi-user Kubeflow deployments.

This KEP takes a new direction from earlier metadata discussions: Kubeflow should not try to compete with established
experiment trackers. Instead, Kubeflow should deeply integrate with a strong open-source option with an active
community, and focus its own effort on Kubernetes-native integration, packaging, and consistent cross-component adoption
patterns.

### Goals

1. Adopt MLflow as the primary experiment tracking integration for Kubeflow users.
1. Donate and maintain Kubernetes-native MLflow plugins in Kubeflow so that MLflow integrates cleanly with namespaces,
   Profiles, and Kubernetes RBAC.
1. Offer a supported MLflow deployment story for Kubeflow operators, including a rebuilt MLflow image with the donated
   plugins preinstalled.
1. Support a shared multi-tenant MLflow deployment in which profile namespaces act as natural MLflow workspace
   boundaries.
1. Improve Kubeflow's relevance for GenAI workflows by aligning with an experiment tracking ecosystem that is investing
   in tracing and agent observability.
1. Provide a path for Kubeflow components to integrate with the shared MLflow deployment over time, with
   [KEP-12862](https://github.com/kubeflow/pipelines/blob/master/proposals/12862-mlflow-integration/README.md) serving
   as one concrete example already underway.
1. Provide a clear UI strategy in which Kubeflow either embeds MLflow or links users out to the MLflow UI.

### Non-Goals

1. Expand Kubeflow Model Registry to become the experiment tracking backend for Kubeflow.
1. Design a brand-new Kubeflow-native experiment tracking service with its own API, storage model, and UI.
1. Rework Pipelines' or Katib's current experiment model as part of this proposal.

## Proposal

### MLflow-First Vision

Kubeflow should package, integrate, and support MLflow directly rather than building a parallel experiment tracking
backend. The user-facing model should stay simple:

- users write to standard MLflow APIs
- operators deploy a supported MLflow installation for Kubeflow
- Kubeflow components discover and reuse that installation through common conventions
- the Kubeflow dashboard either embeds the MLflow UI or links to it

### Donated Kubernetes Plugins

Kubeflow should accept donation of
[opendatahub-io/mlflow-kubernetes-plugins](https://github.com/opendatahub-io/mlflow-kubernetes-plugins) and treat that
codebase as the primary Kubernetes integration layer for MLflow in Kubeflow.

The donated work provides two important capabilities:

1. **Workspace provider**: maps MLflow workspaces to Kubernetes namespaces so that a shared MLflow deployment can serve
   multiple Kubeflow tenants while preserving namespace boundaries.
1. **Authorization plugin**: authorizes MLflow requests using Kubernetes identity and RBAC so that cluster-native access
   control remains the source of truth.

By bringing these capabilities into Kubeflow, the community can evolve them in the open alongside Profiles, dashboard
integration, and component-specific adoption work.

The current repository is Apache-2.0 licensed, which is compatible with Kubeflow. Before Phase 1 is considered complete,
Kubeflow and OpenDataHub maintainers should agree on transferring the repository to Kubeflow community ownership, with
clear approvers and release responsibilities.

### Kubeflow Profiles and Multi-tenancy

Kubeflow Profiles already give the platform a natural namespace-based tenancy model. This proposal builds directly on
that model:

- a profile namespace becomes the default MLflow workspace boundary
- Kubernetes RBAC remains the source of truth for access decisions
- a shared MLflow deployment can serve many namespaces without abandoning isolation
- component UIs and SDKs should consistently map the active Kubeflow Profile or namespace to the default MLflow
  workspace

This is a better fit for Kubeflow than a generic MLflow deployment that knows nothing about namespaces, service account
tokens, or Profile-managed multi-user clusters.

### Deployment and Distribution

Kubeflow should not require every operator to build a custom MLflow image or invent their own deployment manifests.
Instead, the community should provide a supported distribution story with the following pieces:

1. A Kubeflow-published MLflow container image rebuilt from upstream MLflow and shipped with the donated Kubernetes
   plugins preinstalled.
1. A supported Helm-based deployment path. Kubeflow should prefer contributing the missing requirements upstream to
   [mlflow/mlflow#21973](https://github.com/mlflow/mlflow/pull/21973). If the upstream chart cannot accommodate the
   Kubernetes plugins, workspace configuration, and multi-tenant auth requirements in time for Phase 1, Kubeflow should
   maintain its own chart or manifests until the upstream path is sufficient.
1. Kubeflow-specific documentation and examples covering the supported MLflow deployment pattern, multi-user
   authentication, Profiles integration, and any required Kubeflow packaging or configuration.
1. Version guidance that tells operators which MLflow version, plugin revision, and chart configuration are supported by
   each Kubeflow release. This proposal depends on MLflow `>= 3.10`, since MLflow 3.10 includes workspace support, which
   is a core dependency for the multi-tenant design. As MLflow 3.11 lands, Kubeflow should also adopt its built-in
   Kubernetes client authentication providers where possible.

### Kubeflow Component Integration Pattern

Kubeflow components that choose to integrate with MLflow should build on the shared deployment, auth, and workspace
model described in this KEP. Component-specific behavior should remain in follow-up KEPs such as
[KEP-12862](https://github.com/kubeflow/pipelines/blob/master/proposals/12862-mlflow-integration/README.md).

### UI Strategy

The UI strategy for MLflow integration should be explicit and limited to two supported modes:

1. **Launch-out link**: Kubeflow surfaces links such as "Open in MLflow" from notebooks, training jobs, pipelines, or
   dashboard pages. This is the simpler near-term path and uses the MLflow UI directly.
1. **Embedded MLflow experience**: Kubeflow embeds the MLflow UI, or selected MLflow views, inside the Kubeflow
   dashboard for a more cohesive experience.

The embedded option is compelling, but it requires upstream MLflow work to make React module federation or a similarly
maintainable embedding model easier. For that reason, the initial Kubeflow integration should assume that launch-out is
always available, while embedded UI remains a more deeply integrated option if we pursue it.

When Kubeflow launches users into MLflow, it should preserve enough context to land them in the correct workspace,
experiment, or run view.

### User Stories

#### Story 1: Data Scientist Using Existing MLflow Workflows

As a data scientist adopting Kubeflow, I want to reuse existing MLflow capabilities such as autologging from notebooks
and Python scripts so that I can capture experiments in Kubeflow with minimal code changes and without learning a
Kubeflow-specific tracking API.

#### Story 2: ML Engineer Comparing Runs Across Kubeflow Components

As an ML engineer, I want experiment runs from notebooks, training jobs, and pipelines to land in the same MLflow
experiment so that I can compare results across workflows regardless of how those runs were executed.

#### Story 3: Platform Administrator Managing Multi-tenant Tracking

As a platform administrator, I want MLflow to follow Kubeflow Profiles and Kubernetes RBAC so that multiple teams can
share the same cluster and the same MLflow deployment without leaking access across namespaces.

## Design Details

### Implementation Phases

#### Phase 1: Platform Foundation

- Donate the Kubernetes plugins into Kubeflow and establish ownership and release processes.
- Publish a supported MLflow image and deployment path.
- Document and support the Kubeflow-specific MLflow auth configuration, including trusted-header
  `subject_access_review` mode.
- Define the default Profile-to-workspace mapping.
- Provide a launch-out UI path from Kubeflow into MLflow.

#### Phase 2: Component Adoption

- Align the first Kubeflow component integrations to the shared MLflow platform conventions.
- Use [KEP-12862](https://github.com/kubeflow/pipelines/blob/master/proposals/12862-mlflow-integration/README.md) as one
  example of component-specific adoption work.
- Publish the conventions other Kubeflow components should follow.

### Authentication and Authorization

The core deployment model is a shared MLflow instance that understands Kubeflow tenancy.

At a high level:

1. A request originates from a notebook, pipeline workload, training job, or interactive user session running in a
   namespace associated with a Kubeflow Profile.
1. The caller authenticates to MLflow using either projected Kubernetes service account credentials for workloads or the
   existing Kubeflow web identity path for interactive users.
1. The authorization plugin validates that identity and checks Kubernetes RBAC for the requested MLflow operation.
1. If authorized, MLflow serves the requested experiments, runs, metrics, and artifacts within the deployment's
   namespace-aware tenancy model.

Kubeflow components should reuse this shared authentication model rather than defining their own connection and identity
flow.

The upcoming MLflow 3.11 release improves this story with built-in Kubernetes client authentication providers documented
in [Kubernetes Authentication](https://mlflow.org/docs/3.11.0rc0/self-hosting/security/kubernetes/). Kubeflow should use
those providers where possible instead of inventing its own client-side auth layer. In particular,
`MLFLOW_TRACKING_AUTH=kubernetes` supports token-based authentication, and `MLFLOW_TRACKING_AUTH=kubernetes-namespaced`
also adds the workspace header derived from the current namespace.

For the typical Kubeflow browser and interactive-user path, the recommended deployment should run the authorization
plugin in `subject_access_review` mode behind Kubeflow's trusted ingress and configure the forwarded identity headers to
match Kubeflow conventions:

- `MLFLOW_K8S_AUTH_AUTHORIZATION_MODE=subject_access_review`
- `MLFLOW_K8S_AUTH_REMOTE_USER_HEADER=kubeflow-userid`
- `MLFLOW_K8S_AUTH_REMOTE_GROUPS_HEADER=kubeflow-groups`

In that mode, MLflow consumes the identity that Kubeflow already establishes at ingress and still asks Kubernetes to
authorize the requested action with `SubjectAccessReview`. This matches Kubeflow's existing multi-user pattern more
closely than requiring MLflow to authenticate every interactive request directly from a Kubernetes service account
token.

### Kubeflow Deployment Configuration

The main Kubeflow integration work is deployment configuration rather than a missing authorization-plugin capability.
Kubeflow should publish a supported pattern that:

1. Runs MLflow behind the trusted Kubeflow ingress path rather than exposing it directly.
1. Configures the MLflow authorization plugin for `subject_access_review` using `kubeflow-userid` and
   `kubeflow-groups`.
1. Grants the MLflow server service account permission to create `subjectaccessreviews.authorization.k8s.io`.
1. Documents how workload and SDK clients set the active MLflow workspace so Profile namespaces map cleanly to MLflow
   workspaces.

Clusters may still choose to support direct Kubernetes-token-based machine-to-machine access where token issuer or
audience configuration matters, but that is not a fundamental blocker for Kubeflow's primary multi-user deployment
model.

## Risks and Mitigations

1. **Dependency on upstream MLflow**: Kubeflow depends on a service from a different community. Mitigation: existing
   maintainer overlap between Kubeflow and MLflow improves the feedback loop for upstream changes, MLflow's Linux
   Foundation governance reduces single-vendor risk, and Kubeflow should publish version guidance for each release.
1. **Operational complexity**: A shared MLflow deployment is another service for operators to secure and upgrade.
   Mitigation: ship a supported install path with documented storage, auth, and upgrade guidance.
1. **Trusted-header deployment risk**: `subject_access_review` mode depends on MLflow trusting headers set by Kubeflow's
   ingress path.
   Mitigation: publish a supported deployment that routes MLflow only through trusted ingress, configures the Kubeflow
   header names explicitly, and documents the required Kubernetes RBAC for `SubjectAccessReview`.
1. **Embedded UI complexity**: A deeply embedded MLflow UI may be hard to maintain until upstream integration improves.
   Mitigation: keep launch-out as the baseline and treat embedding as a more deeply integrated option if we pursue it.

## Graduation Criteria

### Beta

- The Kubernetes plugins are transferred to Kubeflow community ownership.
- Kubeflow publishes a supported MLflow image and at least one supported deployment path.
- Namespace-scoped RBAC behavior is demonstrated in a multi-user environment.
- Kubeflow provides a launch-out path into MLflow.
- The supported deployment documents and demonstrates `subject_access_review` mode with Kubeflow header mappings.

### Stable

- The supported installation and upgrade story is exercised regularly in release qualification.
- Integration testing in a Kubeflow platform deployment gates Kubeflow releases.

## Implementation History

- 2026-03-31: Reframed this KEP from a Model Registry-centered experiment tracking design to an MLflow-first Kubeflow
  integration proposal.
- 2026-03-31: Superseded the earlier unimplemented direction in this KEP; no user migration is required because the
  previous design did not ship as a supported Kubeflow feature.

## Drawbacks

1. Kubeflow becomes more dependent on the upstream MLflow roadmap and release cadence for experiment tracking features.
1. Operators still need to run and maintain a shared MLflow service, even if Kubeflow improves the packaging story.
1. The best integrated UI experience may depend on upstream MLflow changes that Kubeflow does not control outright.
1. Some users may prefer a more deeply Kubeflow-specific experiment tracking experience than an MLflow-first design
   provides.

## Alternatives

### Expand Model Registry

Kubeflow could continue with the earlier direction of enhancing Model Registry to become the experiment tracking backend
for the platform.

**Benefits:**

- Kubeflow would own the full backend and UI stack for experiment tracking.
- The project could optimize the design around Kubeflow-specific concepts without depending on external MLflow roadmap
  decisions.

**Downsides:**

- It would require Kubeflow to build and maintain another large backend capability that MLflow already provides.
- Users who already depend on MLflow APIs and UI would still need an additional translation or migration story.
- The community would spend effort recreating mature MLflow functionality instead of making MLflow Kubernetes-native for
  Kubeflow.

This alternative was rejected because Kubeflow's leverage is higher when it focuses on integration, packaging, and
multi-tenancy rather than rebuilding experiment tracking from scratch inside another Kubeflow service.
