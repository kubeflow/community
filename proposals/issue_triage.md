# Kubeflow Issue Triage

## TL;DR

The purpose of this doc is to define a process for triaging Kubeflow issues.

## Objectives

* Establish well accepted criterion for determining whether issues have been triaged
* Establish a process for ensuring issues are triaged in a timely fashion
* Define metrics for measuring whether we are keeping up with issues

## Triage Conditions

The following are necessary and sufficient conditions for an issue to be considered triaged.

* The issue must have a label indicating which one of the following kinds of issues it is
  
  * **bug**
    * Something is not working as intended in general.
  * **question**
    * Clear question statement
    * Something is not working as intended in author's specific use case and he/she doesn't know why.
  * **enhancement**
    * Everything is working as intended, but could be better (i.e more user friendly)
  * **process**
    * Typically used to leave a paper trail for updating Kubeflow infrastructure. It helps to track the changes to infrastructure for easy debugging in the future.

* The issue must have at least one [area label](https://github.com/kubeflow/community/blob/master/labels-owners.yaml) grouping related issues and relevant owners.

* The issue must have a priority attached to it. Here is a guideline for priority

  * **P0** - Urgent - Work must begin immediately to fix with a patch release:
    * Bugs that state that something is really broken and not working as intended.
    * Features/improvements that are blocking the next release.
  * **P1** - Rush - Work must be scheduled to assure issue will be fixed in the next release.
  * **P2** - Low - Never blocks a release, assigned to a relevant project backlog if applicable.
  * **P3** - Very Low - Non-critical or cosmetic issues that could and probably should eventually be fixed but have no specific schedule, assigned to a relavant project backlog if applicable.

* **P0** & **P1** issues must be attached to a Kanban board corresponding to the release it is targeting

## Process

* The [Needs Triage](https://github.com/orgs/kubeflow/projects/26) Kanban board will be used to track issues that need triage

  * Cards will be setup to monitor various issues; e.g. issues requiring discussion by various WG's

* The [triage notebook](https://github.com/kubeflow/code-intelligence/blob/master/py/code_intelligence/triage.ipynb) can be used to generate reports about number of untriaged issues

* The [triage notebook](https://github.com/kubeflow/code-intelligence/blob/master/py/code_intelligence/triage.ipynb) can be used to identify issues needing triage and add them to the Kanban board

* Automated tooling will be used to automatically add issues to the Kanban board if they don't meet the above criterion and remove them once the criterion have
  been satisfied and the issues can be considered triaged

* A weekly rotation will be established to designate a primary person to apply initial triage

  * The oncall will attempt to satisfy the above criterion or reassign to an appropriate WG if there is some question

## Become a contributor

* Make sure that you have enough permissions to assign labels to an issue and add it to a project.
* In order to get permissions, open a PR to add yourself to [project-maintainers](https://github.com/kubeflow/internal-acls/blob/4e44f623ea4df32132b2e8a973ed0f0dce4f4139/github-orgs/kubeflow/org.yaml#L389) group.

## Triage guideline

* Take an issue from "Needs Triage" project and open it in a new tab.
* Carefully read the description.
* Carefully read all comments below. (Some issues might be already resolved).
* Make sure that issue is still relevant. (Some issues might be open for months and still be relevant to current Kubeflow release whereas some might be outdated and can be closed).
* Ping one of the issue repliers if he/she is not replying for a while.
* Make sure that all triage conditions are satisfied.

## Metrics

We would like to begin to collect and track the following metrics

* Time to triage issues
* Issue volume

## References

* [kubeflow/community](https://github.com/kubeflow/community/issues/280)
