# Kubeflow Bootstrapping

## Motivation

### Current Kubeflow bootstrapper requires cluster-admin privileges
The current bootstrapper generates a kubeflow application in a PersistentVolume and will optionally deploy it to the API server. The bootstrapper uses ksonnet to generate the kubernetes manifests that define the kubeflow runtime. The manifests are ordered within phases:
- optional creation of a Namespace
- creation of ClusterRoles and ClusterRoleBindings
- creation of namespace scoped resources
- creation of IAP/GCP single signon

The bootstrapper is run as cluster-admin although not all manifests require cluster-admin privileges.

### RBACs for data scientists aren't defined
A data scientist is authenticated either as an admin or a google user but service account RBACs are used when running processes.

Current RBAC related resources

| Action | ClusterRole | ClusterRoleBinding | ServiceAccount |
| :---: | :---: | :---: | :---: |
| train | tf-job-operator | tf-job-operator | tf-job-operator |
| job-dashboard | tj-job-dashboard | tf-job-dashboard | tf-job-dashboard |
| central-ui | centraldashboard | centraldashboard | centraldashboard |
| nfs | system:persistent-volume-provisioner | nfsnfs-provisioner | kubeflow:nfs |
| bootstrap | kube-metacontroller | kube-metacontroller | kubeflow:kube-metacontroller |
| bootstrap | cloud-endpoints-controller | cloud-endpoints-controller | kubeflow:cloud-endpoints-controller |





## Goals
Divide bootstrapper into 2 phases, each phase bound by a ClusterRole. Introduce a ManagedNamespace CRD which is used by data scientists to do the actual kubeflow deployment.

| phase | clusterrole | execution | description |
| :---: | :---: | :---: | :--- |
| init | cluster-admin | bootstrapper | Creates cluster level resources:<br/>ClusterRoles (kubeflow:admin, kubeflow:write, kubeflow:read), PersistentVolume, ManagedNamespace CRD and Controller |
| authn | cluster-admin | bootstrapper | Sets up auth provider under ambassador |
| authz | cluster-admin | controller | Generates namespace scoped resources:<br/>ManagedNamespace, Namespace, RoleBindings
| deploy | kubeflow-write | controller | Submits generated resources to API-server |
| delete | kubeflow-admin | controller | Removes ManagedNamespace and dependencies |


RBAC rules will be created to enable actions on resources at the cluster level and actions on resources scoped by a namespace. The bootstrap/authn phases will perform actions at the cluster level. The authz/deploy phases will perform actions within a namespace.


## Non-Goals
- Authentication of a data scientist. See the Provider proposal.
- Adding data scientists to an Organization Custom Resource and creating RoleBindings for members. See the RBAC proposal.

## UX

| An admin wants to initialize a cluster for kubeflow using a provider  |
| :--- |
|`/opt/kubeflow/bootstrapper --provider <provider> `|
|&nbsp;&nbsp;&nbsp;→ bootstrapper will check and see if the user has appropriate authorization|
|&nbsp;&nbsp;&nbsp;→ bootstrapper will create ClusterRoles for kubeflow admin, write and read|
|&nbsp;&nbsp;&nbsp;→ these ClusterRoles will be in `<provider>.libsonnet`|

| A data scientist wants to deploy kubeflow using his github org / team  |
| :--- |
|`/opt/kubeflow/deployer --org <organization> --team [<team>]`|
|&nbsp;&nbsp;&nbsp;→ bootstrapper will check and see if the user has appropriate authorization|
|&nbsp;&nbsp;&nbsp;→ bootstrapper will create ClusterRoles for kubeflow admin, write and read|
|&nbsp;&nbsp;&nbsp;→ the org name will be used for the admin RoleBinding during deployment |
|&nbsp;&nbsp;&nbsp;→ the team names will be used for the team  ClusterRoles |
|&nbsp;&nbsp;&nbsp;→ members will be mapped to RoleBindings that allow access to kubeflow namespaces based on team membership|
|&nbsp;&nbsp;&nbsp;→ these ClusterRoles will be in `<provider>.libsonnet`|

|An admin wants to provision persistent volumes that can be used by kubeflow deployments.|
| :--- |  
|`/opt/kubeflow/bootstrapper --vol <name ex: AmazonEBS> --id <ID> --mode <RWO/ROX/RWX> --num <number of volumes> --team[<team> <team> ...] typeparams <additional params> ` |
|&nbsp;&nbsp;&nbsp;→ bootstrapper will check and see if you have appropriate role bindings|
|&nbsp;&nbsp;&nbsp;→ Note, PV instance creation is done in a way that we can share the storage across namespaces.|
|&nbsp;&nbsp;&nbsp;→ Custom PV to PVC (namespaced) are exclusive. We need to create multiple PVs to use the underlying storage for sharing.|
|&nbsp;&nbsp;&nbsp;→ The creator of the PV specifies the teams which can use it.|


## Design

#### Changes to Existing Components

** 1. Modify bootstrapper to:**
  - Generate a PV
  - Generate ClusterRoles for Organization (admin), Team (write) and Member (write|read)
  - Generate CRDs for Organization, Team and Member
  - Add authprovider to ambassador

```
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: organization.kubeflow.org
spec:
  group: kubeflow.org
  version: v1
  scope: Namespaced
  names:
    plural: organizations
    singular: organization
    kind: Organization
    shortNames: ["org"]
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: team.kubeflow.org
spec:
  group: kubeflow.org
  version: v1
  scope: Namespaced
  names:
    plural: teams
    singular: team
    kind: Team
    shortNames: ["tm"]
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: member.kubeflow.org
spec:
  group: kubeflow.org
  version: v1
  scope: Namespaced
  names:
    plural: members
    singular: members
    kind: Member
    shortNames: ["mbr"]
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: kubeflow:admin,
rules:
- apiGroups:
  - *
  resources:
  - *
  verbs:
  - *
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: kubeflow:write,
rules:
- apiGroups:
  - *
  resources:
  - configmaps,
    pods,
    services,
    endpoints,
    persistentvolumeclaims,
    events
  verbs:
  - *
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: kubeflow:read,
rules:
- apiGroups:
  - *
  resources:
  - configmaps,
    pods,
    services,
    endpoints,
    persistentvolumeclaims,
    events
  verbs:
  - get,
    watch,
    list
```


## Alternatives Considered

## References
https://engineering.opsgenie.com/advanced-kubernetes-objects-53f5e9bc0c28
