# Kubeflow Bootstrapping

## Motivation

### Current Kubeflow bootstrapper requires cluster-admin privileges
The current bootstrapper creates cluster level resources which are typically one time activities. The bootstrapper also creates a namespace and namespace scoped resources required to run kubeflow jobs and operators. The bootstrapper will optionally create single-signon using IAP/GCP that is a one time activity. Not all activities need to be run with cluster wide admin privileges and RBAC bindings should be changed to be namespace specific and include the user as the subject.

### RBACs for data scientists aren't defined
A data scientist is authenticated either as an admin or a google user but service account RBACs are used when running processes.

Current RBAC Rules

| Action | ClusterRole | ClusterRoleBinding | ServiceAccount |
| :---: | :---: | :---: | :---: |
| train | tf-job-operator | tf-job-operator | tf-job-operator |
| job-dashboard | tj-job-dashboard | tf-job-dashboard | tf-job-dashboard |
| nfs | system:persistent-volume-provisioner | tf-job-dashboard | tf-job-dashboard |



## Goals
RBAC roles should be created to distinguish between cluster level operations and namespace scoped operations. The initial bootstrapping phases should create cluster roles for kubeflow admins, writers and readers. These bindings should allow a data scientist to create a namespace and deploy kubeflow to that namespace. ServiceAccounts should use a RoleBinding of the user rather than the existing ClusterRoleBinding.


## Non-Goals
- Authentication of a data scientist (provider setup)
- Adding data scientists to RBAC Organization and Team ClusterRoleBindings

## UX

| An admin wants to initialize a cluster for subsequent kubeflow deployments specific to a team within an organization |
| :--- |
|`/opt/kubeflow/bootstrapper init --provider <provider> --org <organization> [--team <team> <team> ...]`|
|&nbsp;&nbsp;&nbsp;→ bootstrapper will check and see if the user has appropriate authorization|
|&nbsp;&nbsp;&nbsp;→ bootstrapper will create ClusterRoles for kubeflow admin, write and read|
|&nbsp;&nbsp;&nbsp;→ the org name will be used to define an admin  ClusterRole|
|&nbsp;&nbsp;&nbsp;→ the team names will be used to define team  ClusterRoles |
|&nbsp;&nbsp;&nbsp;→ members will be mapped to RoleBindings that allow access to kubeflow namespaces based on team membership|
|&nbsp;&nbsp;&nbsp;→ these definitions and logic will be in a `<provider>.libsonnet`|

|An admin wants to provision persistent volumes that can be used by kubeflow deployments.|
| :--- |  
|`/opt/kubeflow/bootstrapper init --vol <name ex: AmazonEBS> --id <ID> --mode <RWO/ROX/RWX> --num <number of volumes> --team[<team> <team> ...] typeparams <additional params> ` |
|&nbsp;&nbsp;&nbsp;→ bootstrapper will check and see if you have appropriate role bindings|
|&nbsp;&nbsp;&nbsp;→ Note, PV instance creation is done in a way that we can share the storage across namespaces.|
|&nbsp;&nbsp;&nbsp;→ Custom PV to PVC (namespaced) are exclusive. We need to create multiple PVs to use the underlying storage for sharing.|
|&nbsp;&nbsp;&nbsp;→ The creator of the PV specifies the teams which can use it.|


## Design

#### Changes to Existing Components

Modify bootstrapper to include the init subcommand:
- creates PVs
- creates Pod Security Context policies
- creates ClusterRoles for Organization, Team and Member
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
```

## Alternatives Considered

## References
https://engineering.opsgenie.com/advanced-kubernetes-objects-53f5e9bc0c28
