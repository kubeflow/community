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
gcloud --project=${PROJECT} compute disks create --size=200GB --zone=${ZONE} influxdb-data
gcloud --project=${PROJECT} compute disks create --size=400GB --zone=${ZONE} devstatsdb-data
gcloud --project=${PROJECT} compute disks create --size=400GB --zone=${ZONE} grafana-data
```

### Create a secret with a GITHUB OAuth token

This token is only for rate quota so it doesn't need access to any services.

kubectl create secret generic github-oauth --from-literal=github-oauth=${GITHUB_TOKEN}


### Initialize the db

The postgres container wasn't able to create the directory in `/var/lib/postgresql/data`
which is where the PD is mounted because the permissions were scoped to root
but we run postgres as user postgres. 

I worked around this by starting a shell in the cli container in the devstatsdb-0 pod
and making `/var/lib/postgresql/data` world writable.

To finish setting up the database we need to run some of the devstats SQL scripts and commands.

Start a shell in the postgre container


```
kubectl exec -ti devstatsdb-0 -c postgres /bin/bash
```
Then follow [step 7 in install instructions](https://github.com/cncf/devstats/blob/master/INSTALL_UBUNTU17.md).


Create the db structure

```
kubectl exec -ti devstats-cli-0 /bin/bash
cd /go/src/devstats
./structure
```
	* The above commands should be executed from within the pod.


To setup influx.

```
DB_NAME=kubeflow
./grafana/influxdb_setup.sh ${DB_NAME}
```

### Connecting to postgres

```
psql -h ${PG_HOST} -W ${PG_PASSWORD} -U gha_admin -d gha
```

### Loading data into the db

Use the gha2db program that is part of cncf/devstats

If we run devstats regularly that will syncronize the latest changes.
To backfill some range you can run gha2b directly

```
./gha2db 2018-04-16 00 2018-04-17 00 kubeflow
```

	* Change the date range to the range you want

You can run this on K8s as a job by doing

```
ks param set backfill end_day 2018-01-01
ks param set backfill end_day 2018-04-17
ks apply default -c backfill
```

### Sync data

We use a cron job to run `devstats` regularly to pull in the latest data.

### Example running a query

Run in the devstats-cli-0 container

```
./runq util_sql/top_unknowns.sql {{ago}} '1 month' {{lim}} 10

```

## Grafana

To access the admin ui port-forward to port `3000` and use the default admin account
which has username admin and password admin.

```
kubectl port-forward `kubectl get pods --selector=app=grafana -o jsonpath='{.items[0].metadata.name}'` 3000:3000
```

###

Dashboards are defined inside the directory 

```
components/grafana/dashboards
```

These are loaded into a configmap and provided to the grafana 
instance.


## Miscellaneous

Using psql from the CLI container (although you can also run from the postgre container and then you don't have to do a remote connect)

```
psql -h ${PG_HOST} -W ${PG_PASSWORD} -U gha_admin -d gha
```

List tables

```
SELECT * FROM pg_catalog.pg_tables order by tablename;
```

A simple query to look at events

```
select created_at, type from gha_events;
```

## Using Influx DB

To connect from influxdb pod

```
influx -precision rfc3339 -host ${IDB_HOST} -username gha_admin -password ${IDB_PASS} -database ${IDB_DB} 
```

To see a list of time series
```
show series
```

To select data

```
select * from new_prs_all_d3
```
