_Authors:_

* [Ce Gao(@gaocegege)](https://github.com/gaocegege) - Tencent
* [Jiaxin Shan(@jeffwan)](https://github.com/jeffwan) - Bytedance
* [Wang Zhang(@zw0610)](https://github.com/zw0610) - Tencent

_Status_

- 2021-08-16 Draft v1

## Abstract

[TorchElastic](https://pytorch.org/docs/1.9.0/distributed.elastic.html), which was open-sourced over a year ago in the [pytorch/elastic](https://github.com/pytorch/elastic) GitHub repository, is a runner and coordinator for PyTorch worker processes. it has been part of PyTorch core since 1.9.0. This proposal is to support such a feature with the help of PyTorchJob. 

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

The command needs to be run on every pod. The training job will start When at least `MIN_SIZE` nodes have joined. The command runs a local elastic agent on the node, which is used to launch and manage underlying worker processes. The agent on the node assigns `RANK`, `LOCAL_RANK` and so on for every worker.

## Goals

A Kubeflow user should be able to run elastic training using PyTorch. This proposal is centered around a Kubernetes operator for PyTorch. A user should be able to run both single node and distributed elastic training jobs with PyTorch.

Besides this, users should be able to run non-elastic training jobs as before.

## Design and Implementation

We introduce the design and implementation based on [kubeflow training-operator](https://github.com/kubeflow/training-operator).

## API/CRD

```diff
// PyTorchJobSpec is a desired state description of the PyTorchJob.
type PyTorchJobSpec struct {
	// RunPolicy encapsulates various runtime policies of the distributed training
	// job, for example how to clean up resources and how long the job can stay
	// active.
	//+kubebuilder:validation:Optional
	RunPolicy common.RunPolicy `json:"runPolicy"`

+	ElasticPolicy *ElasticPolicy `json:"elasticPolicy,omitempty"`

	// A map of PyTorchReplicaType (type) to ReplicaSpec (value). Specifies the PyTorch cluster configuration.
	// For example,
	//   {
	//     "Master": PyTorchReplicaSpec,
	//     "Worker": PyTorchReplicaSpec,
	//   }
	PyTorchReplicaSpecs map[common.ReplicaType]*common.ReplicaSpec `json:"pytorchReplicaSpecs"`
}

+ type ElasticPolicy struct {
+	Backend  *RDZVBackend `json:"backend,omitempty"`
+	RDZVPort *int32       `json:"rdzvPort,omitempty"`
+	RDZVHost *string      `json:"rdzvHost,omitempty"`
+	RDZVID   *string      `json:"rdzvId,omitempty"`
+	// RDZVConf contains additional rendezvous configuration (<key1>=<value1>,<key2>=<value2>,...).
+	RDZVConf []RDZVConf `json:"rdzvConf,omitempty"`
+	// Start a local standalone rendezvous backend that is represented by a C10d TCP store
+	// on port 29400. Useful when launching single-node, multi-worker job. If specified
+	// --rdzv_backend, --rdzv_endpoint, --rdzv_id are auto-assigned; any explicitly set values
+	// are ignored.
+	Standalone *bool `json:"standalone,omitempty"`
+	// Number of workers per node; supported values: [auto, cpu, gpu, int].
+	NProcPerNode *int32 `json:"nProcPerNode,omitempty"`
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
+	// can scale down.  It defaults to null.
+	// +optional
+	MinReplicas *int32 `json:"minReplicas,omitempty"`
+	// upper limit for the number of pods that can be set by the autoscaler; cannot be smaller than MinReplicas, defaults to null.
+	// +optional
+	MaxReplicas *int32 `json:"maxReplicas,omitempty"`
}

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

Two fields are added in `common.ReplicaSpec`: `minReplicas` and `maxReplicas`. They act as MIN_SIZE and MAX_SIZE in the elastic example above.

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
      maxReplicas: 5
      restartPolicy: OnFailure 
      template:
        spec:
          containers: 
            - name: pytorch
              image: <image>
			  envs:
			  - name: PET_RDZV_BACKEND
			  	value: c10d
			  - name: PET_RDZV_ENDPOINT
			  	value: <rdzv_endpoint>
			  - name: PET_NNODES
			    value: 3:5
			  - name: PET_NPROC_PER_NODE
	  			value: "1"
              command: "python -m torch.distributed.run xxx.py"
```

## Operator

### Environment Variables

`SetPodEnv` in `pkg/controller.v1/pytorch/pytorch.go` should be changed. There is no need to set `RANK`, `WORLD_SIZE`, `MASTER_ADDR`, `MASTER_PORT` if TorchElastic is used.

`PET_RDZV_ENDPOINT` will be set to `<name>-worker-0:29500`. `PET_NNODES` will be set to `${pytorchjob.spec.replicas[worker].minReplicas}:${pytorchjob.spec.replicas[worker].maxReplicas}`.

### Ports

One built-in port named `kubeflow-rdzv-port` is introduced for `rendezvous`.

### Reconciliation

`JobController.ReconcilePods` should be refactored. Now the pods are returned by `GetPodSlices`. For example, if `spec.Replicas` is 3, the PodSlices may look like: `[[0],[1],[2]]`. It is not expected when elastic training is enabled.

```go
// ReconcilePods checks and updates pods for each given ReplicaSpec.
// It will requeue the job in case of an error while creating/deleting pods.
func (jc *JobController) ReconcilePods(
	job interface{},
	jobStatus *apiv1.JobStatus,
	pods []*v1.Pod,
	rtype apiv1.ReplicaType,
	spec *apiv1.ReplicaSpec,
	replicas map[apiv1.ReplicaType]*apiv1.ReplicaSpec) error {
  ...
	numReplicas := int(*spec.Replicas)
	var masterRole bool
  ...
	podSlices := jc.GetPodSlices(pods, numReplicas, logger)
	for index, podSlice := range podSlices {
		if len(podSlice) > 1 {
			logger.Warningf("We have too many pods for %s %d", rt, index)
		} else if len(podSlice) == 0 {
			logger.Infof("Need to create new pod: %s-%d", rt, index)
      ...
		} else {
			...
		}
	}
	return nil
}
```

### Resulting Spec

The resulting worker looks like this:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ${pytorchjob.metadata.name}-worker-0
spec:
  containers:
  - image: xxx
    name: worker
    env:
    - name: MASTER_PORT
      value: "23456"
	- name: PET_RDZV_BACKEND
	  value: c10d
    - name: PET_RDZV_ENDPOINT
      value: ${pytorchjob.metadata.name}-worker-0:29500
    - name: PET_NNODES
      value: "${pytorchjob.spec.replicas[worker].minReplicas}:${pytorchjob.spec.replicas[worker].maxReplicas}"
	- name: PET_NPROC_PER_NODE
	  value: "1"
    command: "python -m torch.distributed.run xxx.py"
    ports:       
    # KUBEFLOW_RDZV_PORT is set to 29500 by default in TorchElastic.                
    - containerPort: 29500
      name: kubeflow-rdzv-port
      protocol: TCP

```

## Limatations

- KUBEFLOW_RDZV_PORT will be open for every pod even though workers except worker-0 do not use it.

## Alternatives Considered

### API/CRD

[TorchElastic operator](https://github.com/pytorch/elastic/blob/master/kubernetes/api/v1alpha1/elasticjob_types.go) implemented by @jeffwan puts the new fields under `PyTorchJobSpec`.

Personally, prefer keeping it in `common.ReplicaSpec` since other Jobs may also need it.

```diff
// PyTorchJobSpec is a desired state description of the PyTorchJob.
type PyTorchJobSpec struct {
	// RunPolicy encapsulates various runtime policies of the distributed training
	// job, for example how to clean up resources and how long the job can stay
	// active.
	//+kubebuilder:validation:Optional
	RunPolicy common.RunPolicy `json:"runPolicy"`

+	// minReplicas is the lower limit for the number of replicas to which the training job
+	// can scale down.  It defaults to nil.
+	// +optional
+	MinReplicas *int32 `json:"minReplicas,omitempty"`
+	// upper limit for the number of pods that can be set by the autoscaler; cannot be smaller than MinReplicas, defaults to nil.
+	// +optional
+	MaxReplicas *int32 `json:"maxReplicas,omitempty"`

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
	Replicas *int32 `json:"replicas,omitempty"`

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

### Autoscaler Integration

Three fields should be added in CustomResourceDefinition:

```yaml
    scale:
      specReplicasPath: .spec.pytorchReplicaSpecs.Worker.replicas
      # Should we have a total replicas?
      statusReplicasPath: .status.replicaStatuses.Active
      labelSelectorPath: .status.labelSelector
```

`LabelSelector` should be introduced into `common.ReplicaStatus`.

```diff
type ReplicaStatus struct {
+	// LabelSelector is the selector for the replica.
+	LabelSelector *metav1.LabelSelector `json:"labelSelector,omitempty"`

	// The number of actively running pods.
	Active int32 `json:"active,omitempty"`

	// The number of pods which reached phase Succeeded.
	Succeeded int32 `json:"succeeded,omitempty"`
	// The number of pods which reached phase Failed.
	Failed int32 `json:"failed,omitempty"`
}
```

Then `PyTorchJob` has the `scale` subResource, then it can work with Autoscaler. The only problem is that `PyTorchJob` already has the minReplicas and maxReplicas fields. They are used to generate commands. The Autoscaler resource needs them, too. Thus users may need to define them again.
 
## Comments

- [ ] Add custom port support
- [ ] Consider if we should add backend related fields in CRD def
- [ ] Add scope in the doc
- [ ] Consider how to support target deletion
- [ ] Consider if we should deal with worker 0 differently
- [ ] Add more details about reconsilation