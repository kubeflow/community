# Kubeflow Agent Integration Contract: Normative Contracts

This document describes what must happen when an agent uses a Kubeflow capability. It is written as a request flow so project teams can see where each responsibility belongs.

The words **MUST**, **MUST NOT**, and **MAY** are normative. Exact JSON Schemas, Kubernetes manifests, and test fixtures belong in implementation repositories and profile locks.

For the first milestone, the normative claim is limited to the Standalone Training core profile. Gateway integration, external MCP federation, additional capability packs, and multi-cluster behavior are extension profiles and are not required for the initial conformance claim.

## The request flow

```text
1. Discover a capability
2. Load its Skill and tool metadata
3. Resolve identity and scope
4. Preview a mutation
5. Obtain user approval
6. Execute the native operation
7. Follow native status and evidence
8. Retry safely or reconcile failures
```

This flow is specified first for Trainer. It is intended as a compatibility direction for KFP, KServe, Katib, Spark, Hub / Model Registry, Semantic Operator, and other adapters, which require their own approved profiles before they become conformant.

## 1. Responsibilities by layer

| Layer | Owns | Does not own |
| --- | --- | --- |
| Agent harness, such as Kagent | Model calls, planning, memory/context, tool selection, user interaction, and approval UI. | Kubernetes authorization or native resource lifecycle. |
| MCP client | MCP negotiation, request metadata, Skills/Tasks calls, retries, and transport. | Authority to grant access. |
| Agentgateway | Authentication, token exchange or impersonation, routing, policy, audit, and telemetry. | Operator status or model planning. |
| Kubeflow MCP adapter | Capability discovery, SDK/API translation, preview, confirmation verification, idempotency, and native references. | A new controller, lifecycle database, or universal state model. |
| Operator, controller, or service | Native resources, schemas, status, errors, scheduling, and data. | Agent-specific planning or prompt behavior. |

This KEP defines the interfaces between these layers. It does not require a particular model provider, prompt strategy, memory implementation, planning algorithm, or agent-quality score.

## 2. Protocol and discovery

The reference protocol is MCP `2026-07-28`. A conformant server MUST:

- support `server/discover`;
- support namespaced request metadata in `_meta`;
- declare and negotiate optional extensions explicitly;
- implement the Skills methods when Skills are advertised; and
- define a clear fallback when a client or backend lacks an optional extension.

The initial Skills contract requires `io.modelcontextprotocol/skills`, `skills/list`, `skills/get`, and `resources/read`. MCP Tasks are an extension and are not required by the first profile. Legacy session translation MAY be provided by Agentgateway, but stateful session affinity is not required by this KEP.

## 3. Capability and pack descriptions

The Standalone Training profile MUST expose a versioned capability resource such as:

```text
kubeflow://capabilities/<component>.json
```

The first descriptor MUST state the component and contract versions, status, usable tools and resources, Skills, Profile scope, authorization-filtered availability, and observation time. Feature gates, dependency graphs, optional integrations, and additional pack metadata belong to extension profiles.

Unavailable or unauthorized operations MUST NOT be advertised as usable. A degraded descriptor MUST explain the reason and expose only the operations that still work.

Capability descriptors MUST NOT be shared across authorization scopes without isolation. A cache MUST be private to the caller or keyed by actor, Profile, namespace, and policy revision, and MUST be invalidated when authorization or capability state changes. Conformance MUST verify that one scope cannot receive another scope's tools or capabilities.

The first profile uses one minimal lock for the Trainer adapter, including the MCP revision, identity model, SDK/API/CRD versions, image, and storage. Its proposed defaults are Kubernetes/OIDC identity, PostgreSQL durable storage, and a Standalone deployment. A full capability-pack manifest covering dependencies, topologies, lifecycle, and conformance evidence is an extension-profile requirement. A manifest never grants authority.

Existing external MCP servers, such as MLflow MCP or Feast MCP, MAY remain independent backends and be federated through Agentgateway. Federation does not make them Kubeflow adapters or transfer ownership of their native APIs, resources, status, or release lifecycle. A federated backend MUST satisfy the same identity, policy, naming, protocol, and conformance requirements claimed by the deployment.

## 4. Operator adapter rules

Every adapter MUST:

1. call a supported SDK or documented API;
2. preserve native validation, authorization, status, errors, and lifecycle;
3. return the authoritative native resource reference in additive response data;
4. preserve existing MCP tool names, required parameters, and shared response shapes;
5. declare supported versions and feature gates; and
6. provide unit, API/SDK, security, failure, and conformance fixtures.

Trainer and `TrainJob` are the first reference adapter. They demonstrate the contract and do not create Trainer-specific rules for other operators.

## 5. Skills and untrusted content

The first profile supports immutable, read-only Skills. Each Skill entry MUST include its `SKILL.md` URI, complete frontmatter, originating server, raw-byte SHA-256 digest, and byte size. A Skill name or URI scheme alone is not enough to identify it.

Kubeflow metadata MAY be carried in Agent Skills `metadata` frontmatter, but it MUST NOT redefine the Skills protocol. OCI packaging, signatures, attestations, and executable Skill sandboxing belong to a later supply-chain profile.

Skills, logs, events, model cards, datasets, traces, and other retrieved content are untrusted. They MUST NOT grant authorization, contain credentials, bypass confirmation, or change server policy. Executable Skills are outside the first profile.

## 6. Identity and authorization

The server MUST derive actor, Profile, namespace, persona, and native authorization from verified identity and server-side policy. A client MAY send untrusted selectors such as:

```json
{
  "_meta": {
    "io.kubeflow/request-id": "018f...",
    "io.kubeflow/profile-selector": "team-a",
    "io.kubeflow/namespace-selector": "team-a"
  }
}
```

Selectors may only choose exactly one scope already allowed for the authenticated actor. Zero, multiple, inconsistent, or unauthorized matches MUST fail closed. A selector never grants access.

Gateway identity MUST use an audience-bound credential exchange or trusted workload identity with explicit user impersonation. An MCP token MUST NOT be forwarded to Kubernetes, MLflow, or another resource server unless it was deliberately issued for that audience.

Authorization uses deny-overrides:

1. verified identity and native Kubernetes authorization define the maximum authority;
2. Profile and operator policy may restrict that authority;
3. MCP persona and tool policy may further restrict exposure; and
4. the harness may request less authority but can never grant more.

A denial at any layer is final and MUST not reveal unauthorized resource details.

## 7. Mutation safety

Every mutating operation MUST follow this sequence:

1. `confirmed=false` returns a preview;
2. the preview describes expected effects, policy warnings, resource/quota observations, expiry, and safety preconditions;
3. user approval binds the actor, Profile, tool, canonical arguments, `request_id`, and server-issued `plan_id`; and
4. `confirmed=true` executes only after server-side authorization and approval verification.

A model-authored `confirmed=true` is never proof of user approval. The server MUST generate an opaque `plan_id` when it creates a preview. The same `plan_id` remains valid for retries of the same `request_id` while the preview is unexpired and its safety preconditions remain unchanged. Changed canonical arguments, scope, or preconditions require a new preview and `plan_id`. A `plan_id` MUST NOT be accepted with another actor, Profile, namespace, tool, audience, or `request_id`.

For MCP `2026-07-28`, approval requiring user input MUST use Multi Round-Trip Requests: the server returns `input_required`, optionally containing an embedded `elicitation/create` request, and the client retries with `inputResponses` and the returned request state. The implementation MUST bind the response to the exact preview through MCP input handling or the harness's native approval surface. Legacy server-initiated elicitation MAY be supported only as a compatibility path. If approval cannot be bound to the exact preview, Gateway mutation conformance remains deferred or uses a versioned signed approval receipt. The receipt contract must define its signature algorithm, issuer, audience, key distribution, revocation, and replay rules.

## 8. Safe retries and stored state

`request_id` identifies one client intent. For confirmed mutations, the durable idempotency key MUST be scoped by authenticated actor, Profile, namespace, tool, audience, and `request_id`. The first profile uses a PostgreSQL-backed durable store; other stores require equivalent atomicity, recovery, and isolation evidence. The server MUST store previews, approvals, and completed request results in a shared durable store that survives restarts and multiple replicas. A request ID reused with a different scope MUST fail closed and MUST NOT return a result from another scope. The `plan_id` is distinct from `request_id`: the former identifies one preview and approval plan, while the latter identifies the client intent across retries.

The server MUST compare retries using RFC 8785 JSON Canonicalization Scheme followed by SHA-256 over the canonical UTF-8 bytes. The representation includes every semantic tool argument and excludes `confirmed`, approval receipts, trace context, and other transient metadata. Defaults and omitted values MUST be normalized before hashing.

An identical retry returns the original result. A changed request returns a conflict and MUST NOT create another resource. The store must support atomic writes, TTL, cleanup, recovery, concurrency control, privacy, and signing-key rotation.

## 9. Tasks and native resources

MCP Tasks provide durable handles for polling, reconnect, input, and cooperative cancellation, but are an extension profile. The first profile polls the native `TrainJob` resource directly; Tasks MUST NOT replace native operator resources.

The native resource remains authoritative when Task state and native state differ. The adapter MUST distinguish:

- native resource created and Task linked;
- native submission rejected and no resource created;
- submission outcome unknown and reconciliation required; and
- Task expired while the native resource remains observable.

The Trainer adapter MUST report native status and submission failures. Cancellation races, cross-operator partial effects, and distributed transaction semantics belong to later extension profiles.

## 10. Evidence, resources, and governance

Adapters MAY return immutable native references, opaque authorized evidence links, and additive correlation metadata. Full workflow and operation URIs belong in annotations, traces, or protected audit data, not Kubernetes labels or metric dimensions. Evidence links MUST reauthorize on dereference, expire when required, and contain no credentials.

OpenTelemetry and audit records MUST redact credentials and sensitive attributes and limit high-cardinality dimensions. Native status and evidence must remain usable when one continuous trace is unavailable.

Profiles MAY define resource, accelerator, queue, quota, and optional cost limits for mutating plans. A preview MUST distinguish an estimate from an admission guarantee. Retention, residency, data classification, and regulated-data controls belong to deployment-specific profiles.

## 11. Compatibility

The contract is additive at the integration boundary. Existing controller APIs, CRDs, SDK method names, required parameters, and native response semantics MUST remain compatible. MCP-specific behavior belongs in the adapter or optional Gateway layer and MUST NOT require every controller to understand agent approvals, Skills, Tasks, or planning state.

Adapters MAY use Kubernetes server-side dry-run or an operator's validation-only API to construct a preview. If no such operation exists, the adapter MUST construct the preview without creating or modifying a native resource.

Every supported topology and capability-pack combination MUST have a profile lock containing component, SDK/API/CRD, MCP, gateway, identity, image, Skill, storage, and feature-gate versions. Floating versions are not conformant.

Agentgateway federation MUST lock tool names, reject collisions, preserve Skill origin, and reject a backend that would downgrade the required MCP revision or extensions. Progressive and semantic tool modes remain outside the first conformance profile unless the inner tool identity and arguments are enforced at every authorization, approval, and audit boundary.
