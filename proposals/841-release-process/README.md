# KEP-841: Proposal to update the Release Process for Kubeflow

<!--
This is the title of your KEP. Keep it short, simple, and descriptive. A good
title can help communicate what the KEP is and should be considered as part of
any review.
-->

## Summary

This proposal aims to share insights on topics discussed with the release team and others about diverse challenges and improvement opportunities in the release process based on Kubeflow release 1.10.

## Motivation

Current challenges based on Kubeflow release 1.10:
* Challenge to get component’s release progress during release meetings.
    ** Blockers or challenges on the Release are identified later.
    ** Incomplete/Inaccurate or null information on some components about progress/blockers.
* The Release Manager role challenges:
** Only one person is responsible for the Release and decisions.
** Time dedication and commitment are high and for an extended period (6 months), which makes it hard to find candidates for Release.
** The diverse skills required for the role make it even harder for candidates to join.
* Release Documentation
** Working groups need help on building Technical Documentation for Releases.
** Working on technical documentation during the Release, before the feature freeze, can expedite the release process.
* Feature Freeze vs Building Release Candidate
** Teams required more time to finish the Release and later cherry-pick and work on building the Release.
* Release timeframe 
** The Release is now 27 weeks. There are 10 weeks between feature freeze and Release. 
** Release dates and phases are hard to predict in the current process.

### Goals

* Reduce time to market of Kubeflow Release
* Reduce meeting time and structure to give back time to the Release Team.
* Focus on contributions from technical documents and source code by reducing meetings and promoting async communication.
* Promote clarity on dates and phases so distributions, working groups, and the whole community can plan accordingly.
* Improve release cycle by moving technical decisions affecting the release to the Release Management team including Kubeflow platform

### Non-Goals

<!--
What is out of scope for this KEP? Listing non-goals helps to focus discussion
and make progress.
-->

## Proposal

### Release Timelines
KubeFlow Release x.x is moved to Quarterly Release = 12 weeks

![alt text](release.png)

* Notes: Release dates will not be changed unless critical changes are needed.
Week 9 is code freeze. However, the working groups can use that week to finish any outstanding feature critical for the release.

* KubeFlow Release minor versions x.x.xx
** Release can be 60-90 days.

### Release Meetings and Communication
* Create a new Release Management team on Slack for asynchronous communication within the team
* Bi-weekly meetings during Software Development (Week 1-Week 8). Weekly meetings between week 9-12 as needed.

### Release Documentation

* Build a team of technical writers to be embedded in each working group for the release time frame. 
* Provide roles within the community to boost participation and bring new members into this group.

### Release Management Team 
* Release management is the responsibility of a team: 
    * Potentially: Working Group Leads + TOC + KSC + Release Manager
    * The manifest Project is the Kubeflow Release Project, and the Release Team is responsible for this project.
* Feature Freeze vs Building Release Candidate
* Add one more week for building release candidates.
* The Release Manager is still responsible for the overall release of Kubeflow and communication between the teams.
* Release team liaisons will be responsible not for the communication but for contributing to the release with documentation, source code, PRs review, etc, according to their skills and motivation.

### Workflow (TBD)

### Notes/Constraints/Caveats (Optional)

<!--
What are the caveats to the proposal?
What are some important details that didn't come across above?
Go in to as much detail as necessary here.
This might be a good place to talk about core concepts and how they relate.
-->

