
## Motivation
Kubeflow uses a namespace to isolate resources created to run components and also provides a single-signon authentication using GCP's IAP (identity aware proxy). However the mapping of the authentication user with both data and processes isn't well defined and in general roles requiring elevated privileges are used in most scenarios including those where a data scientist is creating processes within containers, mounting volumes, etc.

Providing different authentication providers beyond IAP, setting RBAC bindings for these users and aligning these users with service accounts (via subjects) will allow better resource tracking at the user level, less opportunity to inadvertently remove or update resources within shared kubeflow environments and establish a reasonable threat model.

Data scientist are used to working with authorities like GitHub and use it for managing the models/assets of a project by assigning appropriate privileges to the repos. It would greatly simplify the UX for data scientist to model k8s project on the associated GitHub repos as it does not require ramp-up on k8s concepts.

A solution which is self-serving is highly desired as a data scientist would not like to go through an approving entity like an admin operator/IT support which causes unnecessary delays.

To address the pain points above, we propose the project ML Authorization Toolkit.

![sequence diagram](problem.jpg)

**Configuration Stage:**
   Configuring a k8s cluster to provide project sandboxes and consistent authentication requires knowledge of:

   - Developing/integrating plugins for the desired authentication mechanism

   - Configuring API server to setup the correct authentication mechanism

   - Kubernetes concepts such as injecting a user role using a authentication provider into ClusterRoleBindings, ServiceAccounts, Namespaces to setup correct authorization

**Consuming Services on K8s Cluster**
 - It is not trivial for a data scientist to support single sign-on for an authority like GitHub or LDAP

 - Data scientists are given excessive permissions preventing control over specific actions

 - Service Accounts used to perform user actions do not represent the actual privileges of the user creating
   vulnerabilities in the cluster. In most scenarios, service accounts have excessive permissions. Ex: jupyter-hub, tf-job-operator service accounts

 - Isolating [data](https://github.com/NervanaSystems/dls-features/issues/22) from [projects and users](https://github.com/NervanaSystems/dls-features/issues/58) is not often easily possible.
   Importing or gaining access to this data presents challenges most often solved by copying data from the source or
   granting access to a general population of users or a 'default' ServiceAccount.

- [Sharing](https://github.com/NervanaSystems/dls-features/issues/20) a data scientist's data with peers or external parties
  is difficult or impossible. This data may reside in a number of places outside a cluster such as github, laptop, or distributed
  file systems such as S3 or NFS. Ownership of data many vary in each place along with differing authorization models such
  as tokens, trusted certificates or external proxy.


## Goals
- Introduce the concept of a project: a sandbox where collaborating teams and individuals have role based access controls.

- Make it easy for data scientist to create projects with no devops involvement

- Provide a authentication service with single sign-on to access K8s API by leveraging a service data scientists are already familiar with ex: GitHub

- Provide a authentication mechanism for services hosted on k8s cluster by using same authentication mechanism used for authenticating k8s API.

- Make it easy for a data scientist to join a team and work within one or more projects

- Data scientist can do self-service without compromising on security while maintaining the boundaries of the project

- Make it easy for data scientist to share and isolate data within the cluster without compromising on controls



## Non-Goals
- Introduce the concept of a project: a sandbox where collaborating teams and individuals have role based access controls.

- Make it easy for data scientist to create projects with no devops involvement

- Provide a authentication service with single sign-on to access K8s API by leveraging a service data scientists are already familiar with ex: GitHub

- Provide a authentication mechanism for services hosted on k8s cluster by using same authentication mechanism used for authenticating k8s API.

- Make it easy for a data scientist to join a team and work within one or more projects

- Data scientist can do self-service without compromising on security while maintaining the boundaries of the project

- Make it easy for data scientist to share and isolate data within the cluster without compromising on controls


## UI or API
| An admin wants to configure the cluster for projects by using an external identity provider (ex GitHub). This may require updating the API server. |
| :--- |
|`kf configure --provider <providername> --APIServerConfig <configtemplate> --org <name>`|
|&nbsp;&nbsp;&nbsp;→ API server can discover the public signing keys using a discovery URL https://kubernetes.io/docs/admin/authentication/#openid-connect-tokens|
|&nbsp;&nbsp;&nbsp;→ This is a one time process for each authentication provider and needs to be done with an admin user on the cluster.|
|&nbsp;&nbsp;&nbsp;→ The org name will be used to discover the org owner to assign appropriate privileges (read/write)|
|&nbsp;&nbsp;&nbsp;→ The org owner will have a cluster-wide role with edit privileges over all projects. The clusterrolebindings are created using the admin role during the discovery process for the org.|
|&nbsp;&nbsp;&nbsp;→ We assign to the system:authenticated group the ability to create namespaces so that any authenticated used can create a namespace.|
|&nbsp;&nbsp;&nbsp;→   https://docs.openshift.com/container-platform/3.4/admin_solutions/user_role_mgmt.html|
|&nbsp;&nbsp;&nbsp;→ Authenticator uses the org name to allow access.|

| A data scientist wants to authenticate once and then work on a variety of projects |
| :--- |
|`kf login`|
|&nbsp;&nbsp;&nbsp;→ Token is stored locally on the client.|

|An admin wants to create a project for data scientists team (using an authentication provider of GitHub from above)|
| :--- |
|`kf create project`|
|&nbsp;&nbsp;&nbsp;→ When a request is made to create a project(namespace), the authentication and authorization passes.|
|&nbsp;&nbsp;&nbsp;→ The admission controller does the rolebinding for the namespace giving the user "admin" privileges for the namespace.|
|&nbsp;&nbsp;&nbsp;→ This is done one time at the point of creation of project.|  
|&nbsp;&nbsp;&nbsp;→ Additionally the user is given the privileges to create Custom PV by the admission controller.|

|An admin wants to provision the custom volumes to be shared within the cluster.|
| :--- |  
|`kf provisiondatasets --type <name ex: AmazonEBS> ID <ID> mode <RWO/ROX/RWX> instances <number of volumes>  namespaces <list of namespaces> typeparams <additional params> ` |
|&nbsp;&nbsp;&nbsp;→ This is executed by kubernetes cluster admin|
|&nbsp;&nbsp;&nbsp;→ Note, PV instance creation is done in a way that we can share the storage across namespaces.|
|&nbsp;&nbsp;&nbsp;→ Custom PV to PVC (namespaced) are exclusive. We need to create multiple PVs to use the underlying storage for sharing.|
|&nbsp;&nbsp;&nbsp;→ The creator of the PV specifies the namespaces which can bind to it. This will be checked by the admission controller or operator during binding.|

|A data scientist may be a member of multiple projects. |
| :--- |
|`kf project`|
|&nbsp;&nbsp;&nbsp;→ Finds the current project he is bound to|

|A data scientist wants a listing of projects where he/she has a role.|
| :--- |
|`kf projects --owner`|
|&nbsp;&nbsp;&nbsp;→ Filters can be applied like --owner|

|A data scientist (owner of the project) wants to add/modify/delete user|
| :--- |
|`kf user --add/--modify/--delete <user /template name>`|

|A data scientist (owner of the project) wants to add/modify/delete group|
| :--- |
|`kf group <group template name> --add/--delete <username>`|

| A data scientist wants to validate the environment.|
| :--- |
|`kf validate`|
|&nbsp;&nbsp;&nbsp;→ Validates the security configuration of the current project.|
|&nbsp;&nbsp;&nbsp;→ Checks rolebindings outside of the project and flags anamolies.|

| A data scientist wants to execute the training jobs.|
| :--- |
|`kf train`|
|&nbsp;&nbsp;&nbsp;→ It would be equivalent of creating pods with mounted volumes, copying the training script and executing the training|
|&nbsp;&nbsp;&nbsp;→ Data scientists could use also kubectl commands directly like connect to the pods and inspect all the logs.|

| A data scientist wants to create notebook session or connect ot existing session.|
| :--- |
|`kf notebook`|
|&nbsp;&nbsp;&nbsp;→ Creating new session or listing running sessions|
|&nbsp;&nbsp;&nbsp;→ Data scientists is authenticated and authorized in the browser by the ambassador gateway and redirected to the notebook session.|

| A data scientist wants to open tensorboard frontend to inspect the training progress.|
| :--- |
|`kf tensorboard`|
|&nbsp;&nbsp;&nbsp;→ CLI is creating or listing a tensorboard instances with mounted volumes of associated namespace.|
|&nbsp;&nbsp;&nbsp;→ Data scientists is authenticated and authorized in the browser by the ambassador gateway and redirected to the notebook session.|


Note: All operations on the namespace configuration would be done via k8 API and the commands kf in the examples above would be just wrappers to simplify the usage.
Alternatively standart call could be used to have full flexibility.

## Design
- Develop templates for typical API server configuration, DL projects, groups, roles, rolebindings and pod security policies (new ferature in K8 1.10)

- Introduce a CLI that provides an extensible set of subcommands that do common operations on projects and teams.

- Develop/Integrate SSO for providers like GitHub, Atlassian, LDAP etc.

- May need to introduce CRD for project - need to research further

- token based authentication for K8 API (openid connect token) and services hosted on the cluster (via API gateway) with oauth server installed in the cluster (dex or uaa)
#### New Components

- Templates for DL API server configuration, projects, groups, roles, rolebindings and pod security policy
- CLI for project, team operations
- kubectl plugin for user authentication handle openid token retrieval - kubectl login
- Authorization Provider for SSO
- API gateway based on ambassador component with enternal authentication and authorization
- auth service


#### Changes to Existing Components

- API Gateway (Ambassador) - in case of kubeflow with existing ambassador instance new API endpoint should be added to perform authorized operations on K8 resources on top of envoy component. Ambassador can be configured to work with a third party authentication service. This third party authentication service is configured in kubernetes using the webhook token authenticator. This authenticator will insert the Authorization header with the Bearer token.

- All services must be annotated to allow ambassador to route to these services. Ambassador will be configured to take a JWT token provided in an Authorization header, decode it and set it in a new header that will be carried forward.
https://github.com/kminehart/ambassador-auth-jwt

- Downstream services which normally enforce their own authentication should use the gateway authentication. These services will not do their own authentication challenge to the user.

- kubernetes should be with 1.10 version with pods policies enabled, RBAC and API server adjusted for openid authentication

![architecture](architecture.jpg)

* All calls to K8 are authenticated via auth service which connects with dex and external IDP
* K8 API are authorized with RBAC and rolebindings – project member role or roles
* Access to services hosted on K8 done via a gateway implemented with ambassador component which would use to authentication and authorization auth service. Authorization would be done based on permissions in K8 API.

The following roles would be proposed:
K8 admin
- creates PVs
- creates namespace
- creates POD policies
- creates roles and rolesbindings in the namespace
- creates PVC for new namespace

Project member:
- has role bindings in a given namespace
- has Pod policy assigned
- can create pods in assigned namespace
- can connect and execute commands in pods in assigned namespace
- cannot change volume claim
- can connect via gateway to services in assigned namespaces
- can add rolebindings in assigned namespaces (add users)

## Alternatives Considered
