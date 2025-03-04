# 649-Kubeflow-Helm-Support: Support Helm as an Alternative for Kustomize


The demand for a Helm chart for a basic Kubeflow installation has increased. Given the KSC's stance in issue 821 on neutral deployment language and user-defined production readiness, this is an opportune time to introduce a Helm chart. Supporting Helm will enhance ease of adoption and simplify deployments while maintaining the flexibility of community-maintained manifests. There have already been community efforts as well as the Kubeflow-Helm-Chart Slack Channel.


## Summary


Kubeflow manifests provide a fast way to deploy a minimal Kubeflow platform, with best-effort community support. For guaranteed assistance, users can opt for third-party distributions, consultants, or self-managed expertise. This approach extends to Helm chart support. Contributions and bug reports are encouraged, but no support will be guaranteed. The goal is to build a similar folder structure as Argo for Kubeflow Helm charts.


## Motivation


Currently, because Kubeflow/manifests are based on Kustomize, many potential users and companies that require Helm charts due to company processes/policies have to rely on third-party distributions. While these options are valuable, they require engagement with adjacent projects and communities.


As a project, we must ensure that our Helm chart provides a quick and accessible way for users to deploy a complete Kubeflow platform and individual components, enabling them to manage their environments or adopt a vendor solution.


Simplifying Kubeflow deployment lowers the barrier to entry, increases adoption, and encourages contributions. Just as Kubernetes enabled a new wave of cloud-native startups, a neutral, accessible deployment path can empower AI/ML startups to leverage tools like the Training Operator or Katib without reinventing common patterns. If support becomes burdensome, teams can hire expertise or use a distribution—both of which drive demand for Kubeflow skills.


By making deployment easy, we attract more end users and foster collaboration with broader communities like PyTorch, improving our implementations in service of their users.


## Goals


✅ A fully functional Kubeflow Helm chart for the targeted release. This will install Kubeflow as a platform and as an individual component. 
✅ Published Helm chart documentation with straightforward and uncomplicated configuration options. 
✅ A step-by-step tutorial simplifying Kubeflow deployment for users. 
✅ Contribution to the Kubeflow community effort for Helm-based installation as part of the official Kubeflow repository. 
✅ Where possible, rely on upstream Helm charts (i.e., KServe/Istio). 
✅ Consolidate community Helm efforts and prevent duplicate efforts.


## Non-Goals
* Deep integration with hyperscalers such as S3 object storage (basic Dex/oauth2-proxy config is valid).
* Infrastructure provisioning. Users can opt into OpenTofu or Crossplane to template the Helm chart with infrastructure. Still, we are focused on the Helm chart where the values would be configured (if a component requires knowledge of external systems).
* Support separate abstracted operators for components. Helm will handle upgrades.
* Provide guaranteed community support. 
* Define production for any particular set of users.


## Proposal
This proposal introduces official Helm chart support for deploying Kubeflow. The goal is to provide a modular, community-maintained method for installing and managing Kubeflow, making it more accessible for users who prefer Helm over Kustomize-based manifests.


## Desired Outcome


The Helm chart will allow users to: 


✅ Deploy Kubeflow with a single Helm command, reducing installation complexity. 
✅ Select specific components to install (e.g., Training Operator, Katib, Pipelines) without requiring the entire Kubeflow stack. 
✅ Configure installations via Helm values, enabling customization for different environments (e.g., resource allocation, authentication settings, storage options). 
✅ Upgrade and rollback Kubeflow deployments safely using Helm’s built-in version control. 
✅ Integrate with GitOps workflows (e.g., ArgoCD, FluxCD) for automated deployments. 
✅ Maintain a Helm chart structure similar to Argo’s, ensuring a familiar experience for Kubernetes users.


## Measuring Success


### Adoption Metrics


* Number of Helm chart downloads from the official Kubeflow repository.
* Community contributions to Helm chart improvements.
* Ease of Use and Community Engagement.
* Successful deployments reported by users via GitHub issues, Slack, and forums.
* Documentation feedback and tutorial completion rates.


### Modularity and Customization


* Verified Helm installations of the platform and individual components.
* Flexibility demonstrated in community-reported use cases (e.g., deploying only the Training Operator).


### Stability and Maintainability


* Helm-based deployments function consistently across Minikube, cloud-managed Kubernetes (EKS, GKE, AKS), and on-premises clusters.
* Contributions and maintenance of Helm charts remain sustainable within the Kubeflow community.


### User Stories (Optional)


#### Alex Conquers Kubeflow


**Background**


Alex is an ML engineer working at a mid-sized AI startup. The team wants to experiment with Kubeflow Pipelines and Katib for hyperparameter tuning but doesn’t need the full Kubeflow stack. Currently, deploying Kubeflow using Kustomize manifests feels cumbersome and requires significant manual effort and maintenance.


**Scenario:**


Alex needs a fast and repeatable way to deploy only the necessary Kubeflow components while keeping the installation manageable and configurable.


**Steps & Experience:** 


**Discovering Helm Support for Kubeflow** 
Alex reads the updated Kubeflow documentation and finds that Helm is now an official installation method. The documentation provides a simple command to install only the necessary components.


**Deploying Kubeflow with Helm** 
Alex runs a command to install only Kubeflow Pipelines and Katib. The Helm chart automatically handles dependencies and namespace creation, reducing manual steps. Within minutes, the required services are running in the Kubernetes cluster.


**Customizing the Deployment** 
Alex configures resource limits and storage settings by modifying the Helm values file.


**Scaling and Managing the Deployment** 
Later, the team decides to add the Training Operator. Instead of redeploying everything, Alex simply enables it. Helm seamlessly applies the changes, avoiding disruption to the existing setup.


**Rolling Back** 
A misconfiguration in values.yaml causes an issue. Instead of debugging manually, Alex rolls back to the previous working state.


**Outcome & Value:**


✅ Fast, modular deployment – No need to install unnecessary components. 
✅ Easy configuration – Fine-tune installations using Helm values. 
✅ Smooth upgrades and rollbacks – No more breaking changes due to manual YAML edits. 
✅ Better DevOps integration – Fits naturally into the team’s GitOps workflow with tools like ArgoCD. 


##### Alex's Outcomes: Easily Deploy Kubeflow Using Helm 
Alex could deploy only the necessary Kubeflow components using Helm, avoiding the complexity of managing Kustomize-based manifests. Alex installed Kubeflow Pipelines and Katib by running a single command, making the deployment process fast, modular, and repeatable.


**Customize Deployments with Helm Values.** 
Alex configured the Kubeflow deployment using Helm values, fine-tuning resource limits and storage settings without modifying raw YAML files. By adjusting values.yaml, Alex was able to: 


* Enable Pipelines and Katib while keeping other components disabled.
* Set up a custom storage backend for Kubeflow Pipelines.
* Adjust CPU and memory limits for Katib experiments.


These changes were seamlessly applied with a Helm upgrade, making the system highly customizable and adaptable.


**Use Helm’s Standardized Package Management Features** 
Alex leveraged Helm’s built-in lifecycle management to ensure a smooth deployment experience:


* When a misconfiguration caused an issue, Alex instantly rolled back to a stable deployment using Helm’s versioning feature.
* Helm automatically handled dependencies, ensuring Pipelines and Katib were installed correctly without manual intervention.
* As new versions of Kubeflow components were released, Alex could upgrade seamlessly without reinstalling everything.


**Deploy Individual Kubeflow Components** 
Since Alex’s team only needed Kubeflow Pipelines and Katib, they didn’t have to deploy the entire Kubeflow stack. Instead, Helm allowed them to deploy only the necessary components, keeping the cluster lightweight and resource-efficient.


**Drive Adoption** 
As someone new to Kubeflow, Alex benefited from clear documentation and a step-by-step guide for deploying components with Helm. Instead of spending hours understanding manifests and dependencies, Alex got Kubeflow running in minutes. The modular Helm-based approach made it easy for the team to evaluate Kubeflow without committing to a complex setup.


**Contribute to and Extend the Helm Chart.** 
Alex’s organization saw value in Helm-based deployment and wanted to contribute improvements back to the community. Following a structured approach similar to Argo’s Helm charts, the team could extend the charts to support their infrastructure needs while sharing their updates with the wider Kubeflow community. 


Thanks to Helm, Kubeflow deployment became effortless, modular, and scalable—allowing Alex’s team to focus on building ML workflows instead of dealing with infrastructure complexity. Alex will get feedback from his ML team using Kubeflow and motivate them to contribute improvements and feature requests to enhance the Kubeflow ecosystem.


### Notes/Constraints/Caveats
Alex may choose to use vanilla manifests or go with a vendor. The goal is not to be a distribution but still a part of Kubeflow/manifests. As the appetite for community support grows, the scope may expand, but for now, this is just a simple way to get Kubeflow running using a well-known deployment pattern and provide examples of how to use it.


## Risks and Mitigations


1. Fragmentation of Deployment Methods 


**Risk:** Introducing Helm charts as an official deployment method alongside Kustomize may create fragmentation within the Kubeflow ecosystem, leading to confusion between Helm-based, Kustomize-based, and third-party deployment tools. 


**Mitigation:**
* Clearly position Helm as an alternative to Kustomize, rather than a replacement.
* Maintain alignment with existing manifests, ensuring Helm charts remain consistent with official Kubeflow components.
* Provide comprehensive documentation comparing Helm, Kustomize, and third-party solutions.


2. Maintenance Burden and Long-Term Support


**Risk:** Maintaining a Helm chart requires ongoing updates as Kubeflow components evolve, which could become a burden if not adequately resourced.


**Mitigation:**
* Adopt a community-driven maintenance model, similar to Argo’s Helm charts.
* Establish clear ownership within the Kubeflow community and define a process for versioning and deprecating charts.
* Regularly sync Helm charts with upstream manifests to prevent drift.


3. Security Considerations


**Risk:** Misconfigured Helm deployments could introduce security vulnerabilities, such as exposed services, weak authentication, or misconfigured role-based access control (RBAC).


**Mitigation:**
* Follow Kubernetes security best practices, ensuring charts include secure default configurations.
* Conduct security reviews as part of Kubeflow’s release cycle.
* Provide Helm values presets for secure and production-ready configurations.


## Design Details


### Helm Chart Structure


The repository will contain a root Helm chart (kubeflow) that acts as an umbrella for subcharts: 


```
kubeflow/manifests/experimental/helm
│── charts/
│   │── training-operator/
│   │── katib/
│   │── pipelines/
│   │── istio/
│   │── profiles/
│   │── common/
│   │── kserve/
│── templates/
│── values.yaml
│── Chart.yaml
│── README.md
``` 


* The root kubeflow chart will manage dependencies and shared configurations. 
* Subcharts for each component (training-operator, katib, pipelines, etc.) allow independent deployments.


### Example Helm Chart Configuration (values.yaml)


```yaml
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


### Installation


To install Kubeflow Pipelines and the Training Operator only: 


```
helm install kubeflow ./kubeflow-helm-chart --set pipelines.enabled=true --set training-operator.enabled=true
```


To enable Katib after the initial installation: 


```
helm upgrade kubeflow ./kubeflow-helm-chart --set katib.enabled=true
```


To roll back a deployment: 


```
helm rollback kubeflow 1
```


### Security and Default Configurations


To ensure secure and production-ready deployments, the Helm chart will include:


* Minimal privileges using Role-Based Access Control (RBAC) and Pod Security Standards restricted.
* Network policies to restrict component communication where necessary.
* Secure default values, with optional overrides for users needing customization.


Example RBAC template (templates/rbac.yaml):


```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
 name: kubeflow-pipelines-role
rules:
- apiGroups: ["kubeflow.org"]
 resources: ["pipelines"]
 verbs: ["get", "list", "watch"]
```


### Implementation Plan


* Create a subdirectory (kubeflow/manifests/experimental/helm) to host the Helm charts.
* Define the Helm chart structure, ensuring compatibility, synchronizability, and a single source of truth with the Kustomize manifests.
* Develop subcharts for each major Kubeflow component (Pipelines, Platform, Notebooks, Dashboard, Katib, Training Operator, Istio, etc.) and make them deployable simultaneously to replicate the kustomize manifests.
* Write Helm values documentation, including examples for different environments (Dex vs oauth-proxy and authentication).
* Test the Helm charts as we test the Kustomize manifests.
* Engage the Kubeflow community for feedback and contributions.


### Test Plan
1. Unit Testing for Helm Templates 
Each Helm template will be tested using Helm unit testing frameworks such as:
* helm-unittest – Validates Helm templates using YAML-based test cases.
* helm-template – Ensures templates render correctly without errors.
* This shall happen in the same GHA used for Kustomize since the output should stay the same.


2. Linting and Static Analysis
* Helm Linting (helm lint) – Ensures best practices in chart structure and values.
* YAML Schema Validation – Ensures manifests follow correct Kubernetes API specifications.
 Kubeval & Kubeconform – Validates Kubernetes resources before applying them.
* We already have that repository-wide and can just add helm linting.


3. End-to-End Testing with CI/CD Pipelines
* Tests will validate component functionality post-deployment (e.g., Pipelines UI loads, Katib runs experiments).
* We shall reuse/extend the Kustomize tests, if the output is the same, we can test Helm and Kustomize simultaneously in the same GHA.


4. Community Testing and User Feedback
* Early adopters will be encouraged to test pre-release Helm charts and provide feedback via GitHub issues and the Kubeflow Slack #kubeflow-helm-chart channel.
* A beta phase will allow broader testing before an official Helm release.


[ X] I/we understand the components' owners may require updates to existing tests to make this code solid before committing the changes necessary to implement this enhancement.


#### Prerequisite Testing Updates


Since this is a replication of the Kustomize manifests, most of the testing infrastructure is already in place.


#### E2E Tests
The integration tests will be very similar to and based on the ones we have for the Kustomize manifests.


#### Integration Tests


The end-to-end tests will be very similar to and based on the ones we have for the Kustomize manifests.


### Graduation Criteria


Reach feature-parity with the Kustomze manifests


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
### Potential Drawbacks include:
* Users may expect Helm charts to be fully "production ready" and engage the community for out-of-scope support/contributions.
* Helm chart complexity may become burdensome to manage and strain community resources.
* Helm may have unforeseen limitations.


## Alternatives
### Glasskube
[Glasskube](https://github.com/glasskube/glasskube) was initially explored as a potential way to improve our deployment. That community [has made an effort](https://glasskube.dev/blog/kubeflow-setup-guide/), but we've yet to see more traction. Their implementation is not as widely adopted, and we may struggle finding contributors. Should the Glasskube community build a Kubeflow distribution/installation method, we'd gladly support them in this effort, but we have not seen a push for Glasskube like we've seen for Helm.


### KPT
The [GCP Distribution](https://googlecloudplatform.github.io/kubeflow-gke-docs/docs/) uses KPT, but it requires maintaining KPT containers for function calls and is not as easily integrated with upstream communities that've standardized on Helm. We'd need to consider upstream vanilla manifests and use KPT.


### Crossplane
[The Crossaplane project](https://www.crossplane.io/) could be used to template manifests with a higher-level manifest, but that project is more suited for templating and infrastructure management. We've yet to see any community traction for a Crossplane-powered Kubeflow distribution; therefore, resourcing may be difficult and could lead to a longer lead time versus using Helm.





