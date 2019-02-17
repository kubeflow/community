A fork of https://github.com/cncf/devstats-example

* This directory contains the config files for Kubeflow
* It is based on https://github.com/cncf/devstats-example and then modified
	* There are probably still references that need to be udpated
* Key files

  * **projects.yaml** - Defines the project
  * **grafana/dashboards** - Dashboards and grafana config

## Here's how we created this

1. We follow [Setup other project](https://github.com/cncf/devstats-example/blob/master/SETUP_OTHER_PROJECT.md)

1. We copied it to this directory

1. Copy over dashaboards

   * I used the `knative` dashboards in cncf/devstats at commit 3c419a61ad130c80c7f1b7a5058eb0fd792b4201 (current devstats master)
     rather than the homebrew ones in devstats-example

     * The latter seemed outdated see https://github.com/cncf/devstats-example/issues/7
     * I picked knative because I think it was added fairly recently and probably isn't doing special things like kubernetes

   * Run the following script to update the dashboards

     ```
     ${GIT_KUBEFLOW_COMMUNITY}/devstats/modify_dashboards.sh ${GIT_DEVSTATS_EXAMPLE_FORK}/grafana/dashboards/kubeflow
     ```

1. Run `the following script to add the -E command to sudo commands
   
   ```
   ./scripts/modify_devstats_scripts.sh ./config/devel/
   ```
1. Copy over metrics from cncf/devstats

   * We don't use cncf/devstats-examples because it has fewer metrics

   * Copy `cncf/devstats/metrics/shared` to `metrics/shared`
   * Copy `cncf/devstats/metrics/knative` to `metrics/kubeflow`

   	 * Modify metrics/kubeflow to replace references to `knative` with `kubeflow`

1. Copy scripts/homebrew to scripts/kubeflow

   * Update repo_groups.sql

1. Copy the K8s dashboards https://github.com/cncf/devstats/tree/master/grafana/dashboards/kubernetes
   to `ks-app/components/grafana/dashboards/`

1. Run ` modify_dashboards.sh` to update all references to knative to kubeflow

1. Modified projects.yaml to define a Kubeflow project