## Purpose

The purpose of this document is to describe the expected workflow for receiving
and adopting new proposals for the Kubeflow community.

## Goals

The Kubeflow community's primary goals for a proposal workflow are:

* Provide enough structure to maintain a repeatable workflow from submission to resolution
* Be lightweight enough for community members to learn easily, and ensure that this new community remains agile
* Leave a durable record of proposals, community feedback, and final decision on acceptance
* Inform the community roadmap

## Proposal Scope

Proposals are expected for any significant modifications to the Kubeflow
project, for example:

* Adding a new subproject, application, dependency or component
* Any large-scale refactoring of existing subprojects or applications
* Substantial changes to a public API, UX or UI

## Proposal Document Structure

A proposal is a Markdown (`*.md`) file and will be expected to have the following
[structure](proposals/proposal-template.md):

* **Motivation:** high level description of the problem or opportunity being addressed
* **Goals:** specific new functionalities or other changes
* **Non-Goals:** issues or changes not being addressed by this proposal
* **UI or API:** New interfaces or changes to existing interfaces. Backward compatibility must be considered
* **Design:** Description of new software design and any major changes to existing software. Should include figures or diagrams where appropriate
* **Alternatives Considered:** Description of possible alternative solutions and the reasons they were not chosen.

This structure is also exemplified by a [template](/proposals/TEMPLATE.md). In order to support the goal of keeping the proposal process lightweight, proposals will have a **recommended 2-page limit.**

## Proposal Workflow

The workflow for submitting and reviewing a new proposal is as follows:

1. A Markdown file (`*.md`) will be drafted for the proposal.
1. A pull request (PR) will be filed against [this repository](https://github.com/kubeflow/community) (`kubeflow/community`), which adds this Markdown file to the `proposals` directory.
1. The proposal will be announced on the [kubeflow-discuss](https://groups.google.com/forum/#!forum/kubeflow-discuss) group, and at one of the weekly meetings, so that community members will be aware of it.
1. There will be a **two week** period for comment and review.  Review and feedback take place on the PR, in standard PR review fashion.
1. At the end of the review period, a vote will be held. This vote will also take place on the PR. If a proposal receives 3 binding `+1` votes from Kubeflow project Approvers, and no binding `-1` votes, the proposal will be accepted, and added to the community repo. The PR will be merged, and the label `accepted-proposal` will be added to the PR.
1. If a proposal is voted down, the PR will be left unmerged, and the label `tabled-proposal` will be added to the PR.
