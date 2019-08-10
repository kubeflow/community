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
  
  * bug
  * question
  * enhancement
  * process

* The issue must have at least one area label indicating the WG/SIG that should own it

* The issue must have a priority attached to it. Here is a guideline for priority

   * P0 - Urgent - Work must begin immediately to fix with a patch release.
   * P1 - Rush - Work must be scheduled to assure issue will be fixed in the next release.
   * P2 - High - Never blocks a release, but should be scheduled for a specific expected release in the future rather than left unscheduled. 
   * P3 - Medium - Non-critical or cosmetic issues that could and probably should eventually be fixed but have no specific schedule and so are not necessarily assigned to a given release.

* P0 & P1 issues must be attached to a Kanban board corresponding to the release it is targeting

## Process

* The [Needs Triage](https://github.com/orgs/kubeflow/projects/26) Kanban board will be used to track issues that need triage

  * Cards will be setup to monitor various issues; e.g. issues requiring discussion by various WG's

* The [triage notebook](https://github.com/kubeflow/code-intelligence/blob/master/py/code_intelligence/triage.ipynb) can be used to generate reports about number of untriaged issues

 * The [triage notebook](https://github.com/kubeflow/code-intelligence/blob/master/py/code_intelligence/triage.ipynb) can be used to identify issues needing triage and add them to the Kanban board

* Automated tooling will be used to automatically add issues to the Kanban board if they don't meet the above criterion and remove them once the criterion have
  been satisfied and the issues can be considered triaged

* A weekly rotation will be established to designate a primary person to apply initial triage

  * The oncall will attempt to satisfy the above criterion or reassign to an appropriate WG if there is some question

## Metrics

We would like to begin to collect and track the following metrics

* Time to triage issues
* Issue volume

## References

* [kubeflow/community](https://github.com/kubeflow/community/issues/280)