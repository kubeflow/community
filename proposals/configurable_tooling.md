

## Motivation
Kubeflow enables a DL environment for data scientists deployed in a number of phases using ksonnet. Each phase involves parameterizing and deploying different ksonnet packages. This can be shown in the following table:

| phase     | ksonnet packages     | commands | privileges |
| :------------- | :------------- | :---- | :----- |
| setup       | iap,<br/>cert-manager|  ks, kubectl, gcloud | cluster-admin |
| deployment       | ambassador,<br/>centraldashboard,<br/>nfs,<br/>spartascus |  ks, kubectl, gcloud | cluster-admin |
| notebook | jupyterhub | ks | data scientist |
| serving | tf-serving | ks | data scientist |
| training | tf-job | ks | data scientist |

From the table it's clear that some of the phases should be handled by someone with elevated privileges in the cluster and other phases are intended to be run by data scientists. It's somewhat less clear that a data scientist may have particular ways of configuring training, notebooks or serving that may not be easily satisfied by existing ksonnet libraries. Exposing all of the above to the data scientist muddles the possibility of a clean and concise CLI by exposing:
  1. Lengthy setup instructions to create a DL project
  1. Configurations and other setup requiring devops support
  1. Exposure of the underlying cloud platform
  1. An ad-hoc set of commands that do not compose well, may overlap or provide redundant or non-standard arguments.
  1. Supporting commands that need to be installed on a data scientist's client machine (often with upgrade constraints).
  1. Lack of command completion or command completion (ks) that does not integrate well with other commands or within a pipeline of commands.
  1. Lack of an ability to integrate a data scientist customizations or integrate new CLI subcommands required by new kubeflow components.  

## Goals
- Provide a data scientist's CLI that:
  1. Allows the data scientist to easily create a project or switch between projects.
  1. Is able to discover available services such as dashboards, jobs, job histories, notebooks.
  1. Is easily installed on the client machine.
  1. Provides common kubeflow operations as customizable subcommands (train, serve, notebook)
  1. Allows a data scientist or contributor to add or override subcommands using python
  1. Allows subcommands to be added to only those granted particular privileges
  1. Enables a subcommand registry   

## Non-Goals
The CLI subcommands suggested do not proscribe against defining additional subcommands in other proposals.

## UI or API
1. A CLI with an initial base set of subcommands:    
   1. General    
      1. `kf create [-h] [-d] [-r repo] [-b branch] [-i] <namespace>`
      1. `kf delete [-h] <namespace>`
      1. `kf logs [-h] [-f] <component> [<container>]`
      1. `kf remove [-h] <component>`
      1. `kf run [-h] <component> [container] -- [command]`
      1. `kf shell [-h] <component> [<container>]`
      1. `kf status [-h] <component>`
      1. `kf use [-h] <namespace>`
      1. `kf whoami [-h]`
   1. Specific to Kubeflow components but not addressed per se within this proposal    
      1. `kf notebook [-h] [ls|start|stop] <name>`
      1. `kf serve [-h] <name> <yaml>`
      1. `kf train [-h] <name> <yaml>`

1. The CLI is extensible via a subcommand called `command`    
  1. `kf command [-h] [add|remove|replace|upgrade|list|describe] <subcommand>`
1. Subcommands may be executed locally or call a Kubeless Function (written in python|bash|golang) which:    
   1. Runs in a container that includes requisite tooling and dependencies ks, kubeclt, kubeless, python2.7|python3.6

## Design
A data scientist's CLI is a flexible set of commands that are executed against a cluster of DL components. Within kubeflow, this set of components will vary and will likely be configurable using `ks` environments that are parameterized. A static CLI can not accommodate a configurable set of runtime components found in kubeflow, of which many may be provided by open source contributors. The kubeflow flexible component design mandates a matching CLI design where subcommands can be provided by component authors or contributors that, for example, bundle one or more subcommands for a component. For example adding the pytorch component could include a pytorch CLI perhaps parameterized by where the user is running it (minikube, gce, azure, ...). The CLI for a component may be provided independently of the component ksonnet package. Subcommands will require specific runtime contexts and are implemented as serverless Functions. This design enables a CLI ecosystem where specific functionalities not possible within a fixed CLI deliverable are possible.  

### Implementation
1. Create a base container that includes needed tools `ks, kubectl, python2.7, python3.6`
1. Add a new library kubeflow/core/kubeless.libsonnet to kubeflow/core that is included in kubeflow/core/all.libsonnet
1. Define a set of kubeless Functions that match the `kf` subcommands EG:
```yaml
apiVersion: kubeless.io/v1beta1
kind: Function
metadata:
  name: create
spec:
  handler: subcommand.create
  runtime: python3.6
  function: |
    import subprocess
    result = subprocess.run(['ks', 'init', ...], stdout=subprocess.PIPE)
    result.stdout
```
   1. Kubeless Functions should use the kubernetes python API for kubectl operations and the `ks` executable for ksonnet operations or possibly the new ksonnet-lib. The preference would be to utilize an ksonnet API.
   1. Insure Kubeless Functions are installed in containers to optimize execution times (see kubeless documentation)
1. Each kubeless Function will require a client subcommand plugin that can be dynamically loaded using golang plugin as a module. This plugin would be installed as part of `ks command add ...`. It should also be autogenerated as much as possible.
1. Create a golang client that is generated from spf13/cobra
  1. Generating the golang `kf` client stubs
    >`#!/bin/bash`<br/>
`KF=github.com/kubeflow/kf/kf`<br/>
`rm -rf $GOPATH/src/$KF`<br/>
`mkdir $GOPATH/src/$KF`<br/>
`cobra init $KF`<br/>
`cd $GOPATH/src/$KF`<br/>
`cobra add create`<br/>
`cobra add delete`<br/>
`cobra add exec`<br/>
`cobra add logs`<br/>
`cobra add remove`<br/>
`cobra add services`<br/>
`cobra add list -p 'servicesCmd'`<br/>
`cobra add health -p 'servicesCmd'`<br/>
`cobra add stats -p 'servicesCmd'`<br/>
`cobra add shell`<br/>
`cobra add use`<br/>
`cobra add whoami`<br/>
`cobra add user`<br/>
`cobra add add -p 'userCmd' `<br/>
`cobra add rm -p 'userCmd' `<br/>
`cobra add ls -p 'userCmd'`<br/>
`cobra add command`<br/>
`cd -`<br/>
`mv $GOPATH/src/$KF/* .`<br/>
`rmdir $GOPATH/src/$KF`<br/>


## Alternatives Considered
1. A static set of subcommands that prescribes all available actions a data scientist would do.
1. Using a different client framework other than spf13/cobra. Given that kubectl, kubeless and ks also use this framework there is an opportunity to leverage their subcommands.
