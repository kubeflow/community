# KEP-938: Dedicated Repository for  kubeflow/mcp-server Repository

**Authors:**
- Abhijeet Dhumal (Red Hat) - [@abhijeet-dhumal](https://github.com/abhijeet-dhumal)

**Status:** Provisional

**Related:**
- [KEP-936: Kubeflow MCP Server - AI-Powered Training Interface](https://github.com/kubeflow/community/pull/937) (Technical Specification)
- [kubeflow/sdk#238: MCP Server for Kubeflow SDK](https://github.com/kubeflow/sdk/issues/238)

---

## Summary

This KEP requests the creation of a new repository `kubeflow/mcp-server` to host the Kubeflow MCP (Model Context Protocol) Server. The MCP server enables AI agents to interact with Kubeflow resources through natural language, wrapping the Kubeflow SDK without code duplication.

This is a **repo-creation KEP** focused on governance and ownership. Technical implementation details are covered in [KEP-936](https://github.com/kubeflow/community/pull/937).

## Motivation

The [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) is becoming a standard for AI agents to interact with external systems. A dedicated Kubeflow MCP server will:

1. Enable natural language interfaces for Kubeflow training workflows
2. Integrate with AI-powered IDEs (Claude Code, Cursor, VS Code with Copilot)
3. Provide a foundation for AI-powered LLMOps on Kubeflow

A standalone repository is recommended (see [KEP-936 Design Decisions](https://github.com/kubeflow/community/pull/937)) for:
- Independent release cadence from SDK
- Focused CI/testing for MCP-specific concerns
- Clear dependency direction (`kubeflow-mcp` depends on `kubeflow-sdk`, not reverse)
- Alignment with industry precedent (`github/github-mcp-server`, `containers/kubernetes-mcp-server`, `huggingface/hf-mcp-server`)

## Proposal

### Repository Creation

Create `kubeflow/mcp-server` repository under the Kubeflow GitHub organization.

### Ownership

- **Working Group:** [WG ML Experience](https://github.com/kubeflow/community/tree/master/wg-ml-experience)
- **Primary Maintainer:** [@abhijeet-dhumal](https://github.com/abhijeet-dhumal) (Red Hat)

### OWNERS File

```yaml
# Initial OWNERS for kubeflow/mcp-server
approvers:
  - abhijeet-dhumal
  - andreyvelich
  - wg-ml-experience-leads
reviewers:
  - abhijeet-dhumal
  - andreyvelich
  - wg-ml-experience
```

### Experimental Status

The repository will be marked as **experimental** with the following notice in the README:

> **⚠️ Experimental:** This project is under active development and not intended for production usage. APIs and features may change without notice until graduation criteria are met.

### Maintainer Onboarding

Additional maintainers will be onboarded over time as they contribute improvements to the project. Contributors demonstrating sustained engagement and domain expertise will be nominated for maintainer roles following standard Kubeflow governance processes.

## Graduation Criteria

The experimental status will be lifted when:

| Criterion | Requirement |
|-----------|-------------|
| **Core Tools** | Phase 1 training tools implemented and tested |
| **Documentation** | User guide and API reference published |
| **CI/CD** | Automated testing and release pipeline |
| **Community Validation** | Tested with multiple MCP clients (Claude, Cursor, etc.) |

## Implementation

1. Create `kubeflow/mcp-server` repository
2. Add initial OWNERS file with WG ML Experience leads
3. Add README with experimental status notice
4. Technical implementation per [KEP-936](https://github.com/kubeflow/community/pull/937)

## References

- [KEP-936: Kubeflow MCP Server - Technical Specification](https://github.com/kubeflow/community/pull/937)
- [Model Context Protocol Specification](https://modelcontextprotocol.io/)
- [kubeflow/sdk#238: MCP Server Discussion](https://github.com/kubeflow/sdk/issues/238)
- [KEP-913: KFP Components Repository](https://github.com/kubeflow/community/tree/master/proposals/913-components-repo) (Similar repo-creation KEP)
