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

Current RBAC Rules

| Action | ClusterRole | ClusterRoleBinding | ServiceAccount |
| :---: | :---: | :---: | :---: |
| train | tf-job-operator | tf-job-operator | tf-job-operator |
| job-dashboard | tj-job-dashboard | tf-job-dashboard | tf-job-dashboard |
| central-ui | centraldashboard | centraldashboard | centraldashboard |
| nfs | system:persistent-volume-provisioner | nfsnfs-provisioner | kubeflow:nfs |
| bootstrap | kube-metacontroller | kube-metacontroller | kubeflow:kube-metacontroller |
| bootstrap | cloud-endpoints-controller | cloud-endpoints-controller | kubeflow:cloud-endpoints-controller |





## Goals
Divide bootstrapper into a set of phases, each phase bound by a ClusterRole

| phase | clusterrole |
| :---: | :---: |
| bootstrap | cluster-admin |
| authn | cluster-admin |
| authz | kubeflow-admin |
| deploy | kubeflow-write |

RBAC roles should be created to distinguish between cluster level operations and namespace scoped operations. The bootstrap phase should create cluster roles for kubeflow admins, writers and readers.
The existing ClusterRoles, ClusterRoleBindings should be removed. The existing ServiceAccounts should use a RoleBinding of the user rather than the existing ClusterRoleBinding. The deployment of kubeflow to a namespace should be done using the user's RoleBinding and within a deployment phase rather than this bootstrap phase.




## Non-Goals
- Authentication of a data scientist (provider setup)
- Adding data scientists to RBAC Organization and Team ClusterRoleBindings
- Deployment of kubeflow

## UX

| An admin wants to initialize a cluster for subsequent kubeflow deployments specific to a team within an organization |
| :--- |
|`/opt/kubeflow/bootstrapper init --provider <provider> --org <organization> [--team <team> <team> ...]`|
|&nbsp;&nbsp;&nbsp;→ bootstrapper will check and see if the user has appropriate authorization|
|&nbsp;&nbsp;&nbsp;→ bootstrapper will create ClusterRoles for kubeflow admin, write and read|
|&nbsp;&nbsp;&nbsp;→ the org name will be used for the admin RoleBinding during deployment |
|&nbsp;&nbsp;&nbsp;→ the team names will be used for the team  ClusterRoles |
|&nbsp;&nbsp;&nbsp;→ members will be mapped to RoleBindings that allow access to kubeflow namespaces based on team membership|
|&nbsp;&nbsp;&nbsp;→ these ClusterRoles will be in `<provider>.libsonnet`|

|An admin wants to provision persistent volumes that can be used by kubeflow deployments.|
| :--- |  
|`/opt/kubeflow/bootstrapper init --vol <name ex: AmazonEBS> --id <ID> --mode <RWO/ROX/RWX> --num <number of volumes> --team[<team> <team> ...] typeparams <additional params> ` |
|&nbsp;&nbsp;&nbsp;→ bootstrapper will check and see if you have appropriate role bindings|
|&nbsp;&nbsp;&nbsp;→ Note, PV instance creation is done in a way that we can share the storage across namespaces.|
|&nbsp;&nbsp;&nbsp;→ Custom PV to PVC (namespaced) are exclusive. We need to create multiple PVs to use the underlying storage for sharing.|
|&nbsp;&nbsp;&nbsp;→ The creator of the PV specifies the teams which can use it.|


## Design

#### Changes to Existing Components

** 1. Modify bootstrapper to include the init subcommand:**
  - creates PVs
  - creates Pod Security Context policies
  - creates ClusterRoles for Organization (admin), Team (write) and Member (write|read)
  - creates CRDs for Organization, Team and Member

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
** 2. Modify bootstrapper so it doesn't do deployment but only writes to the Persistent Volume. Deployment is executed by a different golang cmd run by the active user and described in the Deployment section **

#### New Components

** 1. Create a deployer golang cmd that deploys the kubeflow application generated to the Persistent Volume:**


## Alternatives Considered

## References
https://engineering.opsgenie.com/advanced-kubernetes-objects-53f5e9bc0c28
