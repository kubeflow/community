# KEP-467: Kubeflow Agent Skills Catalog and Distribution — Implementation Plan

This plan delivers the [AgentKit KEP](README.md) from `kubeflow/mcp-server`. The GitHub repository
is the initial catalog; a hosted registry is out of scope.

## Design Principles

- Keep one canonical, portable source for each skill; skills work without MCP.
- Skills produce artifacts. MCP operations retain invocation, authorization, confirmation, and
  troubleshooting guidance.
- Use Agent Plugins v1 for packaging and client-specific metadata for marketplace discovery.
- Keep MCP exposure optional and read-only; preserve existing tool schemas and permissions.

## Repository Changes for Alpha

The tree below shows additions and changes relative to the existing `kubeflow/mcp-server` project.
`[new]`, `[update]`, and `[optional]` mark the proposed work; existing MCP code stays unchanged in
Alpha.

```text
kubeflow/mcp-server/
├── .agents/                                                    [new]
│   └── plugins/marketplace.json                                [new; Codex CLI catalog]
├── .claude-plugin/                                             [new]
│   └── marketplace.json                                        [new; Claude Code catalog]
├── plugins/                                                    [new; portable plugin packages]
│   ├── training/                                               [new in Alpha]
│   │   ├── plugin.json                                         [new; Agent Plugins v1; name: training]
│   │   ├── .claude-plugin/plugin.json                          [optional; Claude metadata; name: training]
│   │   ├── mcp.json                                            [optional; portable MCP config]
│   │   ├── .mcp.json                                           [optional; Claude MCP config]
│   │   └── skills/
│   │       └── trainer-distributed-script-adapter/SKILL.md     [new; Alpha skill]
│   ├── pipelines/                                              [future candidate]
│   ├── model-registry/                                         [future candidate]
│   └── <future-plugin>/                                        [future extension]
├── docs/                                                       [existing]
│   └── skills/                                                 [new]
│       ├── catalog.md                                          [entries, owners, sources, versions, support, bundle status]
│       └── CONTRIBUTING.md                                     [contribution and maintenance guidance]
├── tests/                                                      [existing]
│   └── skills/                                                 [new]
│       ├── test_skill_validation.py                            [frontmatter, names, links, layout]
│       ├── test_marketplace_manifests.py                       [plugin and catalog schemas]
│       ├── test_package_contents.py                            [packaged skill files]
│       └── evaluations/                                        [representative valid/invalid cases]
├── README.md                                                   [update; link to install and fallback guidance]
└── kubeflow_mcp/                                               [existing; unchanged in Alpha]
```

### Alpha package rules

- Both catalogs point to `./plugins/training/`. The marketplace name is `kubeflow-agentkit`; the
  plugin entry and portable manifest are named `training`.
- The portable `plugin.json` uses the Agent Plugins v1 schema. The Claude plugin manifest is optional;
  if included, its name and version must match the portable manifest. The root
  `.claude-plugin/marketplace.json` is the Claude catalog, not the plugin manifest.
- Skill frontmatter requires `name` and `description`, and the skill name must match its directory.
- Alpha contains no MCP config. If MCP wiring is added later, keep each client's config in the plugin
  root. A config connects to the Python server; it does not install or register it.
- Other plugin directories are future candidates, not Alpha deliverables.

## Phase 0: Decisions Before Alpha

### Compatibility baseline

| Component | Alpha baseline |
| --- | --- |
| MCP Server | 0.2.x target |
| Kubeflow SDK | `>=0.5.0,<0.6.0` |
| Trainer | `>=2.3.0,<2.4.0` |
| Python | 3.10–3.12 |
| Kubernetes | `>=1.27` |

Before each release, recheck these sources:

- [Server requirements](https://github.com/kubeflow/mcp-server/blob/main/README.md#requirements)
- [`pyproject.toml`](https://github.com/kubeflow/mcp-server/blob/main/pyproject.toml)
- [`SDK_COMPATIBILITY`](https://github.com/kubeflow/mcp-server/blob/main/kubeflow_mcp/common/constants.py)

Record skill-specific dependencies and exceptions. If a local KFP skill is approved, document its
compiler version separately; the server has no Pipelines extra.

### Decisions to record

1. Confirm ownership and reviewers across WG Agents, MCP Server maintainers, WG ML Experience, and
   component owners. Reconcile scope with KEP-936.
2. Limit the Alpha Trainer adapter to supported PyTorch versions and runtimes. Link to an upstream
   KFP skill only if it meets Story 2's no-submit/no-run contract; create a local copy only with its
   owner's agreement.
3. Choose supported clients, marketplace formats, and fallback paths. Decide whether client-specific
   MCP configuration is needed and record the support matrix in `docs/skills/catalog.md`.

Record these decisions before Phase 1. Verify marketplace installs in Phase 2, after the package and
catalog files exist.

## Phase 1: Build and Publish the Alpha Catalog

### Actions

1. Add `plugins/training/plugin.json` and the canonical
   `plugins/training/skills/trainer-distributed-script-adapter/` tree; add
   `plugins/training/.claude-plugin/plugin.json` only if Claude-specific metadata is needed. Keep MCP
   configs out of Alpha. Create `docs/skills/catalog.md` with each entry's owner, source, version,
   component, supported clients, and whether files are bundled.
2. Build the Trainer adapter for supported PyTorch scripts. Return a self-contained `train()` function,
   dependencies, the `torch-distributed` runtime, assumptions, and a separate Trainer configuration
   with `num_nodes` and `resources_per_node`. Keep imports and setup inside the function so it works
   with `CustomTrainer(func=train)`; reject unsupported input and do not submit jobs or duplicate the
   MCP server's [`run_custom_training` wrapper](https://github.com/kubeflow/mcp-server/blob/main/kubeflow_mcp/trainer/api/training.py).
3. In the catalog index, link to a maintained upstream KFP skill only if it meets the no-submit/no-run
   contract. Otherwise, keep Story 2 as a candidate. Coordinate any local skill with Pipelines
   maintainers. Keep the SDK interfaces distinct: the Pipelines client accepts the `@dsl.pipeline`
   callable through `pipeline=`, while the Trainer SDK accepts `train` through `func=`
   ([API](https://sdk.kubeflow.org/en/latest/pipelines/api.html)).
4. Add Claude and Codex catalog entries named `training` and pointing to `./plugins/training/`.
   Include Codex's required `policy.installation`, `policy.authentication`, and `category` fields.
   Set each client's supported discovery metadata; validate both catalogs and verify the KEP README's
   install and fallback paths.
5. Publish the catalog alongside the `kubeflow-mcp` release, using the same Git tag initially while
   tracking an independent plugin version in the portable manifest and, when present, the Claude
   manifest. Document fallback, update, and removal paths; package upstream skills only with their
   owners' agreement.

## Phase 2: Validate and Maintain

### Tests

- Validate Agent Skills frontmatter (`name` and `description`), directory/name agreement, internal
  links, the portable manifest, the optional Claude manifest when present, marketplace catalogs, and
  package contents.
- Add representative evaluations with valid and invalid inputs, including missing artifacts and unmet
  prerequisites. Check operation input compatibility without running mutations.
- Verify both marketplace installs and the directory/skill fallback without a live cluster. Skill
  loading must not require `kubeflow-mcp`.
- If MCP exposure ships, run the relevant
  [SEP-2640 conformance scenarios](https://github.com/modelcontextprotocol/conformance/pull/330) and
  test reads, digests, missing files, path containment, and packaging.

Use [`skills-ref validate`](https://github.com/agentskills/agentskills/tree/main/skills-ref) as a
reference check, not the only quality gate. Validate `plugin.json` against the
[Agent Plugins v1 schema](https://agent-plugins.org/schemas/1.0.0/plugin.schema.json).

### Release

- Require skill-owner and component-owner review; check licensing, attribution, and secret-free assets.
- Document supported Kubeflow/client versions, plugin versioning, updates, and breaking changes.
- Review ownership, conformance, API compatibility, and client support periodically with WG Agents.

### Alpha exit criteria

- A versioned catalog is published; bundled skills are distinguished from upstream links. List a KFP
  upstream skill only if it meets the artifact-only contract; bundle it only with owner agreement.
- The portable manifest, optional Claude manifest, and marketplace catalogs validate; both
  marketplace installs and one fallback are verified.
- The Trainer skill meets its output contract; representative evaluations pass; skills do not duplicate
  MCP tool instructions. MCP Skills exposure is optional.
- Ownership, contribution, safety, and support guidance are documented.

### Stable exit criteria

- Named maintainers and a documented review process are active.
- Supported clients and Kubeflow versions are published and kept current.
- Releases are reproducible, with update/deprecation guidance and no unresolved critical issues.

## Optional Phase 3: Expose Skills Through MCP

This optional phase is not required for Alpha. It adds a read-only Skills provider and conformance
coverage. The work may update `kubeflow_mcp/core/resources.py` and its tests, or add a focused provider
module. Update `pyproject.toml` and `Dockerfile` only if skill files must ship in Python distributions
or the runtime image.

As of 2026-11-01, the checkout pins FastMCP 4.0.10; FastMCP 4.1.2 provides an experimental, opt-in
SkillsProvider, but provider availability does not prove conformance.
The [SEP-2640 specification](https://modelcontextprotocol.io/seps/2640-skills-extension) documents
FastMCP differences in URI structure, discovery, and metadata. The
[client matrix](https://modelcontextprotocol.io/extensions/client-matrix) reports partial support for
ChatGPT, fast-agent, and MCP Inspector. Recheck before starting; defer this phase unless the selected
provider conforms to the current SEP and a target client is verified.

### Actions

1. Verify FastMCP's provider against the stable SEP and document any required migration. Defer if it
   cannot meet the extension contract.
2. Declare `resources` and `io.modelcontextprotocol/skills`. Implement paginated `skills/list` and
   single-entry `skills/get`, returning `resultType: "complete"` and the required `ttlMs` and
   `cacheScope` on both results. Each entry returns required frontmatter and every file's URI,
   SHA-256 digest, and byte size; serve content through `resources/read`. Declare `directoryRead` only
   if implemented.
3. Keep reads inside the packaged skill root; reject traversal and escaping symlinks. Package skill
   files in source distributions, wheels, and the runtime container. Do not install or execute skills.
