# Kubeflow Bootstrapping

## Motivation

### Current Kubeflow bootstrapper requires cluster-admin privileges
The current bootstrapper will create cluster level resources which are typically one time activities. The bootstrapper will then create a namespace and namespace scoped resources required to run kubeflow jobs and operators. Finally, the bootstrapper will optionally create single-signon to GCP using IAP that is also a one time activity.

### RBAC for data scientists isn't defined
The authenticated user's authorization is not used when creating Persistent Volumes or running processes. In general elevated privileges are used in most scenarios with no differentiation between a role that *deploys* kubeflow and a role that *uses* kubeflow (data scientist).

## Goals
RBAC roles should be created to distinguish between cluster level operations and namespace scoped operations. The initial bootstrapping phases should create cluster roles and cluster rolebindings for data scientists. These bindings should allow a data scientist to create a namespace and deploy kubeflow to that namespace.


## Non-Goals
- Authentication of a data scientist (provider setup)
- Creating members
- Adding members to RBAC Organization and Team ClusterRoleBindings

## UI or API

| An admin wants to initialize a cluster for subsequent kubeflow deployments |
| :--- |
|`/opt/kubeflow/bootstrapper init --org <organization> --team[<team> <team> ...] --provider <gcp┃github>`|
|&nbsp;&nbsp;&nbsp;→ bootstrapper will check and see if you have appropriate role bindings|
|&nbsp;&nbsp;&nbsp;→ bootstrapper will create ClusterRole, ClusterRoleBindngs|
|&nbsp;&nbsp;&nbsp;→ the org name will be used to define an org owner ClusterRole|
|&nbsp;&nbsp;&nbsp;→ the team names will be used to define a team owner ClusterRole|
|&nbsp;&nbsp;&nbsp;→ members will be mapped to ClusterRoles that allow access to kubeflow namespaces based on team membership|

|An admin wants to provision custom volumes that can be used by kubeflow deployments.|
| :--- |  
|`/opt/kubeflow/bootstrapper init --vol <name ex: AmazonEBS> --id <ID> --mode <RWO/ROX/RWX> --num <number of volumes> --team[<team> <team> ...] typeparams <additional params> ` |
|&nbsp;&nbsp;&nbsp;→ bootstrapper will check and see if you have appropriate role bindings|
|&nbsp;&nbsp;&nbsp;→ Note, PV instance creation is done in a way that we can share the storage across namespaces.|
|&nbsp;&nbsp;&nbsp;→ Custom PV to PVC (namespaced) are exclusive. We need to create multiple PVs to use the underlying storage for sharing.|
|&nbsp;&nbsp;&nbsp;→ The creator of the PV specifies the teams which can use it.|


## Design

Need to define a metacontroller so that certain resources are created from bootstrapper init. This is being done for CloudEndpoints

#### Changes to Existing Components

Modify bootstrapper to include the subcommand init subcommand:
- creates PVs
- creates Pod Security Context policies
- creates ClusterRoles and ClusterRoleBindings for Organization, Team and Member

Member:
- can create a Namespace
- can create Pods in their Namespace
- can create ServiceAccounts in their Namespace
- can create Containers in their Namespace
- can create Persistent Volume Claims in their Namespace
- can connect via gateway to services in assigned namespaces
- can add rolebindings in assigned namespaces (add users)

## Alternatives Considered


## References
https://engineering.opsgenie.com/advanced-kubernetes-objects-53f5e9bc0c28
