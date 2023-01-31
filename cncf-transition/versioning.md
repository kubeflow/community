# Kubeflow Versioning Policy

[Kubeflow Working Groups](https://github.com/kubeflow/community/blob/master/wg-list.md) (WG) follows
 [semantic versioning](https://semver.org/) terminology expressed as X.Y.Z format, where X is the major version,
 Y is the minor version, and Z is the patch version.

For pre-release artifacts, `rc` and a number incrementing from 0 are appended to the end of the version to indicate
 that it is a pre-release. For example, `X.Y.Z-rc.0`.

In addition, some Kubeflow WGs leverage feature stages `alpha` and `beta` before releasing a stable version.
 For example, `X.Y.Z-alpha.0`.

For more details, see specification of working group version policy and release process
- [Katib](https://github.com/kubeflow/katib/tree/master/docs/release#release-process)
- [Pipelines](https://github.com/kubeflow/pipelines/blob/master/RELEASE.md#release-tags-and-branches)
- [Training Operator](https://github.com/kubeflow/training-operator/blob/master/docs/release/releasing.md)
- [Manifests and Notebooks](https://github.com/kubeflow/community/blob/master/releases/handbook.md#feature-freeze-2-weeks)
