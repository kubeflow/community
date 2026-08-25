# Establish a Kubeflow Agent Integration Contract

**Structured companion draft.** The existing proposal directory remains unchanged.

**Status:** Draft for project review
**Tracking issue:** [kubeflow/community#1026](https://github.com/kubeflow/community/issues/1026)
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
        Skills · Tasks · tools
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
| Deployment topology | Standalone / Gateway | Direct `kubeflow-mcp` access, or Kagent and Agentgateway with delegated identity, policy, routing, audit, and tracing. |
| Capability pack | Training core / optional Kueue / experimental Lifecycle | The operator capabilities installed and individually approved for the deployment. |

The Training core is the first required pack. Trainer demonstrates the contract with `TrainJob`, Runtime, progress, metrics, checkpoints, optimization, and native status. Adapters for Pipelines, KServe, Katib, Spark, Hub / Model Registry, or other Kubeflow capabilities are independent and optional. Existing external MCP servers, such as MLflow MCP or Feast MCP, remain separate and may be federated into the same Gateway topology.

## Goals

- Define an operator-neutral MCP and Agent Skills contract for Kubeflow capabilities.
- Provide safe, auditable, preview-first access to mutations.
- Preserve native operator resources, status, errors, and lifecycle authority.
- Support direct MCP access and an authenticated Gateway topology.
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

## Component integration workflow

1. Agree on the operator or service's native authority and supported API versions.
2. Define its capability descriptor, tools, Skills, resources, personas, and native references.
3. Specify preview and confirmation behavior for every mutation.
4. Add identity, failure, replay, security, and compatibility fixtures.
5. Add the capability to a locked topology/pack profile only after component-owner approval.

## Graduation

Graduation requires a reviewed contract and implementation plan, a locked Trainer reference path, conformance evidence for each claimed topology and capability pack, and release qualification. The detailed gates are in [conformance.md](conformance.md).

## Open decisions

- Agree on the changes `kubeflow-mcp` must make to support this KEP while keeping its current tool names, parameters, response types, personas, and confirmation behavior compatible.
- Choose the first tested versions of Trainer, the Kubeflow SDK, MCP support, Agentgateway, the identity mechanism, and the exposed tool mode. These versions will form the initial reference lock.
- Choose how a user reviews and approves a mutation after seeing its preview. The approval must be tied to the exact user, Profile, tool, arguments, and expiration time, and a model must not be able to approve its own request.
- Choose where Tasks, previews, approvals, and completed request results are stored so they survive restarts and multiple server replicas. Define how the server recognizes two retries as the same request.
- Agree how conflicting access decisions are resolved when the agent harness, gateway, MCP server, Profile/RBAC, Kubernetes, and operator policy all participate. A lower layer must never grant more access than an upper layer allows.
- Define the small manifest that describes an optional operator integration: what it depends on, which topologies it supports, which tools and Skills it exposes, who owns it, and how it is enabled, upgraded, deprecated, or removed.
- Define what the agent sees when an MCP Task and the native operator resource disagree, including failed submissions, unknown outcomes, cancellation races, expiration, and workflows where one component succeeds and another fails.

## Supporting documents

- [Normative contracts](contracts.md)
- [Implementation plan](implementation-plan.md)
- [Conformance and graduation](conformance.md)

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
