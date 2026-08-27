# WG Agents Charter

This charter adheres to the conventions, roles and organization management outlined in [wg-governance].

## Scope

This working group (WG) focuses on the deployment, maintenance, and operationalization of autonomous agentic workflows within Kubeflow. While the [wg-ml-experience](/wg-ml-experience/charter.md) governs direct-to-IDE developer integrations, this WG focuses on the autonomous agent experience—building the infrastructure and tooling that allows agents to independently execute operational tasks (e.g., "investigate this Spark app") or serve as integrated solutions on Kubeflow.

Core Responsibilities:

1. Agentic Tooling & MCP Servers: Developing Model Context Protocol (MCP) servers and interfaces that allow agents to interact with Kubeflow components, actively reducing cluster operational burden (e.g., Spark MCP).

2. Reference Architectures: Managing agents that run alongside or as part of a Kubeflow subproject. For example, while the kubeflow/docs-agent serves developers, it falls under this WG's purview as a foundational reference architecture for how to successfully build and deploy agentic solutions on Kubeflow.

3. Agent Lifecycle Management: Ensuring Kubeflow natively supports the end-to-end development of agentic tools. This includes streamlining the fine-tuning of models for instruction adherence, auditing agent decision-making, and deploying MCPs directly on Kubeflow.

4. Secure Operability: Establishing security baselines for agent deployments. The WG ensures agents can seamlessly access self-hosted models and Kubeflow internal components while strictly enforcing least-privilege architecture (e.g., ensuring agents do not possess default principal access to the broader Kubernetes cluster).

In the end, this WG seeks to ensure the success of Agentic tools deployed within or alongside Kubeflow project components as well as the success of agentic focused [ecosystem partners](/ecosystem/PROJECTS.md).

### In scope

#### Code, Binaries and Services
1. Design, development, and maintenance of Model Context Protocol (MCP) servers and interfaces that enable agents to interface with and command Kubeflow components, actively reducing cluster operational burden (e.g., Spark MCP).
2. Ownership and operational maintenance of agent-based reference architectures running alongside or as part of a Kubeflow subproject (e.g., `kubeflow/docs-agent`).
3. Development of pipelines, tooling, and best practices for Agent Lifecycle Management on Kubeflow. This includes streamlining the fine-tuning of models for instruction adherence, auditing agent decision-making, and deploying MCPs directly on Kubeflow.
4. Establishing security baselines and access patterns for agent deployments, ensuring agents can seamlessly access self-hosted models and Kubeflow internal components while strictly enforcing least-privilege architecture (e.g., ensuring agents do not possess default principal access to the broader Kubernetes cluster).

#### Guiding Principles

- Synergy among Kubeflow Working Groups: Collaborate with other WGs to ensure the success of Agentic tools deployed within or alongside Kubeflow project components.
- Ecosystem Interoperability: Technical collaboration with agent-focused [ecosystem partners](/ecosystem/PROJECTS.md) to ensure smooth integration, open standards, and operational stability within the Kubeflow environment.

#### Cross-cutting and Externally Facing Processes

- Collaboration with other Kubeflow WGs, including WG ML Experience, WG Pipelines, WG Training, and WG Serving, to ensure that agentic tools are interoperable and secure across different stages of the ML lifecycle.
- Coordination with the release teams to align updates in agentic reference architectures and MCP servers with broader Kubeflow release schedules.

### Out of scope
- Direct-to-IDE Developer Tooling: IDE plugins, local developer environments, or human-in-the-loop coding assistants (this falls under the WG ML Experience).
- Core UI/UX Design: Changes to the primary Kubeflow Central Dashboard or component user interfaces.
- General Purpose Foundation Models: The training or hosting of generalized LLMs, except where specifically fine-tuned for Kubeflow operational tasks and tool-calling adherence.

## Roles and Organization Management

This WG adheres to the Roles and Organization Management outlined in [wg-governance]
and opts-in to updates and modifications to [wg-governance].

### Additional responsibilities of Chairs

- Coordinating and facilitating discussions on autonomous agentic workflows in scope of the WG, within the WG itself and the Kubeflow community.
- Ensuring alignment with overall Kubeflow goals and objectives in the context of the autonomous agent experience on Kubeflow.
- Providing technical guidance and mentorship to contributors working on Kubeflow MCP servers, reference architectures, and the projects in scope of this WG.
- Overseeing the technical direction of the subprojects and ensuring consistency with Kubeflow's vision for Kubeflow Agentic Workflows.
- Collaborate and connect with current and potential agentic focused [ecosystem partners](/ecosystem/PROJECTS.md)

### Subproject Creation

New WG subprojects need to be reviewed and approved by the WG Chairs.

[wg-governance]: ../committee-steering/wg-governance.md
