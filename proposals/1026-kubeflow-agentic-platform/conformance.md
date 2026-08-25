# Kubeflow Agent Integration Contract: Conformance and Graduation

This document defines the evidence required to claim a topology or capability pack under this KEP.

## Conformance matrix

| Axis | Selection | Required evidence |
| --- | --- | --- |
| Topology | Standalone | Direct authenticated MCP access, Profile policy, Skills, preview/confirmation, idempotency, and native status. |
| Topology | Gateway | Standalone evidence plus Kagent, Agentgateway, audience-bound identity delegation, policy, audit, stateless MCP, and OpenTelemetry. |
| Capability pack | Training core | Trainer reference adapter, native `TrainJob` submission/status, progress, metrics, checkpoints, and failure behavior. |
| Capability pack | Kueue | Separately approved queue/quota/admission adapter and fixtures. Optional; not implied by generic cluster inspection. |
| Capability pack | Lifecycle | Individually approved Pipelines, MLflow, Kubeflow Hub / Model Registry, KServe, or other operator adapters. |

Each release claims only combinations represented by a checked-in lock file. The lock pins Kubernetes and component versions, image and Skill digests, CRDs and manifests, SDK/API/framework versions, MCP revision and extensions, tool mode, gateway naming, identity issuer/audiences, storage, and feature gates.

## Installation checks

1. Install the locked topology and create two isolated Profiles and namespaces.
2. Install only the clients and capability packs selected by the lock.
3. For Gateway, install Kagent, Agentgateway, default-deny policy, identity exchange or impersonation, NetworkPolicies, and the OpenTelemetry collector.
4. Verify `server/discover`, Skills methods, Tasks negotiation, capability descriptors, authorization-sensitive caching, and trace export.
5. Verify Skill manifests, signatures/attestations, OCI provenance where Kagent is used, and sandbox/egress policy.
6. Verify that the selected MCP framework passes the locked `2026-07-28` protocol and extension fixtures.

## Golden paths

### Reference mutation

1. Resolve the verified actor, Profile, namespace, persona, and active Skill.
2. Discover the operator capability and validate arguments through its native SDK/API.
3. Return a preview with expected effects, policy warnings, observations, and preconditions.
4. Obtain explicit approval bound to the exact intent.
5. Execute the native mutation with `confirmed=true` and return its immutable reference.
6. Retry the same intent and verify the original result is returned without a duplicate resource.

### Reference observation

Follow the native resource's conditions, events, logs, metrics, checkpoints, traces, and evidence links. If Tasks are negotiated, also verify polling, reconnect, `input_required`, cancellation, expiry, and final result retrieval. Tasks must never replace native status.

### Operator extension

Install one approved operator adapter alongside the Training core. Verify its native resource mapping, read operations, mutation preview, confirmation, error behavior, authorization, evidence links, and independent failure mode. Do not claim cross-component transactionality.

## Security tests

- Unauthenticated and wrong-audience requests are rejected.
- Deny-overrides behavior is proven across harness, gateway, MCP persona, Profile/RBAC, Kubernetes, and operator policy layers.
- A user cannot access another Profile, namespace, workspace, model, run, trace, artifact, or endpoint.
- A read-only persona cannot execute mutations.
- User-supplied actor, persona, Profile, or namespace values cannot expand authority.
- Preview cannot mutate resources before confirmation.
- Missing, expired, tampered, wrong-actor, wrong-Profile, changed-argument, or wrong-audience approvals are rejected.
- Reusing `request_id` across actors, Profiles, tools, or changed arguments cannot replay a result.
- Gateway policy cannot be bypassed through alternate target names, Skills, resources, prompts, or meta-tools.
- Incompatible federation targets cannot rename existing tools or downgrade the locked protocol/extensions.
- Skill digest, size, frontmatter, signature, provenance, sandbox, secret, and egress violations are rejected.
- Logs, events, model cards, datasets, traces, and Skills cannot alter authorization, confirmation, or tool arguments.
- Credentials, approval receipts, and sensitive trace attributes do not enter normal model context or logs.
- Task/native-resource races, unknown submission outcomes, expired Tasks, cancellation races, and partial cross-operator effects are classified correctly.
- Resource, accelerator, queue, quota, cost, retention, and residency limits are enforced where claimed by the profile.

## Required artifacts by owner

| Owner | Evidence |
| --- | --- |
| `kubeflow/mcp-server` | Additive schemas/metadata, valid/invalid fixtures, compatibility tests, Trainer reference tests, and direct MCP conformance. |
| Trainer and SDK owners | Trainer 2.3 / SDK 0.5 API mapping, status/progress fixtures, and version compatibility evidence. |
| Kagent and Agentgateway owners | Identity delegation, default-deny policy, approval integration, stable naming, sessionless MCP, Skill handling, audit, and trace fixtures. |
| Agent harness owner | Harness/runtime boundary, approval surface, context/memory behavior, MCP client compatibility, and user-interaction evidence. |
| Each operator/service owner | Approved adapter mapping, supported versions, native references/status, mutation semantics, failure tests, and security review. |
| Participating distribution | Accepted topology/pack lock, manifests, installation overlay, upgrade job, and release qualification. |

## Graduation gates

| Stage | Gate |
| --- | --- |
| Provisional | Sponsoring group accepts the problem and scope; intended owner and component liaisons are recorded. |
| Implementable | Named owners approve the contracts and implementation plan; a design prototype and locked Trainer 2.3 / SDK 0.5 compatibility evidence make implementation risk acceptable. |
| Alpha | Standalone plus Training core passes installation, discovery, Skills, Profile policy, preview/confirmation, idempotency, and native-status tests. |
| Beta | Gateway passes delegated identity, policy, audit, stateless MCP, Tasks, Skills manifests, approval, and OpenTelemetry tests. |
| Stable | A participating distribution supports a locked topology and pack across two consecutive releases with upgrade and security evidence. |
| Additional capability pack | Its owner approves the contract and its independent conformance suite passes for every topology it claims. |

## Explicit exclusions from first conformance

- A2A delegation and Agent Cards.
- Multi-cluster identity, routing, and operation semantics.
- Progressive and semantic tool modes unless inner-tool policy is fully specified.
- Unapproved KFP, MLflow, Hub/Model Registry, KServe, Katib, Spark, or Semantic Operator adapters.
