# Repository Setup

## Adding your tests to Prow

For triggering and running tests from github, the Kubeflow org uses Prow, K8s' continuous integration tool.

Instructions for [setting up Prow](https://github.com/kubeflow/testing#adding-an-e2e-test-for-a-new-repository) and for [adding basic e2e tests](https://github.com/kubeflow/testing#adding-an-e2e-test-for-a-new-repository) can be found in the `kubeflow/testing` repo.

## Repository configuration

### Repository Permissions
When setting up permissions for a repository there a few things to note:
- When providing permissions for `Collaborators and teams`, only teams should be used.
- Teams that should be added by default, with write access, are `ci-bots` and `core-approvers`. Additional teams can be added as necessary.

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
