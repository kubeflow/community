# Repository Setup

Here are the steps involved in setting up a new repository; there is more information in the sections below.

1. Create an OWNERS file at the root of the repository

	* For more info on OWNERS files see [CONTRIBUTING.md](https://github.com/kubeflow/community/blob/master/CONTRIBUTING.md)

1. Configure the repository in GitHub following the instructions [below](#repository-configuration)

1. Setup prow for the repository by following the instructions [below](#setup-prow)


## Setting up prow for your repository

We use [Prow](https://github.com/kubernetes/test-infra)

	* Continuous integration
	* Automatic merging of PRs (tide)
	* Manage PRs using bots


1. Configure prow for the repository by following these [instructions](https://github.com/kubeflow/testing#setting-up-a-kubeflow-repository-to-use-prow-)

  * Create a prow_config.yaml file with the following contents

  ```
  workflows: []
  ```

  * This file is sufficient to ensure the prow jobs pass but doesn't run any actual tests.

  * When you are ready to actually add E2E tests you can follow [adding basic e2e tests](https://github.com/kubeflow/testing#adding-an-e2e-test-for-a-new-repository) to add a basic E2E test
   for your repository 

  * See kubeflow/testing#11 for work creating generating tests for things like lint.

1. Allow tide to automatically merge PRs by submitting a PR like [kubernetes/test-infra#7802](https://github.com/kubernetes/test-infra/pull/7802/files) to kubernetes/test-infra/prow/config.yaml to enable).

## Repository configuration

### Repository Permissions
When setting up permissions for a repository there a few things to note:
- When providing permissions for `Collaborators and teams`, only teams should be used.
- Teams that should be added by default, with write access, are `ci-bots` and `core-approvers`. 

	* Additional teams can be added as necessary but
	* Most operations should be done via the ci-bots and adding folks to the owners files
	* So the number of folks with direct access to a repository should be small (<5)

### Third Party Apps
Make sure to enable the third-party apps used by the Kubeflow community.

These apps include:
- Reviewable
    - For Reviewable, sign in with Github and in the `Repositories` tab, make sure to allow visibility to your other orgs. After the allowing `Kubeflow` you should be able to enable your repo.
    - Click on the enabled repo in Reviewable and make sure to disable `Review status in GitHub PR` because this causes problems for prow https://github.com/kubernetes/test-infra/issues/7140
- TravisCI
    - For TravisCI, any administrator of the repo should be able to enable tests. Just follow the TravisCI [Getting Started Guide](https://docs.travis-ci.com/user/getting-started/).
- Coveralls
    - For instructions on enabling coveralls and integrating with travis, you can follow [these](https://docs.travis-ci.com/user/coveralls/) instructions. If you aren't an org admin, you may need to request assistance in enabling coveralls.

### Branch Protections
When setting up the repo, the `master` branch should be protected. Instructions on protection a branch can be found [here](https://help.github.com/articles/configuring-protected-branches/).

A few things to note when setting up branch protection:
- Enable `Protect this branch` to protect the code in the `master` branch.
- Be sure not to enable `Require pull request reviews before merging`. This setting conflicts with Tide as seen in this [issue](https://github.com/kubeflow/tf-operator/issues/433).
- Don't enable `Require branches to be up to date before merging`
- Enable `Require status checks to pass before merging`

