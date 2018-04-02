
## Motivation
As Kubeflow supports more than one framework, there would be use for overarching control plane to help with common machine learning
steps like uploading code or training model. This control plane then could expose API that can be leveraged by various programming languages, CLI,
plugins etc.

## Goals
Create service deployed as part of kubeflow-core that would expose API that then could be consumed by swagger to generate client libs and CLI tool.

## Proposed API

### Model

Model would be main control structure - a model would be collection of different versions of code that would use same monitoring/comparison infrastructure, serving mechanism etc.

```
POST /model - create new model
GET /model - list all models
GET /model/<<name>> - describe model <<name>>
DELETE /model/<<name>> - remove model
```

### Model version

Model version would be one instance of code that we want to train or serve. Model version corresponds to single code blob (revision).

```
POST /model/<<name>>/version/<<version>> - create new model version, version can be numerical autoincrement or named. That also includes saving code blob somewhere or pointing to specific revision in git etc.
GET /model/<<name>>/version - list all available versions of model
GET /model/<<name>>/version/<<version>> - describe model <<version>>
DELETE /model/<<name>>/version/<<version>> - delete model version
```

### Trainer

Trainer is endpoint for running training job for particular model version and given configuration. Each trainer job set will result in saved model checkpoint (or multiple of them) to set storage backend.

```
POST /model/<<name>>/train/<<version>> - create training jobs for particular model version and given config. Returns unique id. Multiple calls creates multiple job sets.
GET /model/<<name>>/train/<<version>> - list all ongoing jobsets for particular version
GET /model/<<name>>/train/<<version>>/<<job_id>> - detailed info of particular jobset
GET /model/<<name>>/train/<<version>>/<<job_id>>/logs - logs of jobs in <<job_id>>
GET /model/<<name>>/train/<<version>>/<<job_id>>/checkpoint - point to saved checkpoints of given model (like S3 url or NAS path).
DELETE /model/<<name>>/train/<<version>>/<<job_id>> - terminate given job
```

### Server

Run inference service for given model version (like tf-serving).

```
POST /model/<<name>>/serve/<<version>> - create server instance for newest checkpoint of given version or specify checkpoint_id.
GET /model/<<name>>/serve/<<version>> - list all servers running for given version
DELETE /model/<<name>>/serve/<<version>>/<<server_id>> - terminate server
```

### Monitor

Monitor is endpoint to spawn monitoring tool instance for given model (like tensorboard) and compare performance of multiple versions.

```
POST /model/<<name>>/monitor - run instance of monitoring tool, including service
GET /model/<<name>>/monitor - get url to monitoring tool service
DELETE /model/<<name>>/monitor - terminage monitoring tool
```

## Design

Central point to all this would be running http server + service that would provide endpoint to API. Spawning this service would be part of ksonnet apply.

* Storage backend will be required - whether it's PV-based or S3, service will need persistent file backend for things like code, logs or trained model checkpoints.
* User would specify backend framework on spawn (multi-backend is tbd). Depending on which backend is chosen, control-service would wrap given framework operator and make decision regarding tooling (like "if tensorflow then monitoring=tensorboard).
* API would be declared in swagger to allow automatic client bindings
* Control-service would use ETCD and other parts of kubernetes infrastructure for internal state persistence.
* We need to decide on language used for control-service. Python or Golang seems to be most obvious choices, and both viable.

## Alternatives Considered

CLI tool can be just a wrapper of kubectl/ks, but that wouldn't have any potential state persistence and made several of use cases impossible.
