# KEP-467: Kubeflow Agent Skills Catalog and Distribution

- **Authors:** Abhijeet Dhumal (@abhijeet-dhumal)
- **Status:** provisional
- **Owning group:** Kubeflow Agents Working Group (proposed; agreement with WG ML Experience and MCP
  Server maintainers pending)
- **Tracking issue:** [kubeflow/mcp-server#467](https://github.com/kubeflow/mcp-server/issues/467)
- **Created:** 2026-10-29

## Summary

This KEP proposes **AgentKit**, a catalog of standalone Kubeflow workflow skills, initially hosted in
`kubeflow/mcp-server`. Skills use the vendor-neutral
[Agent Skills specification](https://agentskills.io/specification). They ship in a separately
versioned Agent Plugin package alongside the `kubeflow-mcp` Python distribution.
Skills remain usable without the MCP server and do not change its tools or schemas. Client-specific
installation appears below; the optional read-only MCP Skills extension is described in the
[implementation plan](IMPLEMENTATION_PLAN.md).

## Motivation

MCP tools provide Kubeflow operations. Skills can fill workflow gaps by generating, transforming, or
validating artifacts that users or compatible SDK operations can consume.

### Goals

- Publish standalone skills for Kubeflow workflow gaps, starting with Trainer script adaptation;
  add a KFP pipeline-generation entry when a maintained upstream skill supports artifact generation
  without submitting or running workloads.
- Ship a versioned Agent Plugin package with tested client installation paths and a directory-based
  fallback.
- Optionally expose selected skills read-only through SEP-2640 without changing MCP tool behavior or
  making skills depend on MCP.

### Non-Goals

- Building a hosted registry, universal marketplace, search service, or installer.
- Repeating MCP tool instructions or changing MCP tools and their schemas.
- Having skills submit or manage Kubeflow workloads.

## Proposal

Keep each plugin under `plugins/<plugin-name>/`, with canonical skills at
`plugins/<plugin-name>/skills/<skill-name>/SKILL.md`. Each skill owns a standalone task,
prerequisites, validation, and output contract. Skills may produce artifacts for compatible SDK
or MCP operations, but will not explain or invoke those operations. Link to upstream skills that meet
the relevant story’s output contract; keep copies only with their owners’ agreement.

Start with `plugins/training/` as a portable Agent Plugin. Client-specific catalogs support Git-based
marketplaces where available, with copied skills as a fallback. Any later MCP exposure will use the
official read-only Skills extension
([SEP-2640](https://modelcontextprotocol.io/seps/2640-skills-extension)). This proposal extends
[KEP-936](https://github.com/kubeflow/community/tree/master/proposals/936-kubeflow-mcp-server) to
cover skills that generate or transform Kubeflow artifacts, not only skills that call MCP tools.

The [implementation plan](IMPLEMENTATION_PLAN.md) contains the compatibility baseline, repository
layout, delivery phases, tests, and Alpha/Stable exit criteria.

## User Installation

| Goal           | Install path                                                   |
| -------------- | -------------------------------------------------------------- |
| Skills only    | Marketplace plugin, or copy the skill folder to a client skill directory. |
| MCP operations | Install the Python package and register the server separately.            |
| Skills and MCP | Plugin plus server; optional client config connects to MCP.               |

### Claude Code

```text
/plugin marketplace add kubeflow/mcp-server
/plugin install training@kubeflow-agentkit
```

### Codex CLI

```bash
codex plugin marketplace add kubeflow/mcp-server
codex plugin add training@kubeflow-agentkit
```

These marketplace commands use `kubeflow/mcp-server` as the current Git source and install skills
only. For MCP operations, install the server package and register its stdio process with the client
([Claude Code](https://code.claude.com/docs/en/mcp), [Codex CLI](https://developers.openai.com/codex/mcp)):

```bash
pip install kubeflow-mcp
claude mcp add --transport stdio kubeflow -- kubeflow-mcp serve
```

For Codex CLI, use the same package and register it with:

```bash
codex mcp add kubeflow -- kubeflow-mcp serve
```

If the marketplace is unavailable, copy the skill folder into the client’s standard project skill
location:

| Client      | Copy to                        |
| ----------- | ------------------------------ |
| Claude Code | `.claude/skills/<skill-name>/` |
| Codex CLI   | `.agents/skills/<skill-name>/` |

A plugin may instead bundle its client configuration at the plugin root (`mcp.json` for portable
Agent Plugins or `.mcp.json` for Claude Code). That configuration does not install the Python package.

## User Stories

These stories describe AgentKit skills, not existing MCP tools. The MCP server implements Trainer,
has Optimizer and Hub stubs, and plans Pipelines and Spark, as shown in its
[compatibility map](https://github.com/kubeflow/mcp-server/blob/main/kubeflow_mcp/common/constants.py).
Alpha bundles the Trainer adapter. Story 2 remains a candidate unless an upstream KFP skill meets the
no-submit/no-run contract; Stories 3–4 are post-Alpha candidates.

### Story 1: ML Engineer — Adapt a PyTorch Script for Distributed Training

**User:** “Adapt this single-node PyTorch script for 2 nodes with 4 GPUs each.”

**Proposed behavior:** For supported PyTorch inputs, adapt rank/device handling, data sharding, and
setup/cleanup for
[distributed training](https://sdk.kubeflow.org/en/latest/train/distributed.html), then place the
complete workload in a self-contained `train()` function. Keep imports and required setup inside the
function so it can run in the target environment. Make it suitable for `CustomTrainer(func=train)`
([custom training guide](https://sdk.kubeflow.org/en/latest/train/custom-training.html),
[API](https://sdk.kubeflow.org/en/latest/train/api.html)). KFP pipeline generation is a separate
workflow described in Story 2.

**Output:** Return the self-contained function, dependencies, `torch-distributed` runtime, and a
separate Trainer configuration with `num_nodes=2` and `resources_per_node={"gpu": 4}`. Include
assumptions. Do not generate pipeline source or compiled YAML, submit a job, or duplicate the MCP
tool's execution wrapper. The MCP server's
[`run_custom_training` implementation](https://github.com/kubeflow/mcp-server/blob/main/kubeflow_mcp/trainer/api/training.py)
accepts script text and wraps it as a callable.

### Story 2: Data Scientist — Generate a KFP Pipeline (upstream or future candidate)

**User:** “Turn this annotated notebook into a compiled KFP v2 pipeline.”

**Proposed behavior:** Use [Kale](https://kale.kubeflow.org/en/latest/) when applicable; otherwise,
generate KFP DSL from the supplied workflow and compile and validate it locally using the
[KFP compilation workflow](https://www.kubeflow.org/docs/components/pipelines/user-guides/core-functions/compile-a-pipeline/).

**Output:** Return pipeline source and a compiled YAML file. The
[PipelinesClient API](https://sdk.kubeflow.org/en/latest/pipelines/api.html) accepts either a
`@dsl.pipeline` callable or a YAML file path, but this story stops before upload or execution.
[Pipelines PR #13653](https://github.com/kubeflow/pipelines/pull/13653) demonstrates an upstream
generation and compile/fix loop; its demo also runs the pipeline on a local backend, which is outside
this story. [MCP PR #468](https://github.com/kubeflow/mcp-server/pull/468) covers registered pipeline
discovery and run lifecycle, not definition upload.

### Story 3: ML Researcher — Prepare Katib/Optimizer Inputs (post-Alpha candidate)

**User:** “Set up a search over learning rate and batch size to maximize validation accuracy.”

**Proposed behavior:** Produce a `TrainJobTemplate`, a `search_space` mapping built with `Search`
helpers, and `objectives` using `Objective(metric=..., direction=...)` for the
[Optimizer API](https://sdk.kubeflow.org/en/latest/optimize/api.html). Validate parameter bounds and
metric direction. Do not call `OptimizerClient.optimize()`, which creates and submits the job.

### Story 4: Model Developer — Prepare Model Registry Metadata (post-Alpha candidate)

**User:** “Prepare registration metadata for this fraud-detector v1 artifact and its metrics.”

**Proposed behavior:** Prepare inputs for
[`ModelRegistryClient.register_model`](https://sdk.kubeflow.org/en/latest/hub/api.html): model name,
remote artifact URI, and required version. Model format fields and scalar metadata such as metrics
are optional. The SDK client is available through the optional `kubeflow[hub]` extra. Confirm the
artifact is expected to be stored remotely; validate input shape without accessing storage or
registering the model. The MCP server's Hub client remains a stub.

## Design Details

The implementation plan's [Alpha repository layout](IMPLEMENTATION_PLAN.md#repository-changes-for-alpha),
compatibility baseline, and delivery phases define the design.

## Test Plan

The implementation plan's [validation and maintenance section](IMPLEMENTATION_PLAN.md#phase-2-validate-and-maintain)
covers manifest and skill validation, client installation, fallback loading, and optional MCP
conformance.

[ ] I/we understand the involved component owners may require updates to existing tests before
implementation.

## Graduation Criteria

The implementation plan defines [Alpha](IMPLEMENTATION_PLAN.md#alpha-exit-criteria) and
[Stable](IMPLEMENTATION_PLAN.md#stable-exit-criteria) exit criteria.

## Implementation History

- 2026-10-29: KEP created; status is provisional.

## Risks and Mitigations

- **Stale or duplicate skills:** require component-owner review and keep one canonical source.
- **Client differences:** maintain a tested support matrix; do not promise a universal install command.
- **Trust and distribution:** review and version skills; read-only MCP exposure does not execute skill
  content, and installing a skill grants no cluster access.

## Drawbacks

- Maintainers of `kubeflow/mcp-server` would take on skill and client-compatibility maintenance.
- A dedicated skills repository may be a better home if ownership or catalog size grows.

## Alternatives

- **Separate skills repository:** separates component ownership but splits the initial catalog from
  MCP resource packaging.
- **MCP resources only:** does not support native Agent Skills loading.
- **Hosted marketplace:** adds service and maintenance work before GitHub browsing requires it.

## Project and Plugin Identity

The working project name is **AgentKit** (slug: `agentkit`), pending confirmation in
[Open Questions](#open-questions). Use **`kubeflow-agentkit`** as the marketplace identifier and
`training` as the initial plugin name. Keep the `kubeflow/mcp-server` repository and
`kubeflow-mcp` package and CLI names until a separate migration is approved.

Keep one marketplace as the project catalog. Add workflow-focused plugins only when their audience,
ownership, or release needs justify independent installation. Use Codex's required category and each
client's supported metadata for discovery; those labels do not define plugin boundaries.

## Open Questions

- **KFP skill source:** Confirm the upstream repository and owner, and verify that its skill supports
  artifact generation and local validation without submitting or running a pipeline. Bundle it only
  with its owner's agreement.
- **Project name:** Confirm AgentKit (slug: `agentkit`) as the public-facing project name with the
  proposed owning groups.
- **Repository and Git source:** Confirm `kubeflow/mcp-server` as the repository and marketplace
  source path used by the install commands.
- **Marketplace identifier:** Confirm `kubeflow-agentkit` as the marketplace name used in install
  commands.
- **Initial plugin name:** Confirm `training` as the first plugin entry in that marketplace.
- **Plugin structure:** Which post-Alpha workflows warrant separate plugins, and what split criteria
  should apply? Candidate names include `pipelines` and `model-registry`; `optimizer` and `spark` may
  also become plugins if their owners, audiences, or release needs differ. Alpha starts with
  `training`; add other directories as approved. A plugin follows this layout:

  ```text
  plugins/
  ├── training/
  │   ├── plugin.json
  │   ├── .claude-plugin/plugin.json  # optional Claude metadata
  │   └── skills/<skill-name>/SKILL.md
  ├── pipelines/       # same package layout; future candidate
  ├── model-registry/  # same package layout; future candidate
  └── <future-plugin>/ # future extension
  ```

  Each marketplace entry points to one plugin directory. The portable manifest name matches the
  marketplace entry; if included, the Claude manifest name matches it too.

## References

- [Kubeflow Agents Working Group](https://github.com/kubeflow/community/tree/master/wg-agents)
- [Agent Skills specification](https://agentskills.io/specification)
- [Agent Plugins v1 specification](https://agent-plugins.org/specification)
- [Claude Code plugin marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)
- [Codex plugin packaging and marketplace guide](https://developers.openai.com/plugins/build/plugins)
- [SEP-2640: MCP Skills Extension](https://modelcontextprotocol.io/seps/2640-skills-extension)
- [Kubeflow MCP Server KEP-936](https://github.com/kubeflow/community/tree/master/proposals/936-kubeflow-mcp-server)
- [Kubeflow Pipelines skill PR #13653](https://github.com/kubeflow/pipelines/pull/13653)
- [Kubeflow MCP Pipelines client PR #468](https://github.com/kubeflow/mcp-server/pull/468)
