_Authors:_

* [Ce Gao(@gaocegege)](https://github.com/gaocegege) - Tencent
* [Jiaxin Shan(@jeffwan)](https://github.com/jeffwan) - Bytedance
* [Wang Zhang(@zw0610)](https://github.com/zw0610) - Tencent

_Status_

- 2021-08-16 Draft v1

## Abstract

[TorchElastic](https://pytorch.org/docs/1.9.0/distributed.elastic.html), which was open-sourced over a year ago in the [pytorch/elastic](https://github.com/pytorch/elastic) GitHub repository, is a runner and coordinator for PyTorch worker processes. It has been part of PyTorch core since 1.9.0. This proposal is to support such a feature with the help of PyTorchJob. 

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
+	// minReplicas is the lower limit for the number of replicas to which the training job
+	// can scale down.  It defaults to null.
+	// +optional
+	MinReplicas *int32 `json:"minReplicas,omitempty"`
+	// upper limit for the number of pods that can be set by the autoscaler; cannot be smaller than MinReplicas, defaults to null.
+	// +optional
+	MaxReplicas *int32 `json:"maxReplicas,omitempty"`
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
```

`minReplicas` and `maxReplicas` are used to generate `-nnodes` cpnfiguration when `ElasticPolicy` is specified.


>  --nnodes NNODES       Number of nodes, or the range of nodes in form <minimum_nodes>:<maximum_nodes>.

## Command

```yaml
apiVersion: "kubeflow.org/v1"
kind: PyTorchJob
metadata:
  name: elastic-example-imagenet
spec:
  elasticPolicy:
    rdzvBackend: c10d
    minReplicas: 1
    maxReplicas: 2
    maxRestarts: 100
  pytorchReplicaSpecs:
    Worker:
      replicas: 2
      restartPolicy: OnFailure
      template:
        spec:
          containers:
            - name: pytorch
              image: gaocegege/pytorch-elastic-example-imagenet:1.0.0-sigterm
              imagePullPolicy: IfNotPresent
              env:
              - name: LOGLEVEL
                value: DEBUG
              command:
                - python
                - -m
                - torch.distributed.run
                - /workspace/examples/imagenet.py
                - "/workspace/data/tiny-imagenet-200"
```

## Operator

### Environment Variables

`SetPodEnv` in `pkg/controller.v1/pytorch/pytorch.go` should be changed. There is no need to set `RANK`, `WORLD_SIZE`, `MASTER_ADDR`, `MASTER_PORT` if TorchElastic is used.

```go
const (
	// Rendezvous related arguments

	// EnvRDZVBackend is the environment variable name for the rdzv backend.
	EnvRDZVBackend = "PET_RDZV_BACKEND"
	// EnvRDZVID is the environment variable name for the rdzv id.
	EnvRDZVID = "PET_RDZV_ID"
	// ENVRDZVConf is the environment variable name for the rdzv conf.
	EnvRDZVConf = "PET_RDZV_CONF"
	// EnvRDZVEndpoint is the environment variable name for the rdzv endpoint.
	EnvRDZVEndpoint = "PET_RDZV_ENDPOINT"
	// EnvRDZVStandalone is the environment variable name for the standalone mode.
	EnvStandalone = "PET_STANDALONE"

	// User-code launch related arguments.

	// EnvMaxRestarts is the environment variable name for the maximum number of worker group restarts before failing.
	EnvMaxRestarts = "PET_MAX_RESTARTS"
	// EnvMonitorInterval is the environment variable name for the interval, in seconds, to monitor the state of workers.
	EnvMonitorInterval = "PET_MONITOR_INTERVAL"
	// EnvStartMethod is the environment variable name for the multiprocessing start method to use when creating workers, which could be fork, spawn and forkserver.
	EnvStartMethod = "PET_START_METHOD"

	// Worker/node size related arguments.

	// EnvNProcPerNode is the environment variable name for the number of processes per node.
	EnvNProcPerNode = "PET_N_PROC_PER_NODE"
	// EnvNNodes is the environment variable name for the number of nodes.
	EnvNNodes = "PET_NNODES"
)
```

These variables should be set according to the `ElasticPolicy` in the `PyTorchJobSpec`.

The logic of `SetPodEnv` is as follows:

```go
func SetPodEnv(obj interface{}, podTemplateSpec *corev1.PodTemplateSpec, rtype, index string) error {
	pytorchjob, ok := obj.(*pytorchv1.PyTorchJob)
	if !ok {
		return fmt.Errorf("%+v is not a type of PyTorchJob", obj)
	}

	for i := range podTemplateSpec.Spec.Containers {
		if len(podTemplateSpec.Spec.Containers[i].Env) == 0 {
			podTemplateSpec.Spec.Containers[i].Env = make([]corev1.EnvVar, 0)
		}
		podTemplateSpec.Spec.Containers[i].Env = append(podTemplateSpec.Spec.Containers[i].Env, corev1.EnvVar{
			Name:  "PYTHONUNBUFFERED",
			Value: "0",
		})

		envVars, err := GetMasterEnvVarGenerator().Generate(pytorchjob)
		if err != nil {
			return err
		}
		// Set elastic related environment variables.
		podTemplateSpec.Spec.Containers[i].Env = append(
			podTemplateSpec.Spec.Containers[i].Env, envVars...)

		envVars, err = GetElasticEnvVarGenerator().Generate(pytorchjob)
		if err != nil {
			return err
		}
		// Set elastic related environment variables.
		podTemplateSpec.Spec.Containers[i].Env = append(
			podTemplateSpec.Spec.Containers[i].Env, envVars...)
	}

	return nil
}
func (e ElasticEnvVarGenerator) Generate(
	job *pytorchv1.PyTorchJob) ([]corev1.EnvVar, error) {
	envVars := []corev1.EnvVar{}

	elasticPolicy := job.Spec.ElasticPolicy
	if elasticPolicy == nil {
		// Return empty env vars.
		return nil, nil
	}

	// Generate RDZV_ENDPOINT.
	if envVar, err := e.generateEnvRDZVEndpoint(job); err != nil {
		return nil, err
	} else {
		envVars = append(envVars, *envVar)
	}
	// Generate RDZV_BACKEND.
	envVars = append(envVars, e.generateEnvBackend(elasticPolicy))
	// Generate NNODES.
	if envVar, err := e.generateEnvNNodes(job); err != nil {
		return nil, err
	} else {
		envVars = append(envVars, *envVar)
	}

	if elasticPolicy.MaxRestarts != nil {
		envVars = append(envVars, corev1.EnvVar{
			Name:  EnvMaxRestarts,
			Value: strconv.Itoa(int(*elasticPolicy.MaxRestarts)),
		})
	}
	if elasticPolicy.NProcPerNode != nil {
		envVars = append(envVars, corev1.EnvVar{
			Name:  EnvNProcPerNode,
			Value: strconv.Itoa(int(*elasticPolicy.NProcPerNode)),
		})
	}
	if elasticPolicy.RDZVID != nil {
		envVars = append(envVars, corev1.EnvVar{
			Name:  EnvRDZVID,
			Value: *elasticPolicy.RDZVID,
		})
	}
	if envVar := e.generateEnvRDZVConf(elasticPolicy); envVar != nil {
		envVars = append(envVars, *envVar)
	}
	if elasticPolicy.Standalone != nil && *elasticPolicy.Standalone {
		envVars = append(envVars, corev1.EnvVar{
			Name:  EnvStandalone,
			Value: "",
		})
	}

	return envVars, nil
}

func (e ElasticEnvVarGenerator) generateEnvNNodes(job *pytorchv1.PyTorchJob) (*corev1.EnvVar, error) {
	// Return worker.replicas if there is no max and min replicas specified.
	if job.Spec.ElasticPolicy.MinReplicas == nil &&
		job.Spec.ElasticPolicy.MaxReplicas == nil {
		if job.Spec.PyTorchReplicaSpecs[pytorchv1.PyTorchReplicaTypeWorker] == nil {
			return nil, fmt.Errorf("cannot find the worker spec")
		}
		return &corev1.EnvVar{
			Name: EnvNNodes,
			Value: strconv.Itoa(
				int(*job.Spec.PyTorchReplicaSpecs[pytorchv1.PyTorchReplicaTypeWorker].
					Replicas)),
		}, nil
	}

	return &corev1.EnvVar{
		Name: EnvNNodes,
		Value: fmt.Sprintf("%d:%d",
			*job.Spec.ElasticPolicy.MinReplicas, *job.Spec.ElasticPolicy.MaxReplicas),
	}, nil
}

func (e ElasticEnvVarGenerator) generateEnvRDZVEndpoint(job *pytorchv1.PyTorchJob) (*corev1.EnvVar, error) {
	var err error
	host := ""
	if job.Spec.ElasticPolicy.RDZVHost == nil {
		host = fmt.Sprintf("%s-worker-0", job.Name)
	} else {
		host = *job.Spec.ElasticPolicy.RDZVHost
	}

	port := defaultRDZVPort
	if job.Spec.ElasticPolicy.RDZVPort == nil {
		// Generate RDZV_Endpoint.
		port, err = getPortFromPyTorchJob(job, pytorchv1.PyTorchReplicaTypeWorker)
		if err != nil {
			return nil, err
		}
	} else {
		port = *job.Spec.ElasticPolicy.RDZVPort
	}
	return &corev1.EnvVar{
		Name:  EnvRDZVEndpoint,
		Value: fmt.Sprintf("%s:%d", host, port),
	}, nil
}

func (e ElasticEnvVarGenerator) generateEnvRDZVConf(elasticPolicy *pytorchv1.ElasticPolicy) *corev1.EnvVar {
	if elasticPolicy.RDZVConf == nil {
		return nil
	}
	val := ""
	for _, conf := range elasticPolicy.RDZVConf {
		val += fmt.Sprintf("%s=%s,", conf.Key, conf.Value)
	}
	return &corev1.EnvVar{
		Name: EnvRDZVConf,
		// Remove the last comma.
		Value: val[:len(val)-1],
	}
}

func (e ElasticEnvVarGenerator) generateEnvBackend(elasticPolicy *pytorchv1.ElasticPolicy) corev1.EnvVar {
	if elasticPolicy.RDZVBackend != nil {
		return corev1.EnvVar{
			Name:  EnvRDZVBackend,
			Value: string(*elasticPolicy.RDZVBackend),
		}
	}
	return corev1.EnvVar{
		Name:  EnvRDZVBackend,
		Value: string(pytorchv1.BackendC10D),
	}
}
```

### Ports

The worker spec can have the following ports:

- pytorchjob-port: The port for the rdzv port (if needed).

### Resulting Spec

The resulting worker pod looks like this:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ${pytorchjob.metadata.name}-worker-1
spec:
  containers:
  - command:
    - python
    - -m
    - torch.distributed.run
    - /workspace/examples/imagenet.py
    - --arch=resnet18
    - --epochs=20
    - --batch-size=32
    - --workers=0
    - /workspace/data/tiny-imagenet-200
    env:
    - name: LOGLEVEL
      value: DEBUG
    - name: PYTHONUNBUFFERED
      value: "0"
    - name: PET_RDZV_ENDPOINT
      value: elastic-example-imagenet-worker-0:29400
    - name: PET_RDZV_BACKEND
      value: c10d
    - name: PET_NODES
      value: "1:2"
    - name: PET_MAX_RESTARTS
      value: "100"
    image: gaocegege/pytorch-elastic-example-imagenet:1.0.0-sigterm
    imagePullPolicy: IfNotPresent
    name: pytorch
    ports:
    - containerPort: 29400
      name: pytorchjob-port
      protocol: TCP

```

## Autoscaler Integration

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

## Limatations

- pytorchjob-port will be open for every pod even though workers except worker-0 do not use it.
- Does not support target deletion currently
