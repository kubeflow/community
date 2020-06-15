## SUMMARY:

This document covers everything you need to know about the creation and retirement (“lifecycle”) of a working group within Kubeflow. General project governance information can be found in the [governance doc].
Out of scope for this document: [subproject] creation.

[Creation]
[Retirement]

## [Creation]
### Prerequisites for a WG
- [ ] Read [wg-governance.md]
- [ ] Ensure all WG Chairs, Technical Leads, and other leadership roles are [community members]
- [ ] Send an email to the Steering Committee <steering@kubeflow.org> to scope the WG and get provisional approval.
- [ ] Look at the checklist below for processes and tips that you will need to do while this is going on. It's best to collect this information upfront so you have a smoother process to launch
- [ ] Follow the [WG charter process] to propose and obtain approval for a charter
- [ ] Announce new WG on kubeflow-discuss@googlegroups.com

### [GitHub]

TODO: This section needs to be added for KF. In particular do we want to use [generator doc] which is what Kubernetes uses or is that
too heavy weight?

- [ ] Submit a PR that will add rows to [wgs.yaml] using the [generator doc]; this will create README files and OWNERS_ALIASES files for your new directory in `kubernetes/community`
- You’ll need:
  - WG Name
  - Directory URL
  - Mission Statement
  - Chair Information
  - Meeting Information
  - Contact Methods
  - Any WG Stakeholders
  - Any Subproject Stakeholders
- [ ] Add WG-related docs like charter.md, schedules, roadmaps, etc. to your new kubeflow/community/wg-foo directory once the above PR is merged.
- [ ] File a [kubeflow/testing] Issue  and PR for a label; read about our [GitHub management] services

### Communicate:

WGs are responsible for setting up and administering the following communication channels
- [ ] Mailing lists 
      * foo@googlegroups.com
      * foo-leads@googlegroups.com
- [ ] Calendar for WG related meetings
- [ ] Video conferencing (zoom, meet, etc...) 
- [ ] Hosting for meeting notes, recordings etc...
- [ ] Slack channels (if desired)

### Engage:
...as a chair/tech lead with other chairs/tech leads
- [ ] Subscribe to the kubeflow-sig-leads@googlegroups.com group
- [ ] Join the #chairs-and-techleads slack channel

...with the community as part of [wg-governance.md]
- [ ] Get on the Kubeflow community meeting agenda to provide WG updates
- [ ] Create a shared calendar and schedule your weekly/biweekly/triweekly weeks [update meetings]
- This calendar creation process will allow all of your leads to edit SIG/WG Meetings. This is important as we all change jobs, email addresses, and take breaks from the project. Shared calendars will also provide consistency with contributors looking for your subproject meetings, office hours, and anything else that the SIG/WGs contributors should know about.

## [Retirement]
(merging or disbandment)
Sometimes it might be necessary to sunset a SIG or Working Group. SIGs/WGs may also merge with an existing SIG/WG if deemed appropriate, and would save project overhead in the long run. SIGs in particular are more ephemeral than WGs, so this process should be followed when the SIG has accomplished it's mission.

### Prerequisites for WG Retirement
- [ ] Have completed the mission of the WG or have another reason as outlined in [wg-governance.md]

### Steps:
- [ ] Send an email to kubeflow-discuss@googlegroups.com alerting the community of your intentions to disband or merge. [example]
- [ ] Archive the member and lead/chair mailing lists/[GoogleGroups]
- [ ] Delete your shared WG calendar
- [ ] Move the existing WG directory into the archive in `kubeflow/community`
- [ ] GitHub archiving/removing/other transactions:
   - [ ] Move all appropriate github repositories to an appropriate archive or a repo outside of the Kubernetes org
   - [ ] Each subproject a WG owns must transfer ownership to a new WG, outside the project, or be retired
   - [ ] File an issue with kubernetes/org if there are multiple repos
   - [ ] Retire or transfer any test-infra jobs or testgrid dashboards, if applicable, owned by the SIG. Work with SIG-Testing on this.
   - [ ] Migrate/Remove/Deprecate any SIG/WG labels in labels.yaml
   - [ ] Remove or rename any GitHub teams that refer to the WG
   - [ ] Update sigs.yaml to remove or rename


[governance doc]: https://bit.ly/kf-governance
[subproject]: /governance.md#subprojects
[Creation]: #Creation
[Retirement]: #Retirement
[GitHub]: #GitHub
[wg-governance.md]: wg-governance.md
[WG charter process]: wg-charter
[wgs.yaml]: /templates/wgs.yaml
[generator doc]: https://github.com/kubernetes/community/tree/master/generator
[GitHub management]: https://github.com/kubeflow/community/blob/master/how-to/github_admin.md
[code of conduct]: https://github.com/kubeflow/community/blob/master/CODE_OF_CONDUCT.md
[GoogleGroups]: https://github.com/kubeflow/community/blob/master/how-to/kubeflow_assets.md#mailing-list
[slack-guidelines.md]: https://github.com/kubeflow/community/blob/master/how-to/kubeflow_assets.md#slack
[zoom-guidelines.md]: https://github.com/kubeflow/community/blob/master/how-to/kubeflow_assets.md#zoom
