# KEP-645: KSC Election Process Proposal

## 2 cohorts and Staggered elections

KSC consists of 5 members, made up of 2 cohorts of 3 members and 2 members, respectively. Each cohort will be elected every 2 years, with the election schedule staggered so elections for the 2 rotations occur on alternate years. The staggered cohorts are designed to provide continuity and stability in the project leadership of Kubeflow.  
The only exception to the above rule is that the first 2-member rotation consists of 2 members from the Interim KSC, and will be re-elected after 1 year. The goal of having interim KSC members participate in the first KSC is to provide guidance, facilitate asset transitions from Google, and hopefully make the transition in open governance a smooth process.  
The table below illustrates the cohorts and election schedules:

<table>
  <thead>
    <tr>
      <th>Timeline</th>
      <th>2-member cohort</th>
      <th>3-member cohort</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>2023</td>
      <td>Interim KSC member A<br>
Interim KSC member B</td>
      <td>New election</td>
    </tr>
    <tr>
      <td>2024</td>
      <td>New election</td>
      <td></td>
    </tr>
    <tr>
      <td>2025</td>
      <td></td>
      <td>New election</td>
    </tr>
    <tr>
      <td>2026</td>
      <td>New election</td>
      <td></td>
    </tr>
    <tr>
      <td>2027</td>
      <td></td>
      <td>New election</td>
    </tr>
    <tr>
      <td>…</td>
      <td></td>
      <td></td>
    </tr>
  </tbody>
</table>

## Election Procedure

### Timeline

Steering Committee elections are held annually. 4 weeks or more before the election, the Steering Committee will appoint Election Officer(s) (see below). 2 weeks or more before the election, the Election Officer(s) will issue a call for nominations, publish the list of eligible voters, and open the call for exceptions. One week before the election the call for nominations and exceptions will be closed. The election will be open for voting not less than two weeks and not more than four. The results of the election will be announced within one week of closing the election. New Steering Committee members will take office in January of each year on the date the results are announced.

The general timeline is as follows:

- November
  - Election officers appointed
- December
  - Election preparation - publish the list of eligible voters, open call for exceptions (open for approximately 1 week)
  - Call for nominations (open for approximately 2 weeks)
  - Testimonial Phase (open for approximately 2 weeks)
  - Start of election (open for approximately 3 weeks)
- January
  - Conclusion of election
  - Results announced within one week after the election concludes
  - New steering committee members take office in January after the conclusion of the election.

### Election Officer(s)

4 weeks or more before the election, the Steering Committee will appoint between one and three Election Officer(s) to administer the election. Elections Officers will be Kubeflow community members in good standing who are eligible to vote, are not running for Steering in that election, who are not currently part of the Steering Committee and can make a public promise of impartiality. They will be responsible for:

- Making all announcements associated with the election
- Preparing and distributing electronic ballots
- Judging exception requests
- Assisting candidates in preparing and sharing statements
- Tallying voting results according to the rules in this charter

### Eligibility to Vote

Anyone who has at least 50 contributions including at least 1 merged PR in the last 12 months is eligible to vote in the Steering election. Contributions are defined as opening PRs, reviewing and commenting on PRs, opening and commenting on issues, writing design docs, commenting on design docs, helping people on slack, participating in working groups, and other efforts that help advance the Kubeflow project.

This [dashboard](https://kubeflow.devstats.cncf.io/d/9/developer-activity-counts-by-repository-group-table?orgId=1&var-period_name=Last%20year&var-metric=contributions&var-repogroup_name=All&var-country_name=All) shows only GitHub based contributions and does not capture all the contributions we value. We expect this metric not to capture everyone who should be eligible to vote. If a community member has had significant contributions over the past year but is not captured in the dashboard, they will be able to submit an exception form to the Elections Officer(s) who will then review and determine whether this member should be eligible to vote. All exceptions, and the reasons for them, will be recorded in a log that will be available to Steering and the TOC.

The electoral roll of all eligible voters will be captured at kubeflow/community/steering-elections/$YEAR/voters.md and the voters' guide will be captured at kubeflow/community/steering-elections/\$YEAR/README.md, similar to the kubernetes election process and identical to the TOC election process.

We are committed to an inclusive process and will adapt future eligibility requirements based on community feedback.

If you believe you are eligible to vote but are not listed as an elegible voter [you may file an exception using the exception form](https://forms.gle/epaMrirZCNBztoRz5).

## Candidate Eligibility

Community members must be eligible to vote in order to stand for election (this includes voters who qualify for an exception). Candidates may self-nominate or be nominated by another eligible member. There are no term limits for KSC members. Nothing prevents a qualified member from serving on the Kubeflow Steering Committee, Technical Oversight Committee and Conformance Committee simultaneously.

If you believe you are eligible to run in this election but are not listed as an eligible nominee candidate [you may file and exception using the exception form](https://forms.gle/epaMrirZCNBztoRz5).

### Voting Procedure

Elections will be held using [Condorcet Internet Voting Service (CIVS)](https://civs1.civs.us/), an online voting tool that is used by many of the CNCF projects and other open-source communities. This tool has been running since 2003 and is what the [Elekto tool](https://elekto.dev/) is based on.

After this first election, the details for the KSC elections will be published in the elections folder. This folder will be set up after the conclusion of the first election.

In the rare case that election ends in a tie, the election offices may ask the tied candidates to resolve the tie (e.g. one or more candidates could decide to withdraw). If the tie cannot be resolved among the tied candidates, a runoff election will be conducted. If the runoff election ends in a tie, candidate will be randomly selected to decided winners, with equal weights given to each runoff candidate.

### Limitations on Company Representation

No more than two seats may be held by employees of the same organization (or conglomerate, in the case of companies owning each other). If the results of an election result in greater than two employees of the same organization, the lowest vote getters in the current election from any particular employer will be removed until representation on the committee is down to two.

In the staggered election schedule, if a particular organization already has two seats among the rotation not affected by the election, no candidates from that organization will be selected by the election. If the organization wants to change its representation in KSC, one or more members from that organization needs to stand down from KSC, which will trigger a "resignation" event as explained below. There is no guarantee that vacancy created will be filled by the organization's candidate.

If employers change because of job changes, acquisitions, or other events, in a way that would yield more than 2 seats being held by employees of the same organization, sufficient members of the committee must resign until only two employees of the same employer are left. If it is impossible to find sufficient members to resign, all employees of that organization will be removed and new special elections held. In the event of a question of company membership (for example evaluating independence of corporate subsidiaries) a majority of all non-involved Steering Committee members will decide.

#### Changes to take effect in 2025 election and beyond

No more than one seat may be held by employees of the same organization. Since KSC is a relatively small committee with 5 members, this rule was introduced to encourage diversity of representation in KSC.

Exception: The 2024 election result may produce an outcome where the elected 2-member cohort comes from the same organization. In such scenario, the 2-member cohort may serve their full term of 2 years.

### Vacancies

In the event of a resignation or other loss of an elected committee member, the next most preferred candidate from the previous election will be offered the seat.

A maximum of one (1) committee member may be selected this way between elections.  
In case this fails to fill the seat, a special election for that position will be held as soon as possible.

Eligible voters from the most recent election will vote in the special election i.e., eligibility will not be redetermined at the time of the special election.

A committee member elected in a special election will serve out the remainder of the term for the person they are replacing, regardless of the length of that remainder.

### Resignation

If a committee member chooses not to continue in their role, for whatever self-elected reason, they must notify the committee in writing.

### Removal - No confidence

A Steering Committee member may be removed by an affirmative vote of four of five members.  
The call for a vote of no confidence will happen in a public Steering Committee meeting and must be documented as a GitHub issue in the committee's repository.

The call for a vote of no confidence must be made by a current member of the committee and must be seconded by another current member.

The committee member who calls for the vote will prepare a statement which provides context on the reason for the vote. This statement must be seconded by the committee member who seconded the vote.

Once a vote of no confidence has been called, the committee will notify the community through the following channels:

- the community mailing list
- the community slack channel
- In the next Kubeflow Community Meeting

This notification will include:

- a link to the aforementioned GitHub issue
- the statement providing context on the reason for the vote

There will be a period of two weeks for members of the community to reach out to Steering Committee members to provide feedback.

Community members may provide feedback by commenting on the GitHub issue.

After this feedback period, Steering Committee members must vote on the issue within 48 hours.

If the vote of no confidence is passed, the member in question will be immediately removed from the committee.
