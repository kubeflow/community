# WG Agents Charter

This charter adheres to the conventions, roles and organization management outlined in [wg-governance].

## Scope

This working group (WG) focuses on the deployment, maintenance, and operationalization of autonomous agentic workflows within Kubeflow. While the [wg-ml-experience](/wg-ml-experience/charter.md) governs direct-to-IDE developer integrations, this WG focuses on the autonomous agent experience—building the infrastructure and tooling that allows agents to independently execute operational tasks (e.g., "investigate this Spark app") or serve as integrated solutions on Kubeflow.


### In scope

#### Code, Binaries and Services
1. Design, development, and maintenance of Model Context Protocol (MCP) servers and interfaces that enable agents to interface with and command Kubeflow components, actively reducing cluster operational burden (e.g., Spark MCP).
2. Ownership and operational maintenance of agent-based reference architectures running alongside or as part of a Kubeflow subproject (e.g., `kubeflow/docs-agent`).
3. Development of Kubernetes operator and server that run an Apache Ossie semantic layer on the existing data platforms to let agents talk to the data services.

#### Guiding Principles

- Synergy among Kubeflow Working Groups: Collaborate with other WGs to ensure the success of Agentic tools deployed within or alongside Kubeflow subprojects.
- Ecosystem Interoperability: Technical collaboration with agent-focused [ecosystem partners](/ecosystem/PROJECTS.md) to ensure smooth integration, open standards, and operational stability within the Kubeflow environment.

#### Cross-cutting and Externally Facing Processes

- Collaboration with other Kubeflow WGs, including WG ML Experience, WG Pipelines, and WG Training to ensure that agentic tools are interoperable and secure across different stages of the ML lifecycle.
- Coordination with the release teams to align updates in agentic reference architectures and MCP servers with broader Kubeflow release schedules.

### Out of scope
- Direct-to-IDE Developer Tooling: IDE plugins, local developer environments, or human-in-the-loop coding assistants (this falls under the WG ML Experience).
- Core UI/UX Design: Changes to the primary Kubeflow Central Dashboard or component user interfaces.
- General Purpose Foundation Models: The training or hosting of generalized LLMs, except where specifically fine-tuned for Kubeflow operational tasks and tool-calling adherence.

## Roles and Organization Management

This WG adheres to the Roles and Organization Management outlined in [wg-governance]
and opts-in to updates and modifications to [wg-governance].


### Subproject Creation

New WG subprojects need to be reviewed and approved by the WG Chairs.

[wg-governance]: ../committee-steering/wg-governance.md
