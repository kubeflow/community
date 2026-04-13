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
RBAC. Kubeflow should pair that with a supported MLflow image and deployment path so operators do not need to assemble
their own integration.

This direction also makes Kubeflow more relevant to the GenAI ecosystem. MLflow is investing heavily in GenAI experiment
tracking, tracing, and agent observability, so a strong Kubeflow integration helps the platform stay aligned with where
the broader open-source ML tooling ecosystem is going.

This KEP is intentionally platform-level. It defines the shared MLflow platform contract for Kubeflow: the supported
deployment model, namespace-to-workspace mapping, authentication and authorization model, and the UI hand-off
conventions. Component-specific behavior should be described in follow-up KEPs such as the in-flight Kubeflow Pipelines
proposal [KEP-12862](https://github.com/kubeflow/pipelines/blob/master/proposals/12862-mlflow-integration/README.md),
and those KEPs should reuse this contract rather than introduce separate MLflow integration patterns.

This KEP also sets a terminology direction for follow-up component work: the shared MLflow concept of an experiment
should remain platform-wide, and Kubeflow Pipelines should rename its current Experiment grouping to Run Group rather
than continue overloading the word "experiment". Katib or Kubeflow Optimizer follow-up work should rename to
`OptimizationJob` terminology, as discussed in the
[Kubeflow Optimization API design doc](https://docs.google.com/document/d/1Y8IJ-UdZ7VCEAlax_xEFbbqEi7EB6SfIX4D7ua-xn4M/edit),
rather than introducing another conflicting `Experiment` concept.

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

1. Make MLflow the first-class experiment tracking experience for Kubeflow users.
1. Donate and maintain Kubernetes-native MLflow plugins in Kubeflow so that MLflow integrates cleanly with namespaces,
   Profiles, and Kubernetes RBAC.
1. Offer a supported MLflow deployment story for Kubeflow operators, including a rebuilt MLflow image with the donated
   plugins preinstalled.
1. Support a shared multi-tenant MLflow deployment in which Kubernetes namespaces act as natural MLflow workspace
   boundaries, with Kubeflow Profile namespaces as the default platform mapping.
1. Improve Kubeflow's relevance for GenAI workflows by aligning with an experiment tracking ecosystem that is investing
   in tracing and agent observability.
1. Enable Kubeflow components to adopt the shared MLflow deployment and terminology model incrementally rather than
   requiring a full-platform rollout, with
   [KEP-12862](https://github.com/kubeflow/pipelines/blob/master/proposals/12862-mlflow-integration/README.md) serving
   as one concrete example already underway.
1. Provide an initial UI integration in which Kubeflow embeds MLflow views via iframe.

### Non-Goals

1. Expand Kubeflow Model Registry to become the experiment tracking backend for Kubeflow.
1. Design a brand-new Kubeflow-native experiment tracking service with its own API, storage model, and UI.
1. Implement the actual Pipelines `Run Group` and Katib or Kubeflow Optimizer / `OptimizationJob` terminology and UI
   migrations as part of this proposal. Follow-up component-specific work should align those experiences with the shared
   MLflow model described here.

## Proposal

### MLflow-First Vision

Kubeflow should package, integrate, and support MLflow directly rather than building a parallel experiment tracking
backend. The user-facing model should stay simple:

- users write to standard MLflow APIs
- operators deploy a supported MLflow installation for Kubeflow
- Kubeflow components discover and reuse that installation through common conventions
- Kubeflow embeds MLflow views inside Kubeflow UIs via iframe

### Donated Kubernetes Plugins

Kubeflow should accept donation of
[opendatahub-io/mlflow-kubernetes-plugins](https://github.com/opendatahub-io/mlflow-kubernetes-plugins) and treat that
codebase as the primary Kubernetes integration layer for MLflow in Kubeflow.

The donated work provides two important capabilities:

1. **Workspace provider**: maps MLflow workspaces to Kubernetes namespaces so that a shared MLflow deployment can serve
   multiple Kubeflow tenants while preserving namespace boundaries.
1. **Authorization plugin**: authorizes MLflow requests using Kubernetes identity and RBAC so that cluster-native access
   control remains the source of truth. It supports direct `SelfSubjectAccessReview` checks against caller tokens and a
   trusted-proxy `SubjectAccessReview` mode that consumes forwarded user and group headers.

By bringing these capabilities into Kubeflow, the community can evolve them in the open alongside Profiles, dashboard
integration, and component-specific adoption work.

The current repository is Apache-2.0 licensed, which is compatible with Kubeflow. Before Phase 1 is considered complete,
Kubeflow and OpenDataHub maintainers should agree on transferring the repository to Kubeflow community ownership, with
[`mprahl`](https://github.com/mprahl), [`HumairAK`](https://github.com/HumairAK), and any additional volunteers serving
as the initial maintainer group with clear release responsibilities.

### Kubeflow Profiles and Multi-tenancy

Kubeflow Profiles already give the platform a natural namespace-based tenancy model, but the MLflow plugins are not tied
to the Profile Controller itself. This proposal builds on the more general namespace model:

- a Kubernetes namespace becomes the MLflow workspace boundary
- in the default Kubeflow platform deployment, a Profile namespace supplies that boundary
- other namespace-based deployments can use the same mapping even if they do not install Profile Controller
- Kubernetes RBAC remains the source of truth for access decisions
- a shared MLflow deployment can serve many namespaces without abandoning isolation
- component UIs and SDKs should consistently map the active Kubeflow Profile or namespace to the default MLflow
  workspace

In practice, the workspace provider exposes tenant namespaces as MLflow workspaces, and the authorization plugin filters
or authorizes MLflow requests within the namespaces the caller is allowed to access. This is a better fit for Kubeflow
than a generic MLflow deployment that knows nothing about namespaces, service account tokens, or Profile-managed
multi-user clusters.

Existing namespaces can be opted into this model through plugin configuration such as
`MLFLOW_K8S_WORKSPACE_LABEL_SELECTOR`, so using MLflow workspaces with pre-existing namespaces does not require Profile
Controller.

### Deployment and Distribution

Kubeflow should not require every operator to build a custom MLflow image or invent their own deployment manifests.
Instead, it should ship as a composable add-on that can be installed alongside existing Kubeflow components, whether an
operator is running the full platform or only a subset such as Kubeflow Trainer plus a shared MLflow service. The
community should provide a supported distribution story with the following pieces:

1. A Kubeflow-published MLflow container image rebuilt from upstream MLflow and shipped with the donated Kubernetes
   plugins preinstalled.
1. A supported Helm-based deployment path. Kubeflow should prefer contributing the missing requirements upstream to
   [mlflow/mlflow#21973](https://github.com/mlflow/mlflow/pull/21973), where review feedback is already capturing several
   Kubeflow-specific needs. If the upstream chart cannot accommodate Kubeflow's plugin, deployment, and authentication
   requirements in time for Phase 1, Kubeflow should maintain its own chart or manifests only until the upstream path is
   sufficient.
1. Default Helm values that deploy MLflow into `kubeflow-system`. Operators that want stronger isolation should treat
   overriding this to a dedicated namespace such as `kubeflow-mlflow` as a best practice.
1. Kubeflow-specific documentation and examples covering the supported MLflow deployment pattern, multi-user
   authentication, Profiles integration, and any required Kubeflow packaging or configuration.
1. Version guidance that tells operators which MLflow version, plugin revision, and chart configuration are supported by
   each Kubeflow release. This proposal depends on MLflow `>= 3.11`: MLflow 3.10 introduced workspace support, which is
   a core dependency for the multi-tenant design, and MLflow 3.11 adds built-in
   [Kubernetes client authentication providers](https://mlflow.org/docs/latest/self-hosting/security/kubernetes/) that
   Kubeflow should reuse where possible.

### Kubeflow Component Integration Pattern

Kubeflow components that choose to integrate with MLflow should build on the shared deployment, auth, workspace, and
terminology model described in this KEP. This platform contract is intentionally standardized here so follow-up
component KEPs do not each need to re-solve tenancy, credentials, or UI hand-off independently.

The shared MLflow data model in this KEP is intentionally simple: an MLflow experiment is the cross-component container
for related work, and an MLflow run is the record of a single execution or logging session within that experiment.
[KEP-12862](https://github.com/kubeflow/pipelines/blob/master/proposals/12862-mlflow-integration/README.md) applies
that model to Kubeflow Pipelines by creating one parent MLflow run per KFP pipeline run and nested MLflow runs for
individual tasks and loop iterations.

The intended cross-component mapping is:

- MLflow experiment: the shared grouping for related work across Kubeflow tools
- Kubeflow Pipelines pipeline run: one parent MLflow run, with nested MLflow runs for component tasks and loop
iterations
- TrainJob or SparkApplication execution: one MLflow run for that execution
- Katib or Kubeflow Optimizer follow-up work:
  - Option 1: map each `OptimizationJob` to an MLflow experiment, and map each trial or execution created by that
    optimization job to an MLflow run in the experiment.
  - Option 2: let the user choose an MLflow experiment, map each `OptimizationJob` to a parent MLflow run in that
    experiment, and map each trial or execution to a nested MLflow run under the `OptimizationJob` parent run.

To avoid overloading the word "experiment" inside Kubeflow, follow-up component work should align user-facing
terminology with that shared model. In particular, this KEP sets the direction that KFP's current Experiment grouping
should be renamed to Run Group, while Katib or Kubeflow Optimizer follow-up work should rename to `OptimizationJob`
terminology, as discussed in the
[Kubeflow Optimization API design doc](https://docs.google.com/document/d/1Y8IJ-UdZ7VCEAlax_xEFbbqEi7EB6SfIX4D7ua-xn4M/edit),
instead of introducing another conflicting "experiment" concept.

### UI Strategy

The initial UI deliverable should be an embedded iframe experience in which Kubeflow loads full MLflow pages at
selected URLs inside Central Dashboard or other Kubeflow UIs.

Phase 1 should explicitly treat iframe embedding as a practical but limited integration model. With an unmodified
upstream MLflow UI, the embedded experience includes the full MLflow shell such as the header, sidebar, and navigation
to unrelated areas like Model Registry or Prompts. Because cross-origin iframes do not let Kubeflow rewrite MLflow's
DOM or CSS from the parent page, Kubeflow cannot reliably strip that surrounding UI or constrain navigation from the
iframe alone.

If Kubeflow redistributes MLflow with the donated plugins preinstalled, the published image may also carry small,
well-scoped UI patches that improve the embedded experience while keeping the primary behavior aligned with upstream
MLflow. A deeper integration model such as an upstream embed or kiosk mode, or a future module-federation approach,
remains the preferred long-term direction.

The embedded UI path should preserve enough context to load the correct workspace.

### User Stories

#### Story 1: Data Scientist Using Existing MLflow Workflows

As a data scientist adopting Kubeflow, I want to reuse existing MLflow capabilities such as autologging from notebooks
and Python scripts so that I can capture experiments in Kubeflow with minimal code changes and without learning a
Kubeflow-specific tracking API.

#### Story 2: ML Engineer Comparing Runs Across Kubeflow Components

As an ML engineer, I want experiment runs from notebooks, training jobs, and pipelines to land in the same MLflow
experiment so that I can compare results across workflows regardless of how those runs were executed.

#### Story 3: Platform Administrator Managing Multi-tenant Tracking

As a platform administrator, I want MLflow to follow Kubeflow's namespace-based tenancy model, including Profiles where
used, and Kubernetes RBAC so that multiple teams can share the same cluster and the same MLflow deployment without
leaking access across namespaces.

## Design Details

### Implementation Phases

#### Phase 1: Platform Foundation

- Donate the Kubernetes plugins into Kubeflow and establish ownership and release processes.
- Publish a supported MLflow image and deployment path.
- Document and support the Kubeflow-specific MLflow auth configuration, using trusted-header
  `subject_access_review` behind trusted ingress for both browser and machine-to-machine traffic.
- Define the default namespace-to-workspace mapping, with Profile namespaces as the default Kubeflow platform case.
- Provide an iframe-based embedded UI path from Kubeflow into MLflow and document the full-shell navigation
  limitations of that approach.

#### Phase 2: Component Adoption

- Align the first Kubeflow component integrations to the shared MLflow platform conventions.
- Use [KEP-12862](https://github.com/kubeflow/pipelines/blob/master/proposals/12862-mlflow-integration/README.md) as one
  example of component-specific adoption work.
- Publish the conventions other Kubeflow components should follow, including terminology guidance that avoids multiple
  unrelated "experiment" concepts in Kubeflow UIs.

### Authentication and Authorization

The core deployment model is a shared MLflow instance that understands Kubeflow tenancy.

At a high level:

1. A request originates from a notebook, pipeline workload, training job, or interactive user session running in a
   tenant namespace, typically one associated with a Kubeflow Profile in the default platform deployment.
1. Browser and API-server-mediated user requests reach MLflow through Kubeflow's trusted web auth path, which
   authenticates the user and forwards identity for downstream authorization.
1. Direct SDK, notebook, or workload requests can also reach that trusted ingress path with Kubernetes bearer tokens
   obtained from the caller's projected service account or kubeconfig context.
1. Trusted ingress validates supported JWTs, derives `kubeflow-userid` and `kubeflow-groups` from validated claims,
   and forwards those normalized headers to MLflow.
1. If authorized, MLflow serves the requested experiments, runs, metrics, and artifacts within the deployment's
   namespace-aware tenancy model.

Kubeflow components should reuse this shared authentication model rather than defining their own connection and identity
flow.

MLflow 3.11 improves this story with built-in Kubernetes client authentication providers documented in
[Kubernetes Authentication](https://mlflow.org/docs/latest/self-hosting/security/kubernetes/). Kubeflow should use
those providers where possible so SDK clients can authenticate to the trusted ingress path with Kubernetes credentials
instead of inventing a separate client-side auth layer. In particular,
`MLFLOW_TRACKING_AUTH=kubernetes` supports token-based authentication, and `MLFLOW_TRACKING_AUTH=kubernetes-namespaced`
also adds the workspace header derived from the current namespace.

For the supported Kubeflow deployment, the recommended MLflow server should run the authorization plugin in
`subject_access_review` mode behind Kubeflow's trusted ingress and configure the forwarded identity headers to match
Kubeflow conventions:

- `MLFLOW_K8S_AUTH_AUTHORIZATION_MODE=subject_access_review`
- `MLFLOW_K8S_AUTH_REMOTE_USER_HEADER=kubeflow-userid`
- `MLFLOW_K8S_AUTH_REMOTE_GROUPS_HEADER=kubeflow-groups`

In that mode, MLflow consumes the identity that Kubeflow already establishes at ingress and still asks Kubernetes to
authorize the requested action with `SubjectAccessReview`. This matches Kubeflow's existing multi-user pattern more
closely than requiring MLflow to authenticate every interactive request directly from a Kubernetes service account
token.

Kubeflow should use the same trusted-ingress pattern for machine-to-machine traffic as well. Rather than sending raw
bearer tokens directly to MLflow, trusted ingress should validate supported JWTs for both browser and machine-to-machine
requests, derive `kubeflow-userid` and `kubeflow-groups` from validated claims, and forward only those normalized
headers to MLflow.

A concrete example of that ingress pattern looks like:

```yaml
apiVersion: security.istio.io/v1beta1
kind: RequestAuthentication
metadata:
  name: mlflow-browser-jwt
  namespace: istio-system
spec:
  selector:
    matchLabels:
      app: istio-ingressgateway
  jwtRules:
  - issuer: https://dex.example.com
    outputClaimToHeaders:
    - header: kubeflow-userid
      claim: email
    - header: kubeflow-groups
      claim: groups
    fromHeaders:
    - name: Authorization
      prefix: "Bearer "
---
apiVersion: security.istio.io/v1beta1
kind: RequestAuthentication
metadata:
  name: mlflow-m2m-jwt
  namespace: istio-system
spec:
  selector:
    matchLabels:
      app: istio-ingressgateway
  jwtRules:
  - issuer: https://kubernetes.example.cluster
    jwksUri: http://cluster-jwks-proxy.istio-system.svc.cluster.local/openid/v1/jwks
    outputClaimToHeaders:
    - header: kubeflow-userid
      claim: sub
    - header: kubeflow-groups
      claim: groups
    fromHeaders:
    - name: Authorization
      prefix: "Bearer "
```

The exact issuers, claim mappings, and JWKS URIs are deployment-specific, but this is the same general pattern Kubeflow
manifests already use for browser and machine-to-machine JWT support at ingress. In this design, MLflow consumes only
the normalized identity headers, so the original bearer token does not need to be forwarded beyond ingress. MLflow
should be reachable only through that trusted ingress path, and the accompanying gateway or proxy configuration must
remove or overwrite any incoming `kubeflow-userid` or `kubeflow-groups` headers from the client before forwarding
requests to MLflow.

### Kubeflow Deployment Configuration

The main Kubeflow integration work is choosing and documenting a safe deployment topology. Kubeflow should publish a
supported pattern that:

1. Runs MLflow behind the trusted Kubeflow ingress path rather than exposing it directly.
1. Configures Istio `RequestAuthentication` or an equivalent trusted ingress layer to validate browser and
   machine-to-machine JWTs and translate authenticated identity into `kubeflow-userid` and `kubeflow-groups` headers
   for `subject_access_review`.
1. Ensures the gateway or proxy layer removes or overwrites any client-supplied `kubeflow-userid` and
   `kubeflow-groups` headers before forwarding requests to MLflow.
1. Grants the MLflow server service account permission to create
   `subjectaccessreviews.authorization.k8s.io`.
1. Documents how workload and SDK clients set the active MLflow workspace so the active tenant namespace maps cleanly
   to MLflow workspaces.
1. Documents the cluster-specific issuer and JWKS requirements needed for browser and machine-to-machine JWT validation
   at ingress.

Clusters may still need cluster-specific issuer or audience configuration for Kubernetes service account tokens, but the
Kubeflow packaging should make trusted-ingress JWT validation and header normalization the supported path rather than
leaving the machine-to-machine story implicit.

## Risks and Mitigations

1. **Dependency on upstream MLflow**: Kubeflow depends on a service from a different community. Mitigation: existing
   maintainer overlap between Kubeflow and MLflow improves the feedback loop for upstream changes, MLflow's Linux
   Foundation governance reduces single-vendor risk, and Kubeflow should publish version guidance for each release.
1. **Operational complexity**: A shared MLflow deployment is another service for operators to secure and upgrade.
   Mitigation: ship a supported install path with documented storage, auth, and upgrade guidance.
1. **Ingress identity normalization complexity**: The supported design depends on trusted ingress validating JWTs and
   translating them into `kubeflow-userid` and `kubeflow-groups` without allowing header spoofing.
   Mitigation: publish a supported ingress pattern with `RequestAuthentication`, require MLflow to be reachable only
   through that path, and explicitly document that the proxy must overwrite or strip client-supplied identity headers.
1. **Embedded UI limitations and maintainability**: Iframe embedding is a practical initial path, but it loads the full
   MLflow shell and may let users navigate to unrelated MLflow pages from within Kubeflow, which is less cohesive than a
   deeper upstream integration model.
   Mitigation: document this as an explicit Phase 1 limitation, keep Kubeflow entry points focused on the intended
   MLflow URLs, allow small redistribution-time UI patches if needed, and treat upstream embed or kiosk support,
   module federation, or other tighter integration models as future work.
1. **Terminology collision**: Kubeflow components already use "experiment" for different user-facing concepts.
   Mitigation: follow-up component KEPs should align on the shared MLflow definitions in this KEP, with KFP moving its
   current Experiment grouping toward Run Group and Katib or Kubeflow Optimizer moving toward `OptimizationJob`.

## Graduation Criteria

### Beta

- The Kubernetes plugins are transferred to Kubeflow community ownership.
- Kubeflow publishes a supported MLflow image and at least one supported deployment path.
- Namespace-scoped RBAC behavior is demonstrated in a multi-user environment.
- Kubeflow provides an iframe-based embedded path into MLflow.
- The supported deployment documents and demonstrates trusted-ingress JWT validation plus `subject_access_review`
  header mappings for browser and machine-to-machine traffic.

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
1. The initial iframe integration loads the full MLflow shell, so Kubeflow cannot fully control the embedded
   navigation experience without upstream MLflow changes or redistribution-time UI patches.
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
