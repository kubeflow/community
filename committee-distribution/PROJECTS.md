# Projects in Kubeflow Community Distribution

## Bundled Projects

The Kubeflow Community Distribution (KCD) will bundle the following projects:

| Project                 | Type                | Enabled by Default |
|-------------------------|---------------------|--------------------|
| Kubeflow Hub            | Kubeflow Subproject | Yes                |
| Kubeflow Katib          | Kubeflow Subproject | Yes                |
| Kubeflow Notebooks      | Kubeflow Subproject | Yes                |
| Kubeflow Pipelines      | Kubeflow Subproject | Yes                |
| Kubeflow SDK            | Kubeflow Subproject | Yes                |
| Kubeflow Spark Operator | Kubeflow Subproject | Yes                |
| Kubeflow Trainer        | Kubeflow Subproject | Yes                |
| KServe                  | Kubeflow Ecosystem  | Yes                |

Requirements:

- To be eligible for bundling, a project must be [Kubeflow Subproject](../subprojects) or member of the [Kubeflow Ecosystem](../ecosystem).
- Required dependencies of bundled projects may also be bundled, even if they are not Kubeflow Subprojects or Kubeflow Ecosystem projects.

## Changes to Bundled Projects

Changes to the bundled projects may be proposed through a Pull Request on this document by any member of the Kubeflow community.

The Kubeflow Distribution Committee will review the proposal and vote on whether to accept or reject the proposed change following [the KCD decision process](./charter.md#kcd-decision-process).

Proposals and amendments to this document are available for at least a period of one week for comments and questions before a vote will occur.
