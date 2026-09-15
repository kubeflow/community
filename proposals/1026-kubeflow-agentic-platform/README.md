# Establish a Kubeflow Agent Integration Contract

**Status:** Provisional design proposal
**Tracking issue:** [kubeflow/community#1026](https://github.com/kubeflow/community/issues/1026)
**Interim sponsor:** WG ML Experience until the proposed WG Agents is established
**Intended owner:** Proposed WG Agents ([kubeflow/community#1025](https://github.com/kubeflow/community/pull/1025))

Now that Kubeflow is a CNCF graduated project, it is part of a broader cloud-native AI ecosystem. This proposal aligns Kubeflow agent integrations with the wider cloud-native AI ecosystem and emerging Agentic AI Foundation efforts, while preserving the ownership and lifecycle of each Kubeflow component.

## Decision summary

Kubeflow already has the operators and services needed to run an AI/ML lifecycle. The missing piece is a consistent way for an agent to use those capabilities safely. Today, each integration would need to work out its own discovery, identity, approval, status, and observability behavior.

This KEP proposes a shared integration contract for Kubeflow agents. The contract defines how an agent discovers an operator capability, reads its Skills, acts within a verified Profile and namespace, previews and confirms mutations, follows the operator's native resource, and accesses authorized evidence such as logs, events, metrics, traces, runs, and model references.

The KEP does not introduce a new agent runtime, controller, lifecycle database, or replacement API. An existing agent harness such as Kagent remains responsible for the model loop, planning, memory, and user interaction. Agentgateway may provide the identity and policy boundary. Kubeflow MCP adapters translate agent requests into the native SDKs and APIs owned by each operator.

Trainer is the first reference implementation because it is the most mature Kubeflow MCP capability. It proves the common contract with `TrainJob`, but it is not the scope of the platform. The same contract can later be implemented by KFP, KServe, Katib, Spark, Kubeflow Hub / Model Registry, Semantic Operator, and other operator-backed capabilities.

## Problem

Kubeflow capabilities are individually useful but agent-facing behavior is fragmented. Different projects expose different discovery, identity, status, confirmation, and observability conventions. As a result, every agent integration must reconstruct:

- which capabilities are installed and usable;
- which Profile, namespace, persona, and native authorization apply;
- which tools and Skills are available;
- how a mutation is previewed, approved, and made idempotent;
- how asynchronous work maps to native resources; and
- how logs, events, metrics, traces, runs, models, and endpoints are correlated.

The proposal supplies these shared conventions without flattening component semantics.

## Architecture

```text
User / IDE / Notebook / Dashboard
                |
                v
      Agent harness (for example Kagent)
                |
                v
            MCP client
        Skills · tools
                |
       +--------+---------+
       |                  |
       | Standalone       | Gateway
       |                  v
       |          Agentgateway
       |          identity · policy
       |          routing · audit · OTel
       |                  |
       +--------+---------+
                v
       Kubeflow MCP adapter
       modules
                |
                v
       Native SDKs, APIs, operators,
       controllers, and services
```

The design has two independent axes:

| Axis | Options | Meaning |
| --- | --- | --- |
| Deployment topology | Standalone first / Gateway extension | Direct `kubeflow-mcp` access is the first milestone. Kagent and Agentgateway are a follow-up profile. |
| Capability pack | Training core first / other packs extensions | Trainer is the first reference. Other operator and service integrations are added independently. |

The Training core is the first required pack. Trainer demonstrates the contract with `TrainJob`, Runtime, progress, metrics, checkpoints, optimization, and native status. Adapters for Pipelines, KServe, Katib, Spark, Hub / Model Registry, or other Kubeflow capabilities are independent and optional. Existing external MCP servers, such as MLflow MCP or Feast MCP, remain separate and may be federated into the same Gateway topology.

## First milestone

The first implementation milestone is deliberately narrow.

Core interoperability requires:

- Standalone MCP access;
- Trainer as the sole reference adapter;
- one verified identity and Profile model;
- discovery, immutable read-only Skills, preview, and native status.

Alpha hardening adds approval binding, durable idempotency, cache isolation, and the conformance suite for retries and mutation safety.

Gateway integration, additional capability packs, external MCP federation, Skills supply-chain verification, and multi-cluster behavior are extension profiles for follow-up work.

### Proposed `Standalone Training Core v0.1` defaults

These defaults make the first implementation concrete and remain subject to project-owner sign-off:

| Area | Proposed default |
| --- | --- |
| Identity | Kubernetes/OIDC identity with one documented actor-to-Profile and namespace mapping. |
| Approval | MCP `2026-07-28` MRTR using `input_required`, with approval bound to the preview and `plan_id`. |
| Persistence | PostgreSQL-backed durable store for previews, approvals, and idempotency results. |
| Idempotency | RFC 8785 JSON Canonicalization Scheme plus SHA-256 over canonical request arguments. |
| Tasks | Deferred; poll native `TrainJob` status in the first profile. |
| Policy | Deny-overrides precedence. |
| Deployment | Standalone `kubeflow-mcp` reference profile. |

## Goals

- Define an operator-neutral MCP and Agent Skills contract for Kubeflow capabilities.
- Provide safe, auditable, preview-first access to mutations.
- Preserve native operator resources, status, errors, and lifecycle authority.
- Define direct MCP access first and an authenticated Gateway topology as a follow-up profile.
- Prove the contract with a locked Trainer reference adapter.
- Make it possible for other Kubeflow components, such as Pipelines, KServe, Katib, Spark, and Model Registry, to integrate through the same contract, with each component's owners approving its adapter.

## Non-goals

- Replacing Kubeflow operators, APIs, SDKs, controllers, UIs, or data stores.
- Building a central Kubeflow agent runtime or universal lifecycle controller.
- Creating a new lineage, experiment-tracking, model-registry, or semantic-data system.
- Requiring every Kubeflow project to implement MCP in the first release.
- Implementing A2A delegation, Agent Cards, or multi-cluster operation semantics.
- Creating a skills marketplace or granting Skills authority to bypass server policy.
- Defining a universal agent memory, planning loop, model runtime, or harness evaluation score.
- Replacing existing MCP servers, such as MLflow MCP or Feast MCP; they may remain independent or be federated through Agentgateway.

## Runtime boundaries

This KEP integrates with an agent harness, such as Kagent, but does not define a competing harness. The harness owns model calls, planning, memory, tool selection, and user interaction. The MCP client owns protocol negotiation and transport. Agentgateway may provide identity, policy, routing, audit, and telemetry. Kubeflow adapters translate requests into native operator APIs, while operators remain authoritative for resources, status, and lifecycle. Detailed responsibilities are defined in [contracts.md](contracts.md).

## Contract boundaries

This KEP owns the cross-project rules for discovery, authorization scope, preview and approval, idempotency, native references, evidence, telemetry, compatibility, and conformance. Components retain authority over their native schemas, status, errors, lifecycle, APIs, and releases. The full boundary is defined in [contracts.md](contracts.md).

## API impact

This proposal requires no breaking changes to controller APIs, CRDs, or existing SDK methods. Controllers remain authoritative for native resources, validation, status, and lifecycle. SDK changes should be additive and limited to native information needed by adapters. MCP-specific discovery, Skills, authorization, preview, approval, idempotency, Tasks, evidence, and telemetry are implemented at the adapter and optional Gateway layers.

Where native APIs support it, adapters MAY use server-side dry-run or validation-only requests to build previews. Otherwise, previews MUST be generated without mutating resources.

| Existing behavior | Compatibility requirement |
| --- | --- |
| Tool names | Unchanged. |
| Required parameters | Unchanged. |
| Response shapes | Additive fields only. |
| Personas | Existing policy retained. |
| Confirm gate | Formalized, not replaced. |

## Component integration workflow

1. Agree on the operator or service's native authority and supported API versions.
2. Define its capability descriptor, tools, Skills, resources, personas, and native references.
3. Specify preview and confirmation behavior for every mutation.
4. Add identity, failure, replay, security, and compatibility fixtures.
5. Add the capability to a locked topology/pack profile only after component-owner approval.

## Initial acceptance

Initial acceptance requires a reviewed contract and implementation plan, a locked Trainer reference path, and Standalone Training core conformance evidence. The criteria are in [conformance.md](conformance.md); later extension-profile graduation rules will be defined separately.

## Open decisions

- Agree on the changes `kubeflow-mcp` must make to support this KEP while keeping its current tool names, parameters, response types, personas, and confirmation behavior compatible.
- Confirm the proposed Trainer, Kubeflow SDK, MCP, identity, and tool-mode versions for the initial reference lock.
- Confirm the proposed MRTR approval flow and its binding to the exact user, Profile, tool, arguments, preview, and expiration time.
- Confirm PostgreSQL as the initial durable store for previews, approvals, and idempotency results, and confirm the retry identity rules.
- Confirm that MCP Tasks are deferred while the first profile polls native `TrainJob` status.
- Confirm RFC 8785 canonicalization plus SHA-256 for idempotency hashes.
- Agree how conflicting access decisions are resolved when the agent harness, gateway, MCP server, Profile/RBAC, Kubernetes, and operator policy all participate. A lower layer must never grant more access than an upper layer allows.
- Define the small manifest that describes an optional operator integration: what it depends on, which topologies it supports, which tools and Skills it exposes, who owns it, and how it is enabled, upgraded, deprecated, or removed.
- Define what the agent sees when an MCP Task and the native operator resource disagree, including failed submissions, unknown outcomes, cancellation races, expiration, and workflows where one component succeeds and another fails.

## Supporting documents

- [Normative contracts](contracts.md)
- [Implementation plan](implementation-plan.md)
- [Conformance and initial acceptance](conformance.md)

## Related work

- [KEP-936: Kubeflow MCP Server](../936-kubeflow-mcp-server/README.md)
- [KEP-897: First-Class MLflow Integration](../897-experiment-tracking/README.md)
- [KEP-907: Model Registry rename to Kubeflow Hub](../907-model-registry-renaming/README.md)
- [Kubeflow SDK roadmap](https://github.com/kubeflow/sdk/blob/main/ROADMAP.md)
- [Kubeflow Trainer roadmap](https://github.com/kubeflow/trainer/blob/master/ROADMAP.md)
- [WG Agents proposal](https://github.com/kubeflow/community/pull/1025)
- [MCP `2026-07-28`](https://modelcontextprotocol.io/specification/2026-07-28)
- [MCP Skills extension](https://modelcontextprotocol.io/extensions/skills/overview)
- [MCP Tasks extension](https://modelcontextprotocol.io/extensions/tasks/overview)
