# Kubeflow Release Handbook

### Goals

* Use Calendar Versioning (CalVer) to clearly indicate when releases occur.
* Provide a predictable release schedule with clear dates and phases for distributions, working groups, and the community.
* Minimize release overhead through automation and asynchronous communication.
* Reduce meeting time by focusing on bi-weekly syncs during development and weekly syncs during testing phases.
* Enable fast iteration through patch releases as needed.

### Release Meetings and Communication
* Create a new Release Management team on Slack for asynchronous communication within the team
* Bi-weekly meetings during Software Development (Week 1-Week 8). Weekly meetings between week 9-16 as needed.
* Meetings will focus on roadmap status, including blockers, feature discussions, the overall status of the release, and the help needed.

### Versioning (CalVer)

Kubeflow uses [Calendar Versioning](https://calver.org/) (CalVer) for the Kubeflow AI Reference Platform. The version format is:

```
YYYY.MM[.PATCH]
```

Where:
- **YYYY** = release year
- **MM** = release month
- **PATCH** = optional bug-fix release number (incremental integer)

### Release Cadence

* Kubeflow targets two base releases per year
* Patch releases are issued as needed using the format `YYYY.MM.PATCH`.

### Patch (Bug-Fix) Release Policy

Patch releases:
- Must not introduce new features
- Must increment sequentially (`.1`, `.2`, …)
- Must retain the same `YYYY.MM` base version even if released in a later calendar month

### Pre-Release Policy (Release Candidates)

Kubeflow uses Release Candidates (RC) as the only pre-release type.

**Release Candidate Naming:**
```
YYYY.MM-rc.1
YYYY.MM-rc.2
```

**RC Rules:**
- `rc1` is mandatory for every base release
- `rc2` is optional and may only be created if major blockers are reported during `rc1` testing, such as:
  - Installation failures
  - Upgrade regressions
  - Component breakage
  - Security issues
- `rc2` must only contain fixes for `rc1` blockers
- No new features are allowed in any RC
- Additional RC iterations beyond `rc2` may be issued if needed, at the discretion of the release team

**RC Testing Period:**
- `rc1` testing period: 3 weeks
- `rc2` testing period: up to 2 weeks, if needed

### Timeline
* Week 0 - (Release and Roadmap discussions) WG Leads and release team meet to discuss the roadmap planned for the release
* Week 2 - (Software development Phase) WG Leads/Liaisons meet to discuss any release challenges, release changes, and help needed from the community (to communicate on Kubeflow Community Meeting)
* Week 4 - (Software development Phase) WG Leads/Liaisons meet to discuss any release challenges, release changes, and help needed from the community (to communicate on Kubeflow Community Meeting)
* Week 6 - (Software development Phase) WG Leads/Liaisons meet to discuss any release challenges, release changes, and help needed from the community (to communicate on Kubeflow Community Meeting)
* Week 8 - (Last week of Software development Phase) WG Leads/Liaisons meet to discuss any release challenges, release changes, and help needed from the community (to communicate on Kubeflow Community Meeting)
* Week 9 - (Feature Freeze and Prep for Release) WG Leads/Liaisons finalize features and prepare documentation. `rc1` is cut at the end of this week.
* Week 10 - (RC1 Testing begins - Community and Distribution validation) Users and distributions start testing and report blockers.
* Week 11 - (RC1 Testing continues) Continued validation and blocker identification.
* Week 12 - (RC1 Testing ends) Final week of 3-week testing period. Discuss any potential blockers.
* Week 13 - (Release or RC2) Promote `rc1` to final release if no major blockers. Otherwise, apply fixes and cut `rc2`.
* Week 14-15 - (RC2 Testing, if needed) 2 weeks validation period for `rc2`. Community and distributions report blockers.
* Week 16 - (Final Release, if RC2 was needed) Promote `rc2` to final release.
- Manifests WG leads synchronize and cut the release on Kubeflow Platform/Manifests following [Calendar Versioning](https://calver.org/) (`YYYY.MM[.PATCH]`)
- The Release Manager is responsible for approving/reviewing the blog and slides announcing the release.

## People and Roles

### Release Management Team: 
The Release Management Team is composed of: Release Manager, WG leads / liaisons, and Product Owner.
Release team liaisons will be responsible not only for the communication but for contributing to the release with documentation, source code, PRs review, etc, according to their skills and motivation.

### Release Manager Responsibilities: 
- Responsible for the overall Kubeflow Release Process 
- Promote best practices for the release and software development process.
- Manage the communication between the teams to understand current release status and potential blockers
- Manage the communication with the community about the status of the Release or any help/blockers needed.
- Approve & review the blog and slides announcing the Release.
- Provide updates to the mailing list with the progress of the release
- Coordinate directly with the WG liaisons and leads about dates and deliverables
- Coordinate with the Release Team Members for the progress of the release
- Ensure the WG leads have cut the necessary GitHub branches and tags for the different phases of the release
- Host the Release Team meetings
- Update the larger community on release status during the Kubeflow community meetings
- Make sure the processes are being followed
- Make decisions on release date or go-no for each release

### Release Manager Shadows

Release Manager Shadows are community members interested in becoming a Release Manager. They work closely with the current Release Manager throughout the release cycle to learn the process and are prepared to lead future releases.

### Product Owner

The Product Owner is responsible for coordinating documentation updates, the release blog, and the final presentation for the Kubeflow release.

**Responsibilities:**
- Ensure documentation is updated and accurate for the release
- Identify and track issues that require documentation updates
- Coordinate and publish the release blog post
- Prepare the final release presentation and slides

### Preparation

- [ ] [Assemble a release team](https://github.com/kubeflow/community/issues/571)
- [ ] Create a new [release project](https://github.com/orgs/kubeflow/projects) to track issues and pull requests related to the release
- [ ] Working groups broadly think about features **with priorities** they want to land for that cycle, have internal discussions, perhaps groom a backlog from previous cycle, get issues triaged, etc.
- [ ] Update the release manager and members of the Release Team in the [kubeflow/internal-acls](https://github.com/kubeflow/internal-acls/pull/545)
- [ ] Update the [owners file](https://github.com/kubeflow/community/blob/master/releases/OWNERS) by appointing the new release manager as approver and the rest of the release team as reviewers. Add the previous release manager to the list of emeritus approvers.
- [ ] Establish a regular release team meeting as appropriate on the schedule and update the [Kubeflow release team calendar](https://zoom-lfx.platform.linuxfoundation.org/meeting/92113176338?password=883a2c39-41a9-4395-b9f2-d2bd73e8c39e)
- [ ] [Propose a release timeline](https://github.com/kubeflow/community/pull/558), announce the schedule to [kubeflow-discuss mailing list](https://groups.google.com/g/kubeflow-discuss), and get lazy consensus on the release schedule from the WG leads
  - Review the criteria for the timeline below
- [ ] Ensure schedule also accounts for the patch releases after the base release
- [ ] Create one [release tracking issue](https://github.com/kubeflow/manifests/issues/2194) for all WGs, distributions representatives, and the community to track
- [ ] Start a discussion on [Kubeflow dependency versions](https://github.com/kubeflow/manifests/issues/2207) to support for the release

Criteria for timeline that the team needs to consider
- Holidays around the world that coincide with members of the release team, WG representatives, and distro representatives.
- Enterprise budgeting/approval lifecycle. (aka users have their own usage and purchase requirements and deadlines)
- Kubecon dates - let’s not hard block on events, but keep them in mind since we know community members might get doublebooked.
- Associated events (aka. AI Day at Kubecon, Tensorflow events) - we want to keep them in mind.

**Success Criteria:** Release team selected, release schedule sent to kubeflow-discuss, all release team members have the proper permissions and are meeting regularly.

### Implementation
**Actions for the Release Team:**
- Get a git revision from all WGs, on the first day of the Feature Freeze period. WGs need to have a git revision ready to give to the release team.
- Make a pull request to update the manifests for the different WGs, based on the _git revision_ they provided.
- Identify, early in the first week, bugs at risk. These should either be aggressively fixed or punted
- Request a list of features and deprecations, from the Working Groups, that require updates to the documentation
- Ensure the provided component versions match the documentation
- Work alongside the Working Groups to bring the documentation up to date
- Create a [new version dropdown and update the website version](https://github.com/kubeflow/website/pull/3333)
- Add new [release page with component and dependency versions](https://github.com/kubeflow/website/pull/3332)
- Work with the WG to build the release notes and slides
- Start creating the draft for the official blog post and collating information from the Working Groups
    - (Optional but encouraged) Working Groups start drafting WG-specific blog
        posts, deep diving into their respective areas
- Preparation for social media posts can start at the beginning of this phase
- Release Manager: List the features, and ideally with documentation, that made it into the release
- Publish release blog post
- (Optional but encouraged) Working Groups publish individual deep dive blog posts on features or other work they’d like to see highlighted.
- Publish social media posts
- Send [release announcement](https://groups.google.com/g/kubeflow-discuss/c/qDRvrLPHU70/m/ORKN14DzCQAJ) to kubeflow-discuss

**Success Criteria:**
- Documentation for this release completed with minimum following pages updated and a [new version
in the website is cut](https://github.com/kubeflow/kubeflow/blob/master/docs_dev/releasing.md#version-the-website).
- [Installing Kubeflow](https://www.kubeflow.org/docs/started/installing-kubeflow/)
- [Release Page](https://www.kubeflow.org/docs/releases/)
- [Distributions](https://www.kubeflow.org/docs/distributions/) and related pages underneath

## Post Release

### Patch Release
Planning for first patch release begins. Patch releases follow the `YYYY.MM.PATCH` format and must not introduce new features or intentional API changes. The importance of bugs is left to the judgement of the Working Group leads and the Release Manager to decide.

### Release Retrospective

The Release Team should host a [blameless](https://sre.google/sre-book/postmortem-culture/)
retrospective and capture notes with the community. The aim of this document
is for everyone to chime in and discuss what went well and what could be improved.

### Prepare for the Next Release
- Release Manager nominates the next release manager and discusses with the release team
- Send out a [call for participation](https://groups.google.com/g/kubeflow-discuss/c/mdpnTxYv7kM/m/dO9ny3woCQAJ) for the next release
- (if needed) Update the release handbook
- Work to close any remaining tasks
- Close all release tracking issues
- Give Kubeflow release calendar access to the new release manager

