# Kubeflow Steering Committee

The Kubeflow Steering Committee (KSC) is the governing body of the Kubeflow project, providing decision-making and oversight pertaining to the Kubeflow project policies, sub-organizations, and financial planning, and defines the project values and structure.

The [charter](charter.md) defines the scope and governance of the KSC.

## Members

The current membership of the committee is (listed alphabetically by first name):

| Name                | Organization | GitHub                                                           | Term Start | Term End   |
| ------------------- | ------------ | ---------------------------------------------------------------- | ---------- | ---------- |
| Andrey Velichkevich | Apple        | [andreyvelich](https://github.com/andreyvelich/)                 | 02/01/2026 | 02/01/2028 |
| Chase Christensen   | Wiz          | [chasecadet](https://github.com/chasecadet/)                     | 02/01/2026 | 02/01/2028 |
| Francisco Arceo     | Red Hat      | [franciscojavierarceo](https://github.com/franciscojavierarceo/) | 02/01/2025 | 02/01/2027 |
| Julius von Kohout   | DHL          | [juliusvonkohout](https://github.com/juliusvonkohout/)           | 02/01/2025 | 02/01/2027 |
| Mathew Wicks        | NVIDIA       | [thesuperzapper](https://github.com/thesuperzapper/)             | 02/01/2026 | 02/01/2028 |

### Emeritus Members

The list of emeritus members that previously served on KSC:

| Name         | Organization | GitHub                                             | Term Start | Term End   |
| ------------ | ------------ | -------------------------------------------------- | ---------- | ---------- |
| Johnu George | Nutanix      | [johnugeorge](https://github.com/johnugeorge/)     | 02/01/2024 | 02/01/2026 |
| Josh Bottum  | Independent  | [jbottum](https://github.com/jbottum/)             | 02/01/2024 | 02/01/2025 |
| James Wu     | Google       | [james-jwu](https://github.com/james-jwu/)         | 02/01/2024 | 02/01/2025 |
| Yuan Tang    | Red Hat      | [terrytangyuan](https://github.com/terrytangyuan/) | 02/01/2024 | 02/01/2026 |

## Meetings

The KSC currently meets weekly. Meetings are open to the public and held online, unless they pertain to
sensitive or privileged matters.

- Friday at 7:30AM PST (Pacific Time)
- [Meeting notes](https://docs.google.com/document/d/1IzmwOpEszYTfkGkMITBgLm1Hid6LgOwla0HgZXJd7UQ)
- [YouTube playlist recordings](https://www.youtube.com/@KubeflowCommunity)

## Contact

- Slack: [#kubeflow-contributors](https://cloud-native.slack.com/archives/C0742LBR5BM)
- Private mailing list: ksc@kubeflow.org
- Open community [issue/PR](https://github.com/kubeflow/community/issues/new)
- GitHub Team: [@kubeflow-steering-committee](https://github.com/orgs/kubeflow/teams/kubeflow-steering-committee)

## Ownership Transfer

The KSC members hold administrative ownership of Kubeflow assets. When new members of the KSC are elected,
a GitHub issue must be created to facilitate the transfer to the incoming members.

GitHub issue name:

```
Transfer Ownership to KSC 2025
```

GitHub issue content:

- [ ] Update Kubeflow Steering Committee document with the new members and emeritus members.
- [ ] Archive the current Slack channel (e.g. `#archived-ksc-2024`) and create the new Slack channel (e.g. `kubeflow-steering-committee`).
- [ ] Schedule weekly calls with the new members.
- [ ] Update [admins for Kubeflow GitHub org](https://github.com/kubeflow/internal-acls/blob/master/github-orgs/kubeflow/org.yaml#L7).
- [ ] Update the [`kubeflow-steering-committee` GitHub team](https://github.com/kubeflow/internal-acls/blob/master/github-orgs/kubeflow/org.yaml).
- [ ] Update approvers for the following OWNERS files (e.g the past members should be moved to `emeritus_approvers`):
  - `kubeflow/kubeflow` [OWNERS file](https://github.com/kubeflow/kubeflow/blob/master/OWNERS).
  - `kubeflow/community` [OWNERS file](https://github.com/kubeflow/community/blob/master/OWNERS).
  - `kubeflow/internal-acls` [OWNERS file](https://github.com/kubeflow/internal-acls/blob/master/OWNERS).
  - `kubeflow/website` [OWNERS file](https://github.com/kubeflow/website/blob/master/OWNERS).
  - `kubeflow/blog` [OWNERS file](https://github.com/kubeflow/blog/blob/master/OWNERS).
- [ ] Kubeflow GCP projects under `kubeflow.org` organization for ACLs and DNS management.
  - Access for `kf-admin-cluster` GKE cluster in `kubeflow-admin` GCP project for the GitHub ACLs sync.
  - Access for `kubeflow-dns` GCP project for the DNS management.
- [ ] Access for Kubeflow GKE cluster `kf-ci-v1` in `kubeflow-ci` GCP project (No Organization)
      where Prow is running.
- [ ] Kubeflow [Google Group](https://groups.google.com/g/kubeflow-discuss).
- [ ] Update members for [KSC Google Group](https://groups.google.com/a/kubeflow.org/g/ksc).
- [ ] Access to Kubeflow `1password` account.
- [ ] Kubeflow social media resources.
  - Kubeflow [LinkedIn](https://www.linkedin.com/company/kubeflow/)
  - Kubeflow [X](https://x.com/kubeflow).
  - Kubeflow [Bluesky](https://bsky.app/profile/kubefloworg.bsky.social).
  - [Kubeflow Community](https://www.youtube.com/@KubeflowCommunity) YouTube channel.
  - [Kubeflow](https://www.youtube.com/@Kubeflow) YouTube channel.
