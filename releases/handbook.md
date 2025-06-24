# Kubeflow Release Handbook

### Goals

* Cut down the release handbook to fit on a single page.
* Replace the the manual bureaucratic process and overhead and human hours needed by an an automation first approach
* Move away from the Waterfall model to an agile model that relies on automated tests instead of human labor.
* Reduce time to market of Kubeflow Release, by being able to release at any time
* Reduce meeting time and structure to give back time to the Release Team.
* Focus on contributions from technical documents and source code by reducing meetings and promoting asynchronous communication.
* Promote clarity on dates and phases so distributions, working groups, and the whole community can plan accordingly.
* Improve release cycle by moving technical decisions affecting the release to the Release Management team including Kubeflow platform


### Release Timelines
KubeFlow Release x.x is moved to Quarterly Release = 12 weeks

![alt text](release.png)

* Notes: Release dates will not be changed unless critical changes are needed.

* KubeFlow Release minor versions x.x.xx
** Release can be 60-90 days.

### Release Meetings and Communication
* Create a new Release Management team on Slack for asynchronous communication within the team
* Bi-weekly meetings during Software Development (Week 1-Week 8). Weekly meetings between week 9-12 as needed.
* Meetings will focus on roadmap status, including blockers, feature discussions, the overall status of the release, and the help needed.

### Release Documentation

* Build a team of technical writers to be embedded in each working group for the release time frame. 
* Provide roles within the community to boost participation and bring new members into this group.
* Technical Documentation Lead will lead this team; technical documentation can include a blog and slides to announce the Release.

### Release Management Team: 
The Release Management Team is composed by: Release Manager, WG Leads ( in some cases Liasons), Technical documentation lead.
Responseabilities:

- Release team liaisons will be responsible not for the communication but for contributing to the release with documentation, source code, PRs review, etc, according to their skills and motivation.

### Release Manager Responsibilities: 
- Responsible for the overall Kubeflow Release Process 
- Promote best practices for the release and software development process.
- Manage the communication between the teams to understand current release status and potential blockers
- Manage the communication with the community about the status of the Release or any help/blockers needed.
- Approve & review the blog and slides announcing the Release.


### Implementation
* Week 0 -  (Release and Roadmap discussions) WG Leads and Release Manager meet to discuss the roadmap planned for the Release
* Week 2 - (Software development Phase) WG Leads/Liaisons meet to discuss any release challenges, release changes, and help needed from the community (to communicate on Kubeflow Community Meeting)
* Week 4 - (Software development Phase) WG Leads/Liaisons meet to discuss any release challenges, release changes, and help needed from the community (to communicate on Kubeflow Community Meeting)
* Week 6 - (Software development Phase) WG Leads/Liaisons meet to discuss any release challenges, release changes, and help needed from the community (to communicate on Kubeflow Community Meeting)
* Week 8 - (Last week of Software development Phase) WG Leads/Liaisons meet to discuss any release challenges, release changes, and help needed from the community (to communicate on Kubeflow Community Meeting)
* Week 9 - (Feature Freeze and Prep for Release) WG Leads/Liaisons meet to discuss any release challenges, release changes, and help needed from the community (to communicate on Kubeflow Community Meeting). Discuss items required to prepare for Release (including documentation).
* Week 10 - (Community and Distribution testing starts) Users and distributions run their automated test suites and try to stay away from manual labor-intensive tests.
* Week 11 - (Bug Fixing) - Discuss any potential blockers for the Release.
* Week 12 - (Release) - Items to discuss: bug fixes required, release cut, documentation needed.
- Manifests WG leads synchronizes and cut the release on Kubeflow Platform/Manifests.
- The Release Manager is responsible for approving/reviewing the blog and slides announcing the release.

## People and Roles

### Release Manager
The Release Manager will be responsible for coordinating the release and taking ultimate accountability for all release tasks to be completed on time.

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

### Product Manager

**Responsibilities:**
* Drive the release blog post effort
* Drive the release presentation effort
* Handle communication for social media content publication
* Orchestrate and create user surveys
* Track important features and bug fixes that should be highlighted in the release

### Documentation Lead

The Documentation lead is responsible for working with the Release Team to coordinate documentation updates for the next Kubeflow release.
If no members can serve as documentation lead, the release manager must take on the role.

**Responsibilities:**
* Identify and track new issues that require update to the documentation
* Work with contributors to modify the existing documentation to accurately represent any upcoming changes
* Review documentation PRs to ensure quality following the website [Style Guide](https://www.kubeflow.org/docs/about/style-guide/)
* Migrate the old website [version] documentation and updating it with the new release

### Documentation

Working groups should briefly describe what changes to existing [kubeflow.org](https://www.kubeflow.org/) documentation will be required to ensure the docs reflect new features or other software updates. A few bullets identifying which pages in the docs need to change will suffice. These bullets should be added to the Working Group’s GitHub issues describing planned engineering work.

Working Groups should be tracking features for the release, as well as the documentation status of each feature as it’s being developed so that the documentation team can keep track of the documentation work that needs to be done.

### Preparation

- [ ] [Assemble a release team](https://github.com/kubeflow/community/issues/571)
- [ ] Create a new [release project](https://github.com/orgs/kubeflow/projects) to track issues and pull requests related to the release
- [ ] Working groups broadly think about features **with priorities** they want to land for that cycle, have internal discussions, perhaps groom a backlog from previous cycle, get issues triaged, etc.
- [ ] Update the release manager and members of the Release Team in the [kubeflow/internal-acls](https://github.com/kubeflow/internal-acls/pull/545)
- [ ] Update the [owners file](https://github.com/kubeflow/community/blob/master/releases/OWNERS) by appointing the new release manager as approver and the rest of the release team as reviewers. Add the previous release manager to the list of emeritus approvers.
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


**Actions for the Release Team:**
- Get a git revision from all WGs, on the first day of the Feature Freeze period. WGs need to have a git revision ready to give to the release team.
- Make a pull request to update the manifests for the different WGs, based on the _git revision_ they provided.
- Identify, early in the first week, bugs at risk. These should either be aggressively fixed or punted
- Request a list of features and deprecations, from the Working Groups, that require updates to the documentation
- Ensure the provided component versions match the documentation
- Work alongside the Working Groups to bring the documentation up to date
- Create a [new version dropdown and update the website version](https://github.com/kubeflow/website/pull/3333)
- Add new [release page with component and dependency versions](https://github.com/kubeflow/website/pull/3332)
- Work with the WG to build the release slides
- Start creating the draft for the official blog post and collating information from the Working Groups
    - (Optional but encouraged) Working Groups start drafting WG-specific blog
        posts, deep diving into their respective areas
- Preparation for social media posts can start at the beginning of this phase
- Release Manager: List the features, and ideally with documentation, that made it into the release
- Publish release blog post
- (Optional but encouraged) Working Groups publish individual deep dive blog posts on features or other work they’d like to see highlighted.
- Publish social media posts
- Send [release announcement](https://groups.google.com/g/kubeflow-discuss/c/qDRvrLPHU70/m/ORKN14DzCQAJ) to kubeflow-discuss

**Success Criteria:** Documentation for this release completed with minimum following pages updated and a [new version
in the website is cut](https://github.com/kubeflow/kubeflow/blob/master/docs_dev/releasing.md#version-the-website).
- [Installing Kubeflow](https://www.kubeflow.org/docs/started/installing-kubeflow/)
- [Release Page](https://www.kubeflow.org/docs/releases/)
- [Distributions](https://www.kubeflow.org/docs/distributions/) and related pages underneath

**Actions for other WGs:**

- Evaluate which of the reported issues should be release blocking
- Work on providing bug fixes for release blocking issues
- Create a final git tag. It should be stable (not RC) and include fixes for release blocking issues found during this time


## Post Release

### Patch Release
Planning for first patch release begins. The importance of bugs is left to the
judgement of the Working Group's tech leads and the Release Manager to decide.
Fixes included in the patch release must satisfy the following criteria:
* important bug fixes
* critical security fixes
* updates to documentation

### Release Retrospective

The Release Team should host a [blameless](https://sre.google/sre-book/postmortem-culture/)
retrospective and capture notes with the community. The aim of this document
is for everyone to chime in and discuss what went well and what could be improved.

### Prepare for the Next Release
- Release Manager nominates the next release manager and discuss with the release team
- Send out a [call for participation](https://groups.google.com/g/kubeflow-discuss/c/mdpnTxYv7kM/m/dO9ny3woCQAJ) for the next release
- (if needed) Update the release handbook
- Work to close any remaining tasks
- Close all release tracking issues
- Give Kubeflow release calendar access to the new release manager

