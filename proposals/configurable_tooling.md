

## Motivation
- A data scientists CLI is often characterized by:   
  1. Lengthy setup instructions to create a DL project
  1. Configurations requiring devops support
  1. Exposure of the underlying cloud platform
  1. Iterative development that can be many times slower that developing locally
  1. An ad-hoc set of commands that do not compose well, may overlap or provide redundant or non-standard arguments.
  1. Supporting commands that need to be installed on a data scientist's client machine (often with upgrade constraints).
  1. Lack of command completion or command completion that does not integrate well.    

## Goals
- Define a CLI that:
  1. Allows the data scientist to easily create a project or switch between projects.
  1. Is able to discover available services such as dashboards, jobs, job histories, notebooks.
  1. Is easily installed on the client machine.
  1. Allows new subcommands to be added
  1. Allows existing subcommands to be updated or overridden.

## Non-Goals
The CLI subcommands suggested do not proscribe against adding additional subcommands in other proposals.

## UI or API
1. A CLI with an initial base set of subcommands:    
   1. kf create   [-h] [-d] [-r repo] [-b branch] [-i] namespace
   1. kf delete [-h] namespace
   1. kf logs [-h] [-f] [component] [container]
   1. kf ls [-h] [list|health|stats]
   1. kf remove [-h] [component]
   1. kf run [-h] [component] [container] -- [command]
   1. kf shell [-h] [component] [container]
   1. kf status [-h] [component]
   1. kf whoami [-h]
1. The CLI allows extensibility using a subcommand `command`
  1. kf command [-h] [add|remove|replace|upgrade] subcommand
1. Subcommands (create, delete, ls, ...) call a Kubeless Function (written in python) which:    
   1. Runs in a container that includes ks, kubeclt, kubeless, python2.7|python3.6
   1. parses options and sets params

## Design
1. Create containers that include the needed runtimes `ks, kubectl, python2.7, python3.6`
1. Add a new library kubeflow/core/kubeless.libsonnet to kubeflow/core that is included in kubeflow/core/all.libsonnet
1. Define a set of kubeless Functions that match the `kf` subcommands
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
    result = subprocess.run(['kf', 'create', ...], stdout=subprocess.PIPE)
    result.stdout
```
1. Create a golang client similar to the kubeless client




## Alternatives Considered
A static set of subcommands that prescribes all available actions a data scientist would do
