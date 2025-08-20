# KEP-434: Kubeflow Distributions

## Objective

Clarify how Kubeflow distributions will be owned and developed going forward.

## Motivation

Kubeflow can be divided into pieces

1. Individual Kubeflow applications (e.g. Pipelines, KFServing, notebooks, etc...)
1. Distributions of Kubeflow (e.g. Kubeflow on GCP, Kubeflow on AWS, MiniKF, etc...)

Since July, the Kubeflow community has been working on forming working groups to create greater
accountability for the different parts of Kubeflow.

At this point in time, Kubeflow has formed working groups with clear ownership for all of the individual Kubeflow
applications.

There is an ongoing debate about who should own and maintain Kubeflow distributions.

To date there are two categories of distributions

1. Kubeflow distributions tied to a specific platform (e.g. AWS, GCP, etc...)
1. Generic distributions (e.g. for MiniKube, any conformant K8s cluster, etc...)

The former have been owned and maintained by the respective vendors. The general consensus is that these should continue
to be owned and maintained by the respective vendors outside any KF working group.

This leaves the question of what to do about generic distributions. In particular, in [kubeflow/community#402](https://github.com/kubeflow/community/pull/402) there was a long debate about whether the deployments working group would own them or not. That discussion appears to be converging with the decision being that the deployments working group will not own any distributions.

## Proposal

Going forward all distributions of Kubeflow should be owned and maintained outside of Kubeflow.

### What is a Kubeflow Distribution

A Kubeflow distribution is an opinionated bundle of Kubeflow applications optimized for a particular use case or environment.

### Ownership & Development

Going forward new distributions of Kubeflow should be developed outside of the Kubeflow GitHub org. This ensures

- Accountability for the distribution
- Insulates Kubeflow from the success or failure of the distribution
- Avoid further taxing Kubeflow's overstretched engprod resources(see[kubeflow/testing#737](https://github.com/kubeflow/testing/issues/737))

The owners of existing distributions should work with the respective WG/repository/org owners to come up with appropriate transition plans.

### Naming

Distributions of Kubeflow are encouraged to pick unique names that avoid creating confusion and conflict by suggesting that
a given distribution is endorsed by Kubeflow.

As an example, the name "KFCube" for a distribution targeting minikube is highly discouraged as this suggests the distribution is endorsed by Kubefow. An alternative, like "MLCube" would be preferable.

### Releasing & Versioning

Releasing and versioning for each distribution is the responsibility of the distribution owners.
This includes determining the release cadence. The release cadence of distributions doesn't need to be in sync
with Kubeflow releases.

## Alternatives Considered

An alternative would be to spin up a work group to own or maintain one or more generic distribution.

This has the following disadvantages

- Distributions aren't treated uniformly as some distributions are owned by Kubeflow and thus implicitly endorsed by Kubeflow
- Historically, creating accountability for generic distributions has been difficult
