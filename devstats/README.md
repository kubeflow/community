# Devstats

Instructions for deploying [cncf/devstats]https://github.com/cncf/devstats)

## To Setup the database

1. Launch postgres in a container
1. Create the DB

```
PG_PASS=password ./structure
```

	* structure is a go program that is part of cncf/devstats


## Deploying on Kubernetes

We currently use

```
PROJECT=kubeflow-ci
ZONE=us-east1-d
CLUSTER=kubeflow-testing
NAMESPACE=devstats
```

### Create the PDs

This step needs to only run once

```
gcloud --project=${PROJECT} compute disks create --size=200GB --zone=${ZONE} ghadb-data
gcloud --project=${PROJECT} compute disks create --size=200GB --zone=${ZONE} influxdb-data
```

### Create the config map with the projects file

kubectl create -n devstats configmap projects --from-file=./projects.yaml

### Initialize the db

You can execute commands by using `kubectl exec` to start a shell in the devstats-cli stateful set.

```
kubectl exec -ti devstats-cli-0 /bin/bash
cd /go/src/devstats
./structure
```
	* The above commands should be executed from within the pod.


Initialize influx

```
DB_NAME=kubeflow
./grafana/influxdb_setup.sh ${DB_NAME}
```

### Loading data into the db

Use the gha2db program that is part of cncf/devstats

```
./gha2db 2018-04-16 00 2018-04-17 00 kubeflow
```

	* Change the date range to the range you want

### Example running a query

Run in the devstats-cli-0 container

```
./runq util_sql/top_unknowns.sql {{ago}} '1 month' {{lim}} 10
```

### Current status

Running `devstats` in the devstats-cli container to sync the data currently produces the following error.

```
Error(time=2018-04-18 18:39:01.274140856 +0000 UTC):
Error: 'pq: database "devstats" does not exist'
```