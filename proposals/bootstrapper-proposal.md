# Kubeflow Bootstrapping Modifications

## Motivation

### Current Kubeflow bootstrapper requires cluster-admin privileges
The current bootstrapper generates a kubeflow application into a PersistentVolume and will optionally deploy it to the API-server. The bootstrapper uses ksonnet to generate the kubernetes manifests that define the kubeflow runtime. The manifest generation by ksonnet is ordered across phases:
- optional creation of a Namespace
- creation of ClusterRoles and ClusterRoleBindings
- creation of namespace scoped resources (services, serviceaccounts, ...)
- creation of IAP/GCP single signon

The bootstrapper is run as cluster-admin although not all phases above require cluster-admin privileges.

### RBAC rules for data scientists aren't utilized
A data scientist is authenticated either as an admin or a google user (via IAP) but service account RBACs are used when running processes. Actions and their RBACs are shown below:

| Action | ClusterRole | ClusterRoleBinding | ServiceAccount |
| :---: | :---: | :---: | :---: |
| train | tf-job-operator | tf-job-operator | tf-job-operator |
| job-dashboard | tj-job-dashboard | tf-job-dashboard | tf-job-dashboard |
| central-ui | centraldashboard | centraldashboard | centraldashboard |
| nfs | system:persistent-volume-provisioner | nfsnfs-provisioner | kubeflow:nfs |
| IAP | cloud-endpoints-controller | cloud-endpoints-controller | kubeflow:cloud-endpoints-controller |


## Goals
Divide bootstrapper into 2 phases: an initialization phase and a deployment phase. Each phase will run with different authorizations/users.

Introduce a ManagedNamespace CRD and controllers. Submitting a ManagedNamespace CR will execute the deployment phase without requiring the data scientist to have cluster-admin privileges.

| phase | user | executed by | description |
| :---: | :---: | :---: | :--- |
| initialization | cluster-admin | bootstrapper | Create cluster level resources:<br/>ClusterRoles (kubeflow:admin, kubeflow:write, kubeflow:read), PersistentVolume, ManagedNamespace CRD and Controller |
| initialization<br/>(authentication) | cluster-admin | bootstrapper | Configure auth provider under ambassador<br/>(separate proposal) |
| deployment<br/>(authorization) | data scientist | controller | Process ManagedNamespace CR<br/>Create RoleBindings for users in Organization
| deployment | data scientist | controller | Continue with normal deployment processing normally done in [Server.Run](https://github.com/kubeflow/kubeflow/blob/master/bootstrap/cmd/bootstrap/app/server.go) |


RBAC rules will be created to enable actions on resources at the cluster level and actions on resources scoped by a namespace. The initialization phases will perform actions at the cluster level. The deployment phases will perform actions within a namespace. ServiceAccounts will be modified to use RoleBindings of the active user.


## Non-Goals
Authentication of a data scientist using an auth provider. This will be described in a subsequent **authn** proposal that also adds github as an auth provider.

## UX

| An admin wants to initialize a cluster for kubeflow using a provider  |
| :--- |
|`kubectl run --image=gcr.io/kubeflow-images-public/bootstrap:latest --command -- /opt/kubeflow/bootstrapper --provider <provider>`|
|&nbsp;&nbsp;&nbsp;→ bootstrapper will check and see if the user has appropriate authorization|
|&nbsp;&nbsp;&nbsp;→ bootstrapper will apply `<provider>.libsonnet`.|
|&nbsp;&nbsp;&nbsp;→ See [Design](#design) for details.|

| A data scientist wants to deploy kubeflow for herself and a few others  |
| :--- |
|`kubectl create -f kubeflow.yaml`|
|&nbsp;&nbsp;&nbsp;→ the controller will check and see if the user has appropriate authorization|
|&nbsp;&nbsp;&nbsp;→ members will be mapped to RoleBindings that allow access to kubeflow namespaces based on team membership|
|&nbsp;&nbsp;&nbsp;→ See [Design](#design) for details.|


## Design

#### Changes to Existing Components

** 1. Modify bootstrapper to: **
- Use a `<provider>.libsonnet` which includes:
  - ManagedNamespace, Organization, Team, Member CRDs<br/>
  - CompositeController, DecoratorController from metacontroller
  - ClusterRoles for kubeflow (admin, write, read)

``` yaml
apiVersion: apiextensions.k8s.io/v1beta
kind: CustomResourceDefinition
metadata:
  name: member.kubeflow.org
spec:
  group: kubeflow.org
  version: v1alpha1
  scope: Namespaced
  names:
    plural: managednamespaces
    singular: managednamespace
    kind: ManagedNamespace
    shortNames: ["mns"]
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: organization.kubeflow.org
spec:
  group: kubeflow.org
  version: v1alpha1
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
  version: v1alpha1
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
  version: v1alpha1
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
---
apiVersion: metacontroller.k8s.io/v1alpha1
kind: DecoratorController
metadata:
  name: kubeflow-bootstrapper
spec:
  resources:
  - apiVersion: v1alpha1
    resource: managednamespace
    labelSelector:
      matchExpressions:
      - {key: namespace-created, operator: DoesNotExist}
  hooks:
    sync:
      webhook:
        url: http://kubeflow-bootstrapper.metacontroller/bootstrap
---
apiVersion: metacontroller.k8s.io/v1alpha1
kind: CompositeController
metadata:
  name: kubeflow-deployer
spec:
  parentResource:
    apiVersion: kubeflow.org/v1alpha1
    resource: managednamespace
  childResources:
  - apiVersion: kubeflow.org/v1alpha1
    resource: organization
    updateStrategy:
      method: InPlace
  hooks:
    sync:
      webhook:
        url: http://kubeflow-deployer.metacontroller/deploy
```

** 2. Deploy using kubectl create -f `<kubeflow>.yaml` **
- Use a `<kubeflow>.yaml` which includes:
  - PersistentVolume (from kubeflow_toolkit.yaml)<br/>
  - ManagedNamespace CR (shown below)
  - The metacontrollers noted in Section 1. above will create resources
  - The metacontrollers hooks are still **WIP**

``` yaml
apiVersion: kubeflow.org/v1alpha1
kind: ManagedNamespace
metadata:
  name: kubeflow-jdoe
organization:
  name: Acme
  teams:
  - name: ds-delta
    members:
    - member:
      github: jdoe
      slack: jdoe
      firstName: Jane
      lastName: Doe
      affiliation: Doe Inc
      email: jdoe@doeinc.com
    - member:
      github: msmith
      slack: msmith
      firstName: Mike
      lastName: Smith
      affiliation: Doe Inc
      email: msmith@doeinc.com
```



## Alternatives Considered
Using [kubeless](https://kubeless.io/) functions rather than [metacontroller](https://github.com/GoogleCloudPlatform/metacontroller) controllers

## References
https://engineering.opsgenie.com/advanced-kubernetes-objects-53f5e9bc0c28
