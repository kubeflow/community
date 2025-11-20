# How to Become a Kubeflow Subproject

## Background information

**Submitters**

- StefanoFioravanzo (Founding Contributor)  
- Eder Ignatowicz (Lead Contributor)


**Project Name**

KALE

**Why is this project valuable to the Kubeflow Community?**

Kubeflow covers the full MLOps lifecycle — pipelines, training, tuning, model management, and serving. What’s still missing in the ecosystem is a simple, IDE-native experience for data scientists and ML practitioners who live inside JupyterLab.
Kale fills this gap. It enables users to transform notebooks into Kubeflow Pipelines with minimal code changes, preserving the fast, iterative workflow they are already familiar with while leveraging Kubeflow for scalability, scheduling, and GPU acceleration.
The plan for Kale extends beyond notebook-to-pipeline conversion. It aims to provide an in-notebook experience for visualizing, running, and monitoring pipelines, as well as interacting with other Kubeflow components, such as the Model Registry, Training Operator, and Katib.
As part of the ML Experience Working Group, Kale anchors the effort to bring a modern Jupyter-native experience to Kubeflow, complementing tools like Elyra and Jupyter Scheduler and laying the foundation for future IDE extensions.

**Why is it beneficial for this project to be a part of the Kubeflow Community?**

Kale fits naturally into Kubeflow. It aligns with the ML Experience Working Group and the effort to deliver a first-class Jupyter-native workflow. Bringing it under the Kubeflow org gives us a proper home to evolve that experience and build a consistent notebook-to-production story across all Kubeflow components.

Kale already has a history in the ecosystem. It was created and open-sourced by Arrikto, widely adopted early on, but eventually lost active maintainers. The community has always seen value in it (link) — the main gap has been long-term stewardship. Moving it into the Kubeflow organization formalizes that relationship, establishes a governance model, and encourages broader contributions.

We also proved the momentum is real. In GSoC 2025 (link), the project was revamped and updated to align with Kubeflow Pipelines v2 and JupyterLab 4.0. Since then, Kale has experienced steady community growth, with more than a dozen commits from six contributors across three different organizations (link). Donating Kale now builds on that progress, gives it a sustainable home, and positions it as the foundation for Kubeflow’s interactive IDE experience going forward.


**List of existing (and potential) integrations with Kubeflow Core components**

- Integration with Kubeflow Pipelines 2.0: Kale converts annotated notebooks into KFP 2.0 DSL that can be submitted directly to the KFP server. The generated pipelines leverage the native metadata language and data exchange of Kubeflow Pipelines.
- Kubeflow Notebooks: Kale can be embedded into a notebook image that is managed by the Kubeflow notebooks controller.
- Future integrations:
  - Kubeflow Model Registry
  - Kubeflow Trainer 
  - Kubeflow Katib

**Short Description / Functionality**

KALE is a project that aims at simplifying the Data Science experience of deploying Kubeflow Pipelines workflows.

Kubeflow is a great platform for orchestrating complex workflows on top of Kubernetes, and Kubeflow Pipelines provide the means to create reusable components that can be executed as part of workflows. The self-service nature of Kubeflow makes it extremely appealing for Data Science use, at it provides an easy access to advanced distributed jobs orchestration, re-usability of components, Jupyter Notebooks, rich UIs and more. Still, developing and maintaining Kubeflow workflows can be hard for data scientists, who may not be experts in working orchestration platforms and related SDKs. Additionally, data science often involve processes of data exploration, iterative modelling and interactive environments (mostly Jupyter notebook).

Kale bridges this gap by providing a simple UI to define Kubeflow Pipelines workflows directly from your JupyterLab interface, without the need to change a single line of code.

**Adoption**

Kale doesn’t have active production users today — the project went stale a few years ago. That said, community interest has remained strong(link). Since the recent GSoC 2025 revival, we’ve seen new contributors from multiple organizations, regular commits, and significant engagement on the donation issue(link). The demand for a Jupyter-native Kubeflow experience is clear, and Kale is the natural entry point to deliver it.

**Vendor Neutrality**
  
Yes

**Trademark transition**
  
The Kale name and logo are fully open source under the Apache license. The company that initially backed the project does hold any legal rights to the name and logo, since they have always been publicly available under the Apache 2.0 license. These assets have not been transitioned nor used by any other company and there is currently no active maintained project that could clash trademarks

**CI/CD Infra Requirements**

Minimal: Kale runs Python and Node/React tests + lightweight end-to-end tests with Kubeflow pipelines on a lightweight k8s cluster.

**Website**

https://kubeflow-kale.github.io/ 

**GitHub repository**

github.com/kubeflow-kale/kale 

**Releases**

First release - May 2019 - this was the first release of the Arrikto era
Kale 2.0 - end of 2025 - expected time window for the release of the revamped and community-driven version

**Meeting Notes**

https://docs.google.com/document/d/1jH2WAX2ePxOfI4JuiVK9nPlesDMiyg67xzLwhpR7wTQ/edit?tab=t.0

**Installation Documentation**

https://github.com/kubeflow-kale/kale/blob/main/README.md

**Project Roadmap**

The short-term goal is to evolve Kale beyond notebook-to-pipeline conversion. The next milestone focuses on adding visual authoring and runtime pipeline visualization directly in JupyterLab. This will let users both define and monitor Kubeflow Pipelines from the same IDE, bridging the gap between code and UI.

In parallel, we plan to align the visual experience between JupyterLab and the Kubeflow Central Dashboard, ensuring a consistent look and feel across the platform. These efforts will serve as the foundation for the Kubeflow JupyterLab Extension MVP, which aims to deliver a unified, streamlined experience for data scientists and ML practitioners across all Kubeflow components.

In the longer term, Kale will be extended to cover other key integrations, including the Model Registry, Training Operator, and Katib, making it the core entry point for interactive MLOps within Kubeflow.

## Metrics

- Number of Maintainers and their Affiliations: Stefano/Eder
- Number of Releases in last 12 months: N/A (no recent release) 
- Number of Contributors: 6 on the last 3 months
- Number of Users: N/A (no recent release)
- Number of Forks: 132
- Number of Stars: 141
- Number of package/project installations/downloads:  N/A (no recent release)

## Kubeflow Checklist

1.  Overlap with existing Kubeflow projects
    - [ ] Yes (If so please list them)
    - [X] No

1. Manifest Integration
    - [ ] Yes
    - [X] No
    - [ ] Planned

1. Commitment to Kubeflow Conformance Program
    - [X] Yes
    - [ ] No
    - [ ] Uncertain

1. Installation
    - [X] Standalone/Self-contained Component
    - [ ] Part of Manifests
    - [ ] Part of Distributions
    - [X] Part of Notebook images

1. Installation Documentation (Current Quality)
    - [ ] Good
    - [ ] Fair
    - [ ] Part of Kubeflow
    - [X] We are going to do this as part of 2.0 release

1. CI/CD 
    - [X] Yes
    - [ ] No

1. Release Process
    - [ ] Automated
    - [X] Semi-automated
    - [ ] Not Automated

1. Kubeflow Website Documentation
    - [ ] Yes
    - [X] No

1. Blog/Social Media 
    - [X] Yes
    - [ ] No


