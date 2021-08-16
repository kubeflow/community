_Authors:_

* [Ce Gao(@gaocegege)](https://github.com/gaocegege)

_Status_

- 2021-08-16 Draft v1

## Abstract

[TorchElastic](https://pytorch.org/docs/1.9.0/distributed.elastic.html), which was open sourced over a year ago in the pytorch/elastic github repository, is a runner and coordinator for PyTorch worker processes. it has been part of PyTorch core since 1.9.0. This proposal is to support such feature with the help of PyTorchJob. 

## Background

### TorchElastic Design

TorchElastic provides the approach that makes distributed PyTorch fault-tolerant and elastic.

To launch a fault-tolerant job, run the following on all nodes:

```python
python -m torch.distributed.run
        --nnodes=NUM_NODES
        --nproc_per_node=TRAINERS_PER_NODE
        --rdzv_id=JOB_ID
        --rdzv_backend=c10d
        --rdzv_endpoint=HOST_NODE_ADDR
        YOUR_TRAINING_SCRIPT.py (--arg1 ... train script args...)
```

To launch an elastic job, run the following on at least MIN_SIZE nodes and at most MAX_SIZE nodes.

```python
python -m torch.distributed.run
        --nnodes=MIN_SIZE:MAX_SIZE
        --nproc_per_node=TRAINERS_PER_NODE
        --rdzv_id=JOB_ID
        --rdzv_backend=c10d
        --rdzv_endpoint=HOST_NODE_ADDR
        YOUR_TRAINING_SCRIPT.py (--arg1 ... train script args...)
```

The command needs to be run on every node. The training job will start When at least min total number of nodes have joined. The command runs a local elastic agent on the node, which is used to launch and manage underlying worker processes. The agent on the node assigns `RANK`, `LOCAL_RANK` and so on for every worker.

## Goals

A Kubeflow user should be able to run elastic training using PyTorch. This proposal is centered around a Kubernetes operator for PyTorch. A user should be able to run both single node and distributed elastic training jobs with PyTorch.

Besides this, users should be able to run non-elastic training jobs as before.

## Design and Implementation

We introduce the design and implentation based on all-in-one operator.

## API/CRD

```diff
// PyTorchJobSpec is a desired state description of the PyTorchJob.
type PyTorchJobSpec struct {
	// RunPolicy encapsulates various runtime policies of the distributed training
	// job, for example how to clean up resources and how long the job can stay
	// active.
	//+kubebuilder:validation:Optional
	RunPolicy common.RunPolicy `json:"runPolicy"`

	// A map of PyTorchReplicaType (type) to ReplicaSpec (value). Specifies the PyTorch cluster configuration.
	// For example,
	//   {
	//     "Master": PyTorchReplicaSpec,
	//     "Worker": PyTorchReplicaSpec,
	//   }
	PyTorchReplicaSpecs map[common.ReplicaType]*common.ReplicaSpec `json:"pytorchReplicaSpecs"`
}

// +k8s:openapi-gen=true
// +k8s:deepcopy-gen=true
// ReplicaSpec is a description of the replica
type ReplicaSpec struct {
	// Replicas is the desired number of replicas of the given template.
	// If unspecified, defaults to 1.
+	// +optional
	Replicas *int32 `json:"replicas,omitempty"`

+	// minReplicas is the lower limit for the number of replicas to which the training job
+	// can scale down.  It defaults to nil.
+	// +optional
+	MinReplicas *int32 `json:"minReplicas,omitempty"`
+	// upper limit for the number of pods that can be set by the autoscaler; cannot be smaller than MinReplicas, defaults to nil.
+	// +optional
+	MaxReplicas *int32 `json:"maxReplicas,omitempty"`

	// Template is the object that describes the pod that
	// will be created for this replica. RestartPolicy in PodTemplateSpec
	// will be overide by RestartPolicy in ReplicaSpec
	Template v1.PodTemplateSpec `json:"template,omitempty"`

	// Restart policy for all replicas within the job.
	// One of Always, OnFailure, Never and ExitCode.
	// Default to Never.
	RestartPolicy RestartPolicy `json:"restartPolicy,omitempty"`
}
```

Two fields are added in `common.ReplicaSpec`: `minReplicas` and `maxReplicas`. They acts as MIN_SIZE and MAX_SIZE in the elastic example above.

## Command

```yaml
apiVersion: "kubeflow.org/v1"
kind: "PyTorchJob"
metadata:
  name: "pytorch-dist-mnist"
spec:
  pytorchReplicaSpecs:
    # There is no master in elastic training jobs.
    Worker:
      minReplicas: 3
      MaxReplicas: 5
      restartPolicy: OnFailure 
      template:
        spec:
          containers: 
            - name: pytorch
              image: <image>
              command: "python -m torch.distributed.run --rdzv_backend=c10d --rdzv_endpoint=$KUBEFLOW_RDZV_HOST:$KUBEFLOW_RDZV_PORT --nnodes=$KUBEFLOW_MIN_SIZE:$KUBEFLOW_MAX_SIZE --nproc_per_node=1 xxx.py"
```

There are four environment variables here: `KUBEFLOW_RDZV_HOST`, `KUBEFLOW_RDZV_PORT`, `KUBEFLOW_MIN_SIZE` and `KUBEFLOW_MAX_SIZE`.

## Alternatives Considered
One alternative considered for the CRD spec is shown below:
```yaml
apiVersion: "kubeflow.org/v1alpha1"
kind: "PyTorchJob"
metadata:
  name: "example-job"
spec:
  backend: "gloo"
  masterPort: "23456"
  worldSize: 3
  container:
  - image: pytorch/pytorch:latest
```
The idea was the number of replicas for worker and masters could be derived from the `worldSize` given there would only be one master. It was decided against based on the fact that it deviates from a regular replicaSpec and provides less customization.
