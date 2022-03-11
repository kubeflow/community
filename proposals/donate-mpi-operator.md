# Donate MPI-Operator.v2 repo to kubernetes-sigs
 Donate the kubeflow/mpi-operator to a more generic/neutral place (e.g. K8s-sigs) where this project could be beneficial to more people, not limiting to ML-specific workloads. Especially given that now kubeflow/training-operator gets heavier, people should be given the option to only install MPI Operator for their use cases.

 During kubernetes SIG-APPS (Mar-7 2022) [call]((https://github.com/kubernetes/community/tree/master/sig-apps#meetings)) the topic was proposed to the SIG chairs, and they agreed to sponsor the repo.

- [Motivation](#motivation)
- [Goals](#goals)
- [Non-Goals](#non-goals)
- [Process](#process)
- [Alternatives Considered](#alternatives-considered)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

_Status_

* 2022-03-11 - Proposed 

## Motivation
Kubeflow currently is moving to an [Unified operator](https://github.com/kubeflow/training-operator)
The motivation is to encourage non-training users (like HPC) to use and contribute to it, without having to install or learn about kubeflow's training-operator.
With the creation of the project [k8s-sigs/Kueue](https://github.com/kubernetes-sigs/kueue), having the MPi-Operator as a k8s-sigs project will facilitate the efforts to create and maintain a custom job queueing mechasinm for mpi jobs on kubernetes.

## Goals
* Migrate repo kubeflow/mpi-operatorv2 to kubernetes-sigs/mpi-operator
* The training operator could declare the kubernetes-sigs/mpi-operator as a dependency, leveraging new features like job queueing 

## Non-Goals
* Migrate kubeflow/mpi-operator.v1

## Process

* Donate kubeflow/mpi-operator to kuberenetes-sigs as detailed [here](https://github.com/kubernetes/community/blob/master/github-management/kubernetes-repositories.md#rules-for-donated-repositories), being tracked [here](https://github.com/kubeflow/mpi-operator/issues/459)
* Close https://github.com/kubeflow/training-operator/issues/1479
* Close https://github.com/kubeflow/mpi-operator/issues/422
* Re-org the repo to remove dependency from kubeflow/common
* Cut a first release under k8s-sigs

## Alternatives Considered
Continue to maintain the MPI-Operator as a stand alone project unregarless of the development of the universal operator, for non AI/ML use cases.
