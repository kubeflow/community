# 649-kubeflow-helm-support: Support Helm installs for individual components
There has been increased demand for a Helm chart for a basic Kubeflow installation. Given the KSC's stance in issue 821 on neutral deployment language and user-defined production readiness, this is an opportune time to introduce a Helm chart. Supporting Helm will enhance ease of adoption and simplify deployments while maintaining the flexibility of community-maintained manifests. There already has been [community efforts](https://github.com/kromanow94/kubeflow-manifests/tree/helmcharts/charts) as well as the Kubeflow-Helm-Chart Slack Channel. "


## Summary
Kubeflow manifests provide a fast way to deploy a minimal Kubeflow platform, with best-effort community support. For guaranteed assistance, users can opt for third-party distributions, consultants, or self-managed expertise. This approach extends to Helm chart support. Contributions and bug reports are encouraged, but there will be no official support. The goal is to build a [similar folder structure as Argo](https://github.com/argoproj/argo-helm/tree/main) for Kubeflow Helm Charts.


## Motivation
Currently, most installation efforts rely on cloud vendor-hosted distributions or open-source solutions like DeployKF. While these options are valuable, they require engagement with adjacent projects and communities. As a project, we must ensure that our Helm chart provides a quick and accessible way for users to deploy Kubeflow, enabling them to either manage their own environments or adopt a vendor solution.

Simplifying Kubeflow deployment lowers the barrier to entry, increasing adoption and encouraging contributions. Just as Kubernetes enabled a new wave of cloud-native startups, a neutral, accessible deployment path can empower AI/ML startups to leverage tools like the Training Operator or Katib without reinventing common patterns. If support becomes burdensome, teams can hire expertise or use a distribution—both of which drive demand for Kubeflow skills.

By making deployment easy, we not only attract more end users but also foster collaboration with broader communities like PyTorch, improving our implementations in service of their users.


### Goals
✅ A fully functional Kubeflow Helm chart for the targeted release. This will install individual components and we can explore what a minimum viable platform could be. 
✅ Published Helm chart documentation with clear configuration options
✅ A step-by-step tutorial simplifying Kubeflow deployment for users
✅ Contribution to the Kubeflow community effort for Helm-based installation as part of the official Kubeflow Repo.


### Non-Goals
* Full multi cloud/environment support
* End to end authentication layer
* Integration of adjacent projects such as Kserve or Knative. 
* Support seperate abstracted operators for components (although this effort might lead us in that direction as we learn more about the user experience)
* Provide guaranteed community support
* Defintion on what production is for any particular set of users.
* Infrastructure provisioning. A user can opt into OpenTofu or Crossplane to template the Helm chart with infrastructure should they need to, but we are focused on the Helm chart where the values would be configured (if a component requires knowledge of external systems).


## Proposal
This proposal introduces official Helm chart support for deploying Kubeflow components. The goal is to provide a modular, community-maintained way to install and manage Kubeflow, making it more accessible for users who prefer Helm over kustomize-based manifests.
Desired Outcome

The Helm chart will allow users to:
✅ Deploy Kubeflow with a single Helm command, reducing installation complexity.
✅ Select specific components to install (e.g., Training Operator, Katib, Pipelines, etc.) without requiring the entire Kubeflow stack.
✅ Configure installations via Helm values, enabling customization for different environments (e.g., resource allocation, authentication settings, storage options).
✅ Upgrade and rollback Kubeflow deployments safely using Helm’s built-in version control.
✅ Integrate with GitOps workflows (e.g., ArgoCD, FluxCD) for automated deployments.
✅ Maintain a Helm chart structure similar to Argo’s Helm charts, ensuring a familiar experience for Kubernetes users.


Measuring Success

The success of this proposal will be measured by:

    *Adoption Metrics*
        Number of Helm chart downloads from the official Kubeflow repository.
        Community contributions to Helm chart improvements.

    *Ease of Use & Community Engagement*
        Successful deployments reported by users via GitHub issues, Slack, and forums.
        Documentation feedback and tutorial completion rates. We can also gather details from in person events.

    *Modularity & Customization*
        Verified Helm installations of individual Kubeflow components.
        Flexibility demonstrated in community-reported use cases (e.g., deploying only Training Operator).

    *Stability & Maintainability*
        Helm-based deployments function consistently across Minikube, cloud-managed Kubernetes (EKS, GKE, AKS), and on-prem clusters.
        Contributions and maintenance of Helm charts remain sustainable within the Kubeflow community.

This proposal lays the foundation for Helm-based Kubeflow installations while ensuring alignment with Kubeflow’s existing deployment philosophy: providing users with flexible options while maintaining a vendor-neutral stance.

### User Stories (Optional)

#### Story 1
##### Alex's Conquers Kubeflow

*background*

Alex is an ML engineer working at a mid-sized AI startup. The team wants to experiment with Kubeflow Pipelines and Katib for hyperparameter tuning but doesn’t need the full Kubeflow stack. Currently, deploying Kubeflow using kustomize and raw YAML manifests feels cumbersome, requiring significant manual effort and maintenance.

*Scenario:*

Alex needs a fast and repeatable way to deploy only the necessary Kubeflow components while keeping the installation manageable and configurable.

Steps & Experience:

    *Discovering Helm Support for Kubeflow*
        Alex reads the updated Kubeflow documentation and finds that Helm is now an official installation method.
        The documentation provides a simple command to install only the necessary components.

    *Deploying Kubeflow with Helm*
        Alex runs a command to install only Kubeflow Pipelines and Katib.
        The Helm chart automatically handles dependencies and namespace creation, reducing manual steps.
Within minutes, the required services are running in the Kubernetes cluster.

    *Customizing the Deployment*
    Alex configures resource limits and storage settings by modifying the Helm values file.

    *Scaling and Managing the Deployment*
    Later, the team decides to add the Training Operator. Instead of redeploying everything, Alex simply enables it
    Helm seamlessly applies the changes, avoiding disruption to the existing setup.

    *Rolling Back* 
    A misconfiguration in values.yaml causes an issue. Instead of debugging manually, Alex rolls back to the previous working state

Outcome & Value:

✅ Fast, modular deployment – No need to install unnecessary components.
✅ Easy configuration – Fine-tune installations using Helm values.
✅ Smooth upgrades & rollbacks – No more breaking changes due to manual YAML edits.
✅ Better DevOps integration – Fits naturally into the team’s GitOps workflow with tools like ArgoCD

##### Alex's Outcomes: Easily Deploy Kubeflow Using Helm

Alex was able to deploy only the necessary Kubeflow components using Helm, avoiding the complexity of managing kustomize-based manifests. By running a single command, Alex installed Kubeflow Pipelines and Katib, making the deployment process fast, modular, and repeatable.
Customize Deployments with Helm Values

Alex configured the Kubeflow deployment using Helm values, fine-tuning resource limits and storage settings without modifying raw YAML files. By adjusting values.yaml, Alex was able to:

    Enable Pipelines and Katib, while keeping other components disabled.
    Set up a custom storage backend for Kubeflow Pipelines.
    Adjust CPU and memory limits for Katib experiments.
    These changes were seamlessly applied with a Helm upgrade, making the system highly customizable and adaptable.

*Use Helm’s Standardized Package Management Features*

Alex leveraged Helm’s built-in lifecycle management to ensure a smooth deployment experience:

    When a misconfiguration caused an issue, Alex rolled back to a stable deployment instantly using Helm’s versioning feature.
    Helm automatically handled dependencies, ensuring Pipelines and Katib were installed correctly without manual intervention.
    As new versions of Kubeflow components were released, Alex was able to upgrade seamlessly without having to reinstall everything.

*Deploy Individual Kubeflow Components*

Since Alex’s team only needed Kubeflow Pipelines and Katib, they didn’t have to deploy the entire Kubeflow stack. Instead, Helm allowed them to deploy only the necessary components, keeping the cluster lightweight and resource-efficient.
Lower the Barrier for Kubeflow Adoption

* Drive Adoption *
As someone new to Kubeflow, Alex benefited from clear documentation and a step-by-step guide for deploying components with Helm. Instead of spending hours understanding manifests and dependencies, Alex was able to get Kubeflow running in minutes. The modular Helm-based approach made it easy for the team to evaluate Kubeflow without committing to a complex setup.
Contribute to and Extend the Helm Chart

Alex’s organization saw value in Helm-based deployment and wanted to contribute improvements back to the community. By following a structured approach similar to Argo’s Helm charts, the team was able to extend the charts to support their own infrastructure needs while sharing their updates with the wider Kubeflow community.

Thanks to Helm, Kubeflow deployment became effortless, modular, and scalable—allowing Alex’s team to focus on building ML workflows instead of dealing with infrastructure complexity. Alex will get feedback from his ML team and using Kubeflow and motivate them to contribute improvements and feature requests to enhance the Kubeflow ecosystem. 



### Notes/Constraints/Caveats (Optional)
Alex may choose to use vanila manifests or go with a vendor after using Helm the goal is not to be an *official distro*, but more of a *community edition*. As appetite for community support grows, the scope may, but for now this is just a simple way to get Kubeflow running using a well know deployment pattern and provide examples of how to use it. 


### Risks and Mitigations
1. Fragmentation of Deployment Methods

Risk: Introducing Helm charts as an official deployment method may create fragmentation within the Kubeflow ecosystem, leading to confusion between Helm-based, kustomize-based, and third-party deployment tools (e.g., DeployKF).
Mitigation:

    Clearly position Helm as an alternative to kustomize, rather than a replacement.
    Maintain alignment with existing manifests, ensuring Helm charts remain consistent with official Kubeflow components.
    Provide comprehensive documentation comparing Helm, kustomize, and third-party solutions to help users choose the right approach for their needs. If a user wants to support a kustomize effort or KPT effort simialr to this Helm effort, we would empower them but set standards similar to this propsoal to ensure its success in the communtiy. 

2. Maintenance Burden and Long-Term Support

Risk: Maintaining a Helm chart requires ongoing updates as Kubeflow components evolve, which could become a burden if not properly resourced.
Mitigation:

    Adopt a community-driven maintenance model, similar to Argo’s Helm charts, allowing contributors to submit PRs and updates.
    Establish clear ownership within the Kubeflow community and define a process for versioning and deprecating charts.
    Regularly sync Helm charts with upstream manifests to prevent drift. There is potential for automation here.

3. Security Considerations

Risk: Misconfigured Helm deployments could introduce security vulnerabilities, such as exposed services, weak authentication, or misconfigured role-based access control (RBAC).
Mitigation:

    Follow Kubernetes security best practices, ensuring charts include secure default configurations (e.g., minimal privileges, network policies).
    Conduct security reviews as part of Kubeflow’s release cycle, involving SIG Security and community reviewers.
    Provide Helm values presets for secure and production-ready configurations. This is a fantastic opportunity for us to involve security professionals in the community and automate checks. 

4. UX Consistency and Documentation Gaps

Risk: If Helm-based deployment is not well-documented and user-friendly, it could lead to poor adoption or misconfigurations.
Mitigation:

    Ensure Helm charts follow a standard structure for ease of use and consistency.
    Provide step-by-step documentation, potentially including examples for different environments (e.g., local Minikube, cloud-managed Kubernetes).
    Gather feedback from users refine the Helm-based deployment experience.

5. Helm-Specific Limitations

Risk: Helm may not support all advanced Kubeflow deployment scenarios, such as fine-grained component patching that is easier with kustomize.
Mitigation:

    Document known limitations and provide recommendations for when kustomize or other tools may be more appropriate.
    Design Helm values with flexibility in mind, ensuring key configuration options are exposed.
    Allow users to override Helm-managed resources when necessary.



## Design Details

The Helm chart for Kubeflow will follow a modular structure similar to Argo’s Helm charts, allowing users to deploy individual components while maintaining flexibility for full-stack installations.
1. Helm Chart Structure

The repository will contain a root Helm chart (kubeflow) that acts as an umbrella for subcharts, enabling users to deploy only the components they need:

kubeflow-helm-chart/
│── charts/
│   │── training-operator/
│   │── katib/
│   │── pipelines/
│   │── istio/ (unsure how codependent we are on this one)
│   │── profiles/
│── templates/
│── values.yaml
│── Chart.yaml
│── README.md

    The root kubeflow chart will manage dependencies and shared configurations.
    Subcharts for each component (training-operator, katib, pipelines, etc.) allow independent deployments.
    Templates will provide base Kubernetes resources such as Deployments, Services, and ConfigMaps.
    The values.yaml file will expose configuration options for each component.

2. Example Helm Chart Configuration (values.yaml)

A default values.yaml file will allow users to enable/disable components and customize deployment settings:
```
# Global settings
global:
  namespace: kubeflow
  istio:
    enabled: true

# Enable/Disable specific components
pipelines:
  enabled: true
  mysql:
    persistence:
      storageClass: gp2
      size: 10Gi

katib:
  enabled: false

training-operator:
  enabled: true
  resources:
    limits:
      cpu: "2"
      memory: "4Gi"
```
3. Installing and Managing Kubeflow with Helm
Installation

To install Kubeflow Pipelines and the Training Operator only:

helm install kubeflow ./kubeflow-helm-chart --set pipelines.enabled=true --set training-operator.enabled=true

Upgrading Configuration

To enable Katib after the initial installation:

helm upgrade kubeflow ./kubeflow-helm-chart --set katib.enabled=true

Rolling Back a Deployment

If an upgrade introduces an issue, rollback to a previous working state:

helm rollback kubeflow 1


4. Security & Default Configurations

To ensure secure and production-ready deployments, the Helm chart will include:

    Minimal privileges using Role-Based Access Control (RBAC).
    Network policies to restrict component communication where necessary.
    Secure default values, with optional overrides for users needing customization.

Example RBAC template (templates/rbac.yaml):

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kubeflow-pipelines-role
rules:
- apiGroups: ["kubeflow.org"]
  resources: ["pipelines"]
  verbs: ["get", "list", "watch"]


Implementation Plan

    Create a GitHub repository (kubeflow/kubeflow-helm) to host the Helm charts.
    Define the Helm chart structure, ensuring compatibility with Kubeflow manifests.
    Develop subcharts for each major Kubeflow component (Pipelines, Katib, Training Operator, Istio, etc.).
    Write Helm values documentation, including examples for different environments.
    Test the Helm charts across various Kubernetes environments (Minikube, cloud-managed clusters).
    Engage the Kubeflow community for feedback and contributions.

    

### Test Plan
1. Unit Testing for Helm Templates

Each Helm template will be tested using Helm unittesting frameworks such as:

    helm-unittest – Validates Helm templates using YAML-based test cases.
    helm-template – Ensures templates render correctly without errors.

2. Linting & Static Analysis

    Helm Linting (helm lint) – Ensures best practices in chart structure and values.
    YAML Schema Validation – Ensures manifests follow correct Kubernetes API specifications.
    Kubeval & Kubeconform – Validates Kubernetes resources before applying them.

3. End-to-End Testing with CI/CD Pipelines
Tests will validate component functionality post-deployment (e.g., Pipelines UI loads, Katib runs experiments).
Kubeflow Pipelines sample execution will be tested using a simple pipeline job. 

4. Community Testing & User Feedback
Early adopters will be encouraged to test pre-release Helm charts and provide feedback via GitHub issues and the Kubeflow Slack #kubeflow-helm-chart channel.
A beta phase will allow broader testing before an official Helm release.

[ ] I/we understand the owners of the involved components may require updates to
existing tests to make this code solid enough prior to committing the changes necessary
to implement this enhancement.

#### Prerequisite testing updates

<!--
Based on reviewers feedback describe what additional tests need to be added prior
implementing this enhancement to ensure the enhancements have also solid foundations.
-->

#### Unit Tests

<!--
In principle every added code should have complete unit test coverage, so providing
the exact set of tests will not bring additional value.
However, if complete unit test coverage is not possible, explain the reason of it
together with explanation why this is acceptable.
-->

<!--
Additionally, try to enumerate the core package you will be touching
to implement this enhancement and provide the current unit coverage for those
in the form of:
- <package>: <date> - <current test coverage>
This can inform certain test coverage improvements that we want to do before
extending the production code to implement this enhancement.
-->

- `<package>`: `<date>` - `<test coverage>`

#### E2E tests

<!--
Describe what E2E tests will be added to ensure proper quality of the enhancement.
After the implementation PR is merged, add the names of the tests here.
-->

#### Integration tests

<!--
Describe what tests will be added to ensure proper quality of the enhancement.
After the implementation PR is merged, add the names of the tests here.
-->

### Graduation Criteria

<!--
This section is optional until Kubeflow has formally defined graduation criteria,
feature gates, and a deprecation policy.

Clearly define what it means for the feature to be implemented and
considered stable.
If the feature you are introducing has high complexity, consider adding graduation
milestones with these graduation criteria:
- [Maturity levels (`alpha`, `beta`, `stable`)][maturity-levels]
- [Feature gate][feature gate] lifecycle
- [Deprecation policy][deprecation-policy]
[feature gate]: https://git.k8s.io/community/contributors/devel/sig-architecture/feature-gates.md
[maturity-levels]: https://git.k8s.io/community/contributors/devel/sig-architecture/api_changes.md#alpha-beta-and-stable-versions
[deprecation-policy]: https://kubernetes.io/docs/reference/using-api/deprecation-policy/
-->

## Implementation History

<!--
Major milestones in the lifecycle of a KEP should be tracked in this section.
Major milestones might include:
- KEP Creation
- KEP Update(s)
- Implementation Start
- First Component and Kubeflow version where the KEP is released
- Component and Kubeflow version where the KEP is graduated
- When the KEP was retired or superseded
-->

## Drawbacks

<!--
Why should this KEP _not_ be implemented?
-->

## Alternatives

<!--
What other approaches did you consider, and why did you rule them out? These do
not need to be as detailed as the proposal, but should include enough
information to express the idea and why it was not acceptable.
-->
