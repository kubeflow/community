# WG ML Experience

This charter adheres to the conventions, roles, and organisation management outlined in [wg-governance] for the Working Group "ML Experience".

## Scope

The ML Experience Working Group focuses on developing, maintaining, and improving tools and extensions that support data science and machine learning practitioners experiences within Kubeflow. The group is dedicated to delivering a high-level, seamless experience integrated with the IDE of choice across multiple Kubeflow components.
 
### In scope
 
#### Code, Binaries, and Other relevant assets

1. Development of Kubeflow JupyterLab extensions that provide simple abstractions and UX to interact with the most common Kubeflow components (e.g., pipelines, hyperparameter tuning) and shorten the time to value for practitioners comfortable with Jupyter. These extensions will focus on the most used Kubeflow components, such as:
    - Pipelines;
    - Kubeflow Trainer
    - Kubeflow Katib
    - Model Registry;
    - Model Serving (KServe);
    - Feast.

2. Promote the reusability of UI components from other Kubeflow UIs into the IDE (e.g., rendering a pipeline graph inside the JupyterLab environment) by establishing a shared contract between the IDE WG and the wider Kubeflow community. 

3. Develop a Python SDK to simplify operationalization across Kubeflow components and provide a “one-stop-shop” for practitioners who want easy access to Kubeflow services. The SDK also provides the groundwork for the IDE extension automation and workflows.
    - Create a single installation and configuration layer for users interacting programmatically with the Kubeflow ecosystem via SDKs.
    - The “common” SDK is not meant to replace individual components’ SDKs but rather to offer a unified access layer to simplify dependency management and shared configuration (like authorization).

#### Guiding Principles

- Synergy among Kubeflow Working Groups: Collaborate with other WG to promote reusability of UI components from other Kubeflow UIs to create a single UX between Jupyter IDE and Kubeflow Central Dashboard;
- Collaboration with other open-source IDE projects (like Jupyter and VSCode) to promote the creation and reusability of open standards for AI/ML tools (protocols, communication exchange, file formats, etc.) and plugins. The aim of this group is to actively participate in the development of these standards to include Kubeflow in a broader ecosystem or interoperable tools. 

#### Cross-cutting and Externally Facing Processes

- Collaboration with other Kubeflow WGs, including WG Notebooks, WG Pipelines, WG Training, WG AutoML, WG Data, and WG Serving, ensures that IDE tools are interoperable across different stages of the ML lifecycle.
- Coordination with the release teams to align updates in IDE tools with broader Kubeflow release schedules.


### Out of scope

- Building and maintaining Notebook/Workspaces images (this falls under the WG Notebooks).

## Roles and Organization Management

This WG adheres to the Roles and Organization Management outlined in [wg-governance] and opts-in to updates and modifications to [wg-governance].

### Additional responsibilities of Chairs

- Coordinating and facilitating discussions on ML experience topics in scope of the WG, within the WG itself and the Kubeflow community.
- Ensuring alignment with overall Kubeflow goals and objectives in the context of user experience to data scientists and machine learning practitioners on Kubeflow.

### Additional responsibilities of Tech Leads

- Providing technical guidance and mentorship to contributors working on Kubeflow JupyterLab extensions, SDK, and the projects in scope of this WG.
- Overseeing the technical direction of the subprojects and ensuring consistency with Kubeflow's vision for Kubeflow ML Experience.

### Deviations from [wg-governance]

This WG follows the outlined roles and governance in [wg-governance].

### Subproject Creation

WG Technical Leads

[wg-governance]: ../wgs/wg-governance.md