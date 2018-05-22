_Authors:_

- [@gaocegege][] - Ce Gao &lt;gaoce@caicloud.ioo&gt;

## Motivation

Apache MXNet is a popular machine learning framework which currently does not have an operator for Kubernetes. This proposal is aimed at defining what that operator should look like, and adding it to Kubeflow.

## Goals

A Kubeflow user should be able to run training using MXNet as easily as then can using TensorFlow. This proposal is centered around a Kubernetes operator for MXNet. A user should be able to run both single node and distributed training jobs with MXNet.

This proposal defines the following:

- A MXNet operator
- A way to deploy the operator with ksonnet
- A single pod MXNet example
- A distributed MXNet example

## Non-Goals

For the scope of this proposal, we won't be addressing the method for serving the model and the [UI](https://github.com/awslabs/mxboard).

## API (CRD and resulting objects)

The custom resource submitted to the Kubernetes API would look something like this:

```yaml
apiVersion: "kubeflow.org/v1alpha1"
kind: "MXNetJob"
metadata:
  name: "example"
spec:
  replicaSpecs:
    worker:
      replicas: 4
      restartPolicy: Never
      template:
        spec:
          containers:
            - name: mxnet
              image: kubeflow/dog-food-for-mxnet:1.0
    server:
      replicas: 2
      restartPolicy: Never
      template:
        spec:
          containers:
            - name: mxnet
              image: kubeflow/dog-food-for-mxnet:1.0
    scheduler:
      restartPolicy: Never
      template:
        spec:
          containers:
            - name: mxnet
              image: kubeflow/dog-food-for-mxnet:1.0
```

This MXNetJob resembles the existing TFJob v1alpha2 version for the [tf-operator][]. MXNet has three types of processes which communicate with each other to accomplish training of a model (Please have a look at [MXNet Tutorial](https://mxnet.incubator.apache.org/faq/distributed_training.html#types-of-processes)).

### Resulting Replicas

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: example-20lm
  labels:
    controller-uid=dc3669c6-29f1-11e8-9ccd-ac1f6b8040c6
    job_type=worker
    kubeflow.org=
    task_index=0
spec:
  containers:
  - image: kubeflow/dog-food-for-mxnet:1.0
    name: mxnet
    env:
    - name: DMLC_ROLE
      value: worker
    - name: DMLC_PS_ROOT_URI
      value: example-20lm-scheduler
    - name: DMLC_PS_ROOT_PORT
      value: 9092
    - name: DMLC_NUM_SERVER
      value: 2
    - name: DMLC_NUM_WORKER
      value: 4
  restartPolicy: Never
```

Different replicas share the same environment variables, which are documented [here](https://mxnet.incubator.apache.org/faq/distributed_training.html#manually-launching-jobs).

## Design

MXNet serves parameter server architecture as TensorFlow does, while it requires a scheduler for service discovery.

## Alternatives Considered

There is an existing implementation [deepinsight/mxnet-operator](https://github.com/deepinsight/mxnet-operator), while it is not maintained well. Besides this, it refers to the architecture of [tf-operator][] in the early stage, which does not follow the best practice in Kubernetes community.

[@gaocegege]: https://github.com/gaocegege
[tf-operator]: https://github.com/kubeflow/tf-operator
