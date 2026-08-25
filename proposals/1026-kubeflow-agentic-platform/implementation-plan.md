# Kubeflow Agent Integration Contract: Implementation Plan

This document translates this KEP's architecture and contracts into executable work. It is a planning document, not a replacement for the normative contracts in [contracts.md](contracts.md) or the evidence requirements in [conformance.md](conformance.md).

## Implementation strategy

Build one narrow, end-to-end reference path first:

```text
MCP 2026-07-28
  to Skills and Tasks
  to Trainer adapter
  to Profile authorization
  to preview and approval
  to durable idempotency
  to native TrainJob status
  to Gateway conformance
```

Trainer is the first adapter because it is already implemented and exercises mutation, asynchronous status, progress, metrics, checkpoints, and native resource references. The implementation must keep the adapter interfaces operator-neutral so another operator can add a capability pack without changing the core security or protocol contract.

## Workstreams

### 0. Runtime and harness boundary

Owners: Kagent or another approved harness, MCP client owners, `kubeflow/mcp-server`, and the participating distribution

Deliverables:

- document the boundary between the harness, MCP client, Agentgateway, adapter, and operator;
- select the reference harness and approval surface, and define MCP client retry, timeout, cancellation, reconnect, and state behavior.

Exit criteria:

- a second MCP host can exercise the contract without changing operator semantics;
- the harness cannot grant more authority than verified identity and native policy allow, and approval boundaries are observable.

### 1. MCP server foundation

Repository: `kubeflow/mcp-server`

Deliverables:

- migrate to a framework/runtime that passes MCP `2026-07-28` protocol fixtures, or implement an explicit compatibility layer;
- implement `server/discover`, request `_meta`, Skills methods, and negotiated Tasks;
- preserve existing tool names, parameters, personas, and response shapes;
- publish versioned capability descriptors;
- expose operator modules through the existing module export contract;
- add protocol, schema, and backward-compatibility fixtures.

Exit criteria:

- Standalone direct MCP tests pass;
- existing Trainer contract tests remain green;
- unsupported revisions and extensions fail predictably;
- no capability is advertised unless installed, authorized, and usable.

### 2. Operator-neutral adapter API

Repository: `kubeflow/mcp-server` and the future shared contract location

Deliverables:

- machine-readable schemas for capability descriptors, native resource references, context, evidence links, and additive response data;
- a versioned capability-pack manifest covering dependencies, supported topologies, exposed surfaces, security scopes, and upgrade/deprecation behavior;
- adapter registration and version negotiation;
- a documented mapping from native SDK/API calls to MCP tools;
- common error, status, correlation, and authorization test helpers;
- an operator adapter template.

Exit criteria:

- a second mock adapter can implement the contract without Trainer-specific fields;
- schemas validate both valid and invalid fixtures;
- native status remains available without a universal lifecycle translation.

### 3. Trainer reference adapter

Repositories: `kubeflow/mcp-server`, Kubeflow SDK, and Trainer

Deliverables:

- lock the first supported Trainer and SDK versions, initially Trainer 2.3 and SDK 0.5;
- map `TrainJob`, Runtime, progress, metrics, checkpoints, and optimization capabilities;
- preserve native conditions, events, logs, and resource references;
- implement preview output with resource, quota, policy, and precondition information;
- add submit, observe, failure, retry, cancellation, and recovery fixtures.
- add native-submission/Task race, unknown-outcome, expiry, and partial-effect fixtures.

Exit criteria:

- the full Standalone Training core path passes on a locked cluster;
- duplicate confirmed requests do not create duplicate resources;
- changed arguments or changed safety preconditions return a conflict and fresh preview.

### 4. Identity, Profile, and authorization

Repositories: `kubeflow/mcp-server`, Kagent, Agentgateway, and the participating distribution

Deliverables:

- server-side mapping from authenticated subject/groups to allowed Profiles and namespaces;
- namespaced Profile and namespace selector handling as untrusted hints;
- persona filtering that never expands native authorization;
- audience, issuer, subject, expiry, and impersonation validation;
- two-user isolation fixtures and cross-Profile denial tests.

Exit criteria:

- direct Standalone HTTP and Gateway identity behavior are documented separately;
- no user-supplied actor, persona, Profile, or namespace value grants authority;
- wrong-audience and ambiguous-scope requests fail closed.

### 5. Preview, approval, and idempotency

Repositories: `kubeflow/mcp-server`, Kagent integration, and the selected persistence component

Deliverables:

- deterministic canonical argument encoding;
- durable preview records with bound resource versions and safety observations;
- signed approval receipt or an equivalent server-verifiable approval mechanism;
- explicit evaluation of MCP Elicitation and the selected harness approval surface;
- durable HA storage with atomic create, replay, conflict, TTL, cleanup, and recovery behavior;
- key rotation and receipt revocation rules;
- one-prompt reference user journey for Gateway mutations.

Exit criteria:

- preview and execution hash the same intent while excluding `confirmed` and transient metadata;
- approval cannot be produced solely by a model-authored `confirmed=true`;
- identical retries return the original result and changed intents conflict;
- receipts cannot cross actors, Profiles, tools, audiences, or expiry boundaries.
- authorization denials follow one deny-overrides precedence matrix across every layer.

### 6. Kagent and Agentgateway integration

Repositories: Kagent integration manifests, Agentgateway configuration, and distribution overlays

Deliverables:

- pinned Kagent and Agentgateway API versions;
- `RemoteMCPServer` and agent configuration with authenticated request propagation or STS;
- `allowedHeaders: [Authorization]` or an explicitly tested replacement;
- Agentgateway route, default-deny MCP policy, `prefixMode: Never`, and `sessionRouting: Stateless`;
- collision checks for tools, prompts, resources, and Skills;
- protocol/extension intersection checks for optional targets such as MLflow MCP;
- OpenTelemetry collector and audit configuration.

Exit criteria:

- Gateway exposes stable KEP-936 tool names;
- user identity reaches `kubeflow-mcp` with the correct audience;
- incompatible targets cannot silently downgrade the locked protocol;
- direct backend access cannot bypass Gateway enforcement.

### 7. Skills supply chain

Repositories: `kubeflow/mcp-server`, Skills packaging, Kagent integration, and distribution CI

Deliverables:

- `skills/list`, `skills/get`, and `resources/read` fixtures;
- complete per-file manifest generation with raw-byte digest and size;
- `SKILL.md` frontmatter and metadata validation;
- OCI packaging and digest linkage for Kagent;
- signature/attestation verification and trusted registry policy;
- sandbox, filesystem, secret, resource, and egress restrictions.

Exit criteria:

- changed, added, removed, unsigned, or tampered files revoke approval;
- the same Skill cannot silently shadow another server's Skill;
- Skill content cannot change authorization or confirmation behavior.

### 8. Conformance and release qualification

Repositories: structured KEP fixtures, `kubeflow/mcp-server` CI, and the participating distribution

Deliverables:

- checked-in topology/capability-pack lock file;
- Kind or equivalent cluster installation profile;
- protocol, security, identity, mutation, replay, and native-status test suites;
- upgrade and rollback jobs;
- owner sign-off records for every claimed component;
- release report containing versions, digests, test results, and known limitations.

Exit criteria:

- the selected topology and Training core pass continuously in CI;
- Task/native-resource failure and partial-effect outcomes are covered;
- Lifecycle adapters are independently enabled and tested;
- floating versions are not used in a conformance claim.

## Suggested implementation sequence

| Phase | Scope | Exit gate |
| --- | --- | --- |
| 0. Governance | Confirm sponsor, intended owner, component owners, and issue scope. | Proposal is accepted as provisional by the owning group. |
| 1. Contract fixtures | Freeze schemas, MCP revision, Skills/Tasks behavior, context keys, and canonicalization. | Valid/invalid fixtures are reviewed by the MCP Server project. |
| 2. Design prototype | Run the narrow Trainer path against the contract, including protocol, descriptor, identity, preview, and native-resource fixtures. | Owners have evidence to approve the implementation plan. |
| 3. Implementable gate | Approve the contracts and plan before broad implementation begins. | KEP is approved for implementation. |
| 4. Standalone foundation | Implement MCP discovery, Skills, Tasks, descriptors, Profile policy, and Trainer adapter. | Standalone Training core passes Alpha conformance. |
| 5. Mutation safety | Implement durable previews, approval binding, idempotency, and replay tests. | Confirmed mutations are safe across replicas and retries. |
| 6. Gateway reference | Add Kagent, Agentgateway, delegated identity, policy, stable naming, audit, and OTel. | Gateway read/preview path passes; mutation path passes after approval integration. |
| 7. Capability packs | Add Kueue, Pipelines, MLflow, Hub / Model Registry, KServe, or other adapters individually. | Each pack has owner approval and independent conformance evidence. |

## Dependencies and blockers

- WG Agents ownership or an explicitly recorded interim sponsor.
- `kubeflow/mcp-server` project approval for additive contract changes.
- Stable MCP framework support for the selected protocol revision and extensions.
- A supported Kagent approval integration that can bind approval to a preview intent.
- An HA persistence choice for preview, approval, Tasks, and idempotency records.
- Agreement on policy precedence and deny-overrides behavior across all authorization layers.
- A versioned capability-pack manifest and lifecycle policy for enablement, deprecation, and upgrades.
- A participating distribution willing to own the locked reference profile.

Until these dependencies are resolved, the KEP remains a design blueprint and should not claim Implementable status.
