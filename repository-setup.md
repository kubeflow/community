# Repository Setup

## Adding your tests to Prow

For triggering and running tests from github, the Kubeflow org uses Prow, K8s' continuous integration tool.

Follow this [pull request](https://github.com/kubernetes/test-infra/pull/7313/files) as a guide for setting up Prow.  Your pull request should:
- Add your repository to the list of repos queried by Tide.
- Add your respository as a presubmit and postsubmit
- Add your pre and post submits to the test-grid

Additionally make sure that the `k8s-ci-robot` is given write access to the repo and that an `OWNERS` file is added to the repository.  The `OWNERS` file, like [this one](https://github.com/kubeflow/kubeflow/blob/master/OWNERS), will specify who can review and approve on this repo.

## Setting up basic tests

Basic tests for Prow are determined by the container you choose to use. For most cases, the container that should be used when configuring Prow is found [here](https://github.com/kubeflow/testing/blob/master/images/Dockerfile) in the `kubeflow/testing` repo.

This container will run workflows based on a `prow_config.yaml`.  An example can be seen [here](https://github.com/kubeflow/kubeflow/blob/master/prow_config.yaml). Each workflow submits a ksonnet definition to the cluster, often in the form of an [Argo](https://github.com/argoproj/argo/blob/master/examples/README.md) workflow.

An example of a basic argo workflow, created using ksonnet, can be found in this [pull request](https://github.com/kubeflow/pytorch-operator/pull/13/files). This workflow simply checks out your repository and provides prow with the artifacts needed to provide logs and determine the result of the test. Adding additional steps to the argo workflow will allow you to run tests using the checked out code.

## Github configurations

Finally to set up your repository, there are some configurations that should be made in GitHub.

First, it's probably a good idea to protect your `master` branch to avoid accidently deleting or overwriting the code. Instructions on protection a branch can be found [here](https://help.github.com/articles/configuring-protected-branches/). Be sure not to enable `Require pull request reviews before merging`. This setting conflicts with Tide as seen in this [issue](https://github.com/kubeflow/tf-operator/issues/433).

