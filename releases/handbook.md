# Kubeflow Release Handbook

## Executive Summary

The purpose of this document is to define the roles and processes for the Kubeflow community to release Kubeflow. This document will attempt to coordinate releasing between the five major components and working groups in Kubeflow, as well as defining best practices, roles, and processes to make releasing Kubeflow easier for the community with each iteration.

## People and Roles

### Release Manager
The Release Manager will be responsible for coordinating the release and taking ultimate accountability for all release tasks to be completed on time.

The previous Release Manager is responsible for choosing their successor that meets the prerequisite. If multiple Release Team members meet the prerequisites to become a Release Manager, the one from a different organization than the one that drove the previous release should be preferred.

**Prerequisites:**
1. Have contributed as a release team member in two or more previous releases

**Time Commitments:** This role will need to be synchronous. The Release Manager is expected to join most of the weekly meetings and coordinate with the Release Team and the Working Group leads. For the Development phase, an estimate of the work needed is 4-8 hours per week. For the next phases, the Release Manager is required to devote more time and coordinate the tasks of the release.

**Responsibilities:**
* Provide updates to the mailing list with the progress of the release
* Coordinate directly with the WG liaisons and leads about dates and deliverables
* Coordinate with the Release Team Members for the progress of the release
* Ensure the WG leads have cut the necessary GitHub branches and tags for the different phases of the release
* Host the weekly Release Team meetings
* Update the larger community on release status during the Kubeflow community meetings
* Make sure the processes are being followed
* All the responsibilities of a Release Team Member

**Authority:**
The Release Manager will need to have authority to take some decisions, in
order to ensure the stability of the release and completion in a timely manner.
Such decisions include:
* Moving the release process to the next phase, even if there are controversial issues at hand
* Delaying the release until some important issues are resolved
* Denying component version upgrades

### Release Team Member (Working Group Liaison)
Release team members are assigned to one or more WG to act as a liaison between the release team and the WGs. The release team member will be the main contact point for the release team to figure out the progress of the WG as well as required component versions throughout the release. If a release team member is already part of a WG then they could also serve as the liasion. In addition, release team members work closely with the Release Manager to address release issues.

**Prerequisites:** none

**Time Commitments:** Their role will need to be synchronous, since they are expected to join the Release meetings and other WG meetings. Their time commitment is expected to be spread out throughout the release.

**Responsibilities:**

* Keep track of the provided component versions and updating the [versions table](https://github.com/kubeflow/manifests#kubeflow-components-versions)
* Create PRs to update manifests repo from WG provided git revisions
* Attend the Release Team meetings
* Attend the WG meetings
* Provide feedback on enhancing the current Release Handbook
* Keep notes from the Release Team meetings, in a rotation manner between the members

### Product Manager
They will be in charge of driving non-code deliverables, like the release blog post, release video, user surveys, and social media announcements.

**Prerequisites:** Experience in writing blog posts. Contributions to an existing Open Source project is a huge plus.

**Time Commitments:** This role will require some synchronous communication, since they will need to attend some of the later Release Team meetings. Most of the effort is expected to start once the Feature Freeze phase completes, where they will start working on the blog and release announcements.

**Responsibilities:**

* Drive the release blog post effort
* Drive the release presentation effort
* Handle communication for social media content publication
* Orchestrate and create user surveys
* Track important features and bug fixes that should be highlighted in the release

### Docs Lead

The Docs Lead is responsible for working with the Release Team to coordinate documentation updates for the next Kubeflow release.

If no members can serve as docs lead, the release manager must take on the role.

**Prerequisites:** Contributions to the [website repo](https://github.com/kubeflow/website)

**Time Commitments:** This role will require some synchronous communication. The bulk of their work is expected to be in the Documentation phase of the release, but they will also be involved throughout the release by keeping track of issues that might require an update to the docs.

**Responsibilities:**
* Identify and track new issues that require update to the docs
* Work with contributors to modify existing docs to accurately represent any upcoming changes
* Review documentation PRs to ensure quality following the website [Style Guide](https://www.kubeflow.org/docs/about/style-guide/)
* Migrate the old website [version] documentation and updating it with the new release

### Working Group Documentation Lead
The Working Group Documentation Lead is responsible for working with the Working Group and Release Team to coordinate a Working Group's documentation updates for the next Kubeflow release.

**Prerequisites:** Contributions to the [website repo](https://github.com/kubeflow/website), experience writing feature descriptions for software applications, Kubernetes and/or Kubeflow, and in light weight project management.   If the contributor is new to the Kubeflow Community, this would be a good first role and consideration will be made if the contributor does not have direct experience. 

**Time Commitments:** This role will require some synchronous communication. The bulk of their work is expected to be in the Documentation phase of the release, but they will also be involved throughout the release by keeping track of issues that might require an update to the docs.

**Responsibilities:**
* Identifying and tracking new issues for a Working Group that require update to the docs
* Working with contributors and Release Team Documentation lead to modify existing docs to accurately represent any upcoming changes
* Reviewing documentation PRs to ensure quality following the website [Style Guide](https://www.kubeflow.org/docs/about/style-guide/)
* Migrating the old website [version] documentation and updating it with the new release

### Working Group Test Lead
The Working Group Test Lead is responsible for working with the Working Group and Release Team to coordinate a Working Group's test infrastructure and test plan for the next Kubeflow release.  They will also help to execute and report the results of the test plan.

**Prerequisites:** Contributions to the [website repo](https://github.com/kubeflow/website), with experience running Kubernetes and/or Kubeflow clusters, writing test plans, and providing light weight project management

**Time Commitments:** This role will require some synchronous communication. The bulk of their work is expected to be in the testing phase of the release, but they will also be involved throughout the release by keeping track of issues that might require iterative testing.

**Responsibilities:**
* Identifying and tracking new issues for a Working Group that require testing
* Working with contributors and Release Team to create and/or modify the Working Group's test plan to accurately represent any upcoming changes
* Help to configure, monitoring and operate the Working Group's test infrastructure i.e. GitHub Actions and/or AWS Test Infrastructure
* Help to complete test cases per the test plan
* Provide test plan results to the Release Team 

### Distribution Representative

**Prerequisites:** Work at the organization that owns the distribution

**Time Commitments:** This role can be completely asynchronous. Most of their work is expected to be in the Distribution testing phase. Ideally they should be involved when the first RC is cut in order to alert early for potential issues.

**Responsibilities:**
- Expose issues that the distribution owner is facing with the new release
- Sync with the release team during distro testing phase, we want a nice tight feedback loop there

## Proposed WG Processes

### Releasing

We are moving to a release cadence of **4 months**, in response to our 3 month cycle being tight for the typical set of features we have wanted to release.The release is planned out with 10 weeks of development, with 6 weeks of feature freeze, documentation work, and other processes. At some point there will be a feature freeze, as described below, in the manifests repo. This means that other WGs cannot request the Manifest WG leads to update the repo to change a component’s YAML files, if the update sets a new image with new features.

The above means that WGs, which will be maintaining a list of repos, will only be providing git revisions that only include bug fixes and not features, to the Manifests WG leads.

We recommend adopting a release branch to cope with this form of releasing; we suggest that all WGs follow the process below for releasing new versions of their software:

1. Create a new branch for your new version
2. Use tags for the release that will be pointing to commits in the created branch

This way a WG can keep on pushing new features to their **master** branch. Once there’s a feature freeze, in manifests repo, they can cherry-pick bug fixes to their new branch and request from the Manifests WG leads to sync the manifests from commits in that branch. This ensures that the newer commits will only include bug fixes.

### Documentation

Working groups should briefly describe what changes to existing [kubeflow.org](https://www.kubeflow.org/) documentation will be required to ensure the docs reflect new features or other software updates. A few bullets identifying which pages in the docs need to change will suffice. These bullets should be added to the Working Group’s GitHub issues describing planned engineering work.

Working Groups should be tracking features for the release, as well as the documentation status of each feature as it’s being developed so that the documentation team can keep track of the documentation work that needs to be done.

## Versioning Policy

Kubeflow version format follows [semantic versioning](https://semver.org/) terminology expressed as vX.Y.Z format,
 where X is the major version, Y is the minor version, and Z is the patch version.

Throughout the release cycle, pre-release artifacts are available at different stages. These artifacts are versioned
 with `rc` and a number incrementing from 0 to indicate that it is a pre-release. For example, `vX.Y.Z-rc.0`.

At the start of the release cycle, the release manager works with the community to propose the next version and the release timeline.

## Terminology

### git revision

A git revision is either a git commit, branch, or tag. Ideally people should be providing the manifests repo with tags, to update the manifests from.

### Release Candidate (RC)

The Release Candidate (RC) in the manifests repo is always a git **tag**.

The manifests repo will be following the release process below:

1. There will be a **vX.Y-branch** branch, in which the Manifests WG leads will be cherry picking commits on top
2. Manifests leads will be creating new tags for different RCs, that will be pointing to commits of that release branch


## Timeline

| Week | Events |
| ---- | ------ |
| 1 | Development |
| 2 |   |
| 3 |   |
| 4 |   |
| 5 |   |
| 6 |   |
| 7 |   |
| 8 |   |
| 9 |   |
| 10 |   |
| 11 | Feature Freeze, RC released, Documentation Update starts |
| 12 |   |
| 13 | Manifests testing week, RC released |
| 14 | Distributions testing starts |
| 15 |   |
| 16 | Distributions testing ends, Documentation Update ends |
| 17 | Release Day |


### Preparation

- [ ] [Assemble a release team](https://github.com/kubeflow/community/issues/571)
- [ ] Create a new [release project](https://github.com/orgs/kubeflow/projects) to track issues and pull requests related to the release
- [ ] Working groups broadly think about features **with priorities** they want to land for that cycle, have internal discussions, perhaps groom a backlog from previous cycle, get issues triaged, etc.
- [ ] Update the release manager and members of the Release Team in the [kubeflow/internal-acls]](https://github.com/kubeflow/internal-acls/pull/545)
- [ ] Establish a regular release team meeting as appropriate on the schedule and update the [Kubeflow release team calendar](https://calendar.google.com/calendar/embed?src=c_c5i4tlc61oq2kehbhv9h3gveuo%40group.calendar.google.com&ctz=America%2FNew_York)
- [ ] [Propose a release timeline](https://github.com/kubeflow/community/pull/558), announce the schedule to [kubeflow-discuss mailing list](https://groups.google.com/g/kubeflow-discuss), and get lazy consensus on the release schedule from the WG leads
  - Review the criteria for the timeline below
- [ ] Ensure schedule also accounts for the patch releases AFTER the minor release
- [ ] Create one [release tracking issue](https://github.com/kubeflow/manifests/issues/2194) for all WGs, distributions representatives, and the communtiy to track
- [ ] Start a discussion on [Kubeflow dependency versions](https://github.com/kubeflow/manifests/issues/2207) to support for the release

Criteria for timeline that the team needs to consider
- Holidays around the world that coincide with members of the release team, WG representatives, and distro representatives.
- Enterprise budgeting/approval lifecycle. (aka users have their own usage and purchase requirements and deadlines)
- Kubecon dates - let’s not hard block on events, but keep them in mind since we know community members might get doublebooked.
- Associated events (aka. AI Day at Kubecon, Tensorflow events) - we want to keep them in mind.

**Success Criteria:** Release team selected, release schedule sent to kubeflow-discuss, all release team members have the proper permissions and are meeting regularly.


### Development (10 weeks)

Normal development in the different WGs and in the <https://github.com/kubeflow/manifests> repo.

**Success Criteria:**
* (Optional but encouraged): Issues tracking new features should also provide information on whether the docs should be updated for that feature

### Feature Freeze (2 weeks)

From that phase and forward updates to the manifests repo must only be fixing component bugs. No new commits, in the manifests repo, that update a component to include a new feature are allowed.

**Actions for other WGs:**

- Provide a _git revision_ which the release team members or Manifests leads will use to update the files in the manifests repo
- Provide an initial list of issues that the WG would like to close until the final release
- Work on closing the provided open issues
- Ensure that future_git revisions_they provide only include bug fixes, and not new features, from the previously provided _git revision_
- Declare expected common dependency version ranges

**Actions for Manifests WG:**

- Keep track of the pending bug fixes for each WG in the release tracking issue
- Push a commit that updates the manifests for the different WGs, based on the _git revision_ they had provided.
- Create a new **vX.Y-branch** branch in the manifests repo
- Create a new **vX.Y-rc.0** tag that will be pointing to the branch created above
- Add commits on top of the **vX.Y-branch** branch to include bug fixes. The other WGs can provide a new _git revision_ to Manifests WG leads. The new git revision must only include bug fixes, not new features.
- On the last day of feature freeze, cut a new **vX.Y-rc.1** RC tag on the **vX.Y-branch** release branch.

**Actions for the Release Team:**
- Get a git revision from all WGs, on the first day of the Feature Freeze period. WGs need to have a git revision ready to give to the release team.
- Make a pull request to update the manifests for the different WGs, based on the _git revision_ they provided.
- Identify, early in the first week, bugs at risk. These should either be aggressively fixed or punted

**Success Criteria:** All working group git branches and tags are created, manifests are up to date, features either have landed or been pushed to next release.

### Manifests testing (1 week)

The Manifests WG leads will be evaluating the final structure of manifests before Distribution owners start testing

**Actions for other WGs:**
- Provide updates on the progress of pending issues and their fixes

**Actions for Manifests WG:**
- Ensure the manifests provide a deployable Kubeflow installation
- Sync with other WGs on pending issues
- After finishing testing, create a new **vX.Y-rc.2** tag on the **vX.Y-branch** release branch to ensure the latest bug fixes are included.

**Success Criteria:** Manifests complete and fixes from working groups applied.

### Documentation (3 weeks) (Starts the same time as Feature Freeze)

Alongside the feature freeze and the continuous bug fixes we can now focus on
ensuring that the docs are up to date, before distributions start testing.
Features that are at risk or being worked up until the deadline
can be documented last, ideally most of the feature work has landed already and
those can start to be documented.

**Actions for ALL WGs:** Have their documentation up to date

**Actions for the Release Team:**
- Request a list of features and deprecations, from the Working Groups, that require updates to the documentation
- Ensure the provided component versions match the documentation
- Work alongside the Working Groups to bring the docs up to date
- Create a [new version dropdown and update the website version](https://github.com/kubeflow/website/pull/3333)
- Add new [release page with component and dependency versions](https://github.com/kubeflow/website/pull/3332)

**Success Criteria:** Documentation for this release completed with minimum following pages updated and a [new version
in the website is cut](https://github.com/kubeflow/kubeflow/blob/master/docs_dev/releasing.md#version-the-website).
- [Installing Kubeflow](https://www.kubeflow.org/docs/started/installing-kubeflow/)
- [Release Page](https://www.kubeflow.org/docs/releases/)
- [Distributions](https://www.kubeflow.org/docs/distributions/) and related pages underneath

### Distribution testing (3 weeks)

Distribution owners will start testing the latest RC tag and report back issues they find. Depending on the severity of the issues, and number of bug fixes that will accommodate them, the Manifests WG leads might need to cut a new RC tag.

After the 3 weeks pass, for this phase, the release process will not further wait for the distributions to be ready.

**Actions for other WGs:**

- Evaluate which of the reported issues should be release blocking
- Work on providing bug fixes for release blocking issues
- Create a final git tag. It should be stable (not RC) and include fixes for release blocking issues found during this time

**Actions for Manifests WG:**

- (Optional) Create a **vX.Y-rc.3** tag, depending on the number of created issues and bug fixes

**Actions for Release Team:**

- Work with the WG to build the release slides
- Start creating the draft for the official blog post and collating information from the Working Groups
    - (Optional but encouraged) Working Groups start drafting WG-specific blog
        posts, deep diving into their respective areas
- Preparation for social media posts can start at the beginning of this phase
- Release Manager: List the features, and ideally with docs, that made it into the release

**Success Criteria:** Thumbs up from distribution representatives when their testing is complete.

### Release

We made it!

**Actions for Manifests WG:**

- Create the final **vX.Y** tag, pointing to the latest commit of the release branch
- Cut a new GitHub release in <https://github.com/kubeflow/kubeflow>
- Cut a new GitHub release in <https://github.com/kubeflow/manifests>

**Actions for Release Team:**

- Publish release blog post
- (Optional but encouraged) Working Groups publish individual deep dive blog posts on features or other work they’d like to see highlighted.
- Publish social media posts
- Send [release announcement](https://groups.google.com/g/kubeflow-discuss/c/qDRvrLPHU70/m/ORKN14DzCQAJ) to kubeflow-discuss

## Post Release

### Patch Release
Planning for first patch release begins. The importance of bugs is left to the
judgement of the Working Group's tech leads and the Release Manager to decide.
Fixes included in the patch release must satisfy the following criteria:
* important bug fixes
* critical security fixes
* updates to documentation

The tech leads of a WG can also coordinate and decide, alongside the
Manifests WG tech leads and the Release Manager, if a component's versions should be
bumped in this patch release or go to the next minor release.

The Release team continues to meet regularly, as often as needed for the point
releases. Similar to the minor release, the patch releases should have a
tracking issue or board so that distributions can track patch releases
independently of the minor releases.

### Release Retrospective

The Release Team should host a [blameless](https://sre.google/sre-book/postmortem-culture/)
retrospective and capture notes with the community. The aim of this doc
is for everyone to chime in and discuss what went well and what could be improved.

### Prepare for the Next Release
- Release Manager nominates the next release manager and discuss with the release team
- Send out a [call for participation](https://groups.google.com/g/kubeflow-discuss/c/mdpnTxYv7kM/m/dO9ny3woCQAJ) for the next release
- (if needed) Update the release handbook
- Work to close any remaining tasks
- Close all release tracking issues
- Give Kubeflow release calendar access to the new release manager

