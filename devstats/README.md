# Devstats

Instructions for deploying [cncf/devstats]https://github.com/cncf/devstats)


## Deploying on Kubernetes

We currently use

```
PROJECT=devstats
ZONE=us-east1-d
CLUSTER=devstats
NAMESPACE=devstats
```

### Setup the project with deployment manager.

```
gcloud deployment-manager --project=${PROJECT} deployments create devstats --config=devstats.yaml
gcloud deployment-manager --project=${PROJECT} deployments create devstats-gcfs --config=gcfs.yaml
```

This will create the resources

	* GKE Cluster
	* Static IP address for ingress
	* A Cloud NFS file store

```
gcloud --project=${PROJECT} compute addresses list
```

* We use Cloud NFS to store grafana and postgres data. This way its easily accessible on multiple pods

### Create PVC for NVC

* Modify `k8s_manifests/nfs_pvc.yaml`

  * Set IP address to ip address of cloud NFS
  * Set namespace to namespace of your components

### Setup DNS

TODO(https://github.com/kubeflow/community/issues/228): Change host to devstats.kubeflow.org.
We used the name devstats2.kubeflow.org while we setup a new instance running in the devstats project.
Once its up and working we should turn down the existing instance in kubeflow-ci and change the hostname.

```
IPADDRESS=<..address from above...>
HOST=devstats
gcloud --project=kubeflow-dns dns record-sets transaction start -z=kubefloworg
gcloud --project=kubeflow-dns dns record-sets transaction add -z=kubefloworg \
    --name="${HOST}.kubeflow.org." \
   --type=A \
   --ttl=300 "${IPADDRESS}"
gcloud --project=kubeflow-dns dns record-sets transaction execute -z=kubefloworg
```

	* This uses domain kubeflow.org which is managed by Cloud DNS zone kubefloworg


### Create a secret with a GITHUB OAuth token

This token is only for rate quota so it doesn't need access to any services.

kubectl create secret generic github-oauth --from-literal=github-oauth=${GITHUB_TOKEN}


### Create a secret for the Grafana admin password

```
GRAFANA_PASSWORD=`< /dev/urandom tr -dc A-Za-z0-9 | head -c14; echo`
kubectl create secret generic grafana --from-literal=admin_password=${GRAFANA_PASSWORD}
```

If you need the password to login

```
kubectl get secrets grafana -o json | jq -r .data.admin_password | base64 -d  && echo
```

** Important** Once created the password is stored in the database so changing 
the secret won't change the password.


### Setup Devstats config Files

See config/README.md

### Create the K8s resources

```
kubectl apply -f k8s_manifest/nfs_pvc.yaml
kubectl apply -f k8s_manifest/cli_home_pvc.yaml
ks apply devstats2 -c cert-manager
ks apply devstats2 -c devstats
```

* The postgres and grafana containers will likely be crashing because we need to 
  setup the disk.

### How it all works

* Postgres has 3 databases
 
  * **postgres** This database is created by `postgre-docker-entrypoint`
    * I don't think this is used by devstats.
    * psql needs to connect to a database even when psql is being used to create/delete other
      databases. So we connect to the postgres database when executing commands to create/delete
      the **kubeflow** and **devstats** dbs.
  * **kubeflow** This is the DB where devstats data is actually stored.
  * **devstats** This DB is used for logs    

* List of environment variables used by [devstats code](https://github.com/cncf/devstats/blob/23ee872591a77f25c8832e0e46e0289cf22697a0/context.go)


* Grafana dashboards and datasources are defined in YAML files

  * These are stored in source control and checked out into a NFS volume.

### Setup Postgres

1. We use the `devstats-cli-0` container to modify the NFS share; start a shell inside the container
   using the `kubectl` command below and then proceed to run the other steps in the container.


	```
	kubectl exec -ti devstatsdb-0 -c postgres /bin/bash
	```


1. Checkout the various source repositories onto NFS to get the scripts

   ```
   mkdir /mount/data/src
   cd /mount/data/src
   git clone https://github.com/kubeflow/community.git git_kubeflow-community
   ```

1. Run the following script to set permissions on the NFS share

   ```
   /mount/data/src/git_kubeflow-community/devstats/scripts/setup_nfs.sh
   ```

1. Set up the home directory for postgres in the CLI container

   ```
   /mount/data/src/git_kubeflow-community/devstats/scripts/setup_postgres_home.sh
   ```

   * We use a home diretory backed by PD in CLI so we need to do a onetime setup

1. Copy some binaries referenced by the scripts

   ```
   cd /mount/data/src/git_kubeflow-community/devstats/config
   ./copy_devstats_binaries.sh 
   ```

   * TODO(jlewi): We should file a bug to get the devstats scripts updated to just assume the binaries are on the
     path.  I hink if we don't set GHA2DB_LOCAL it will use path.

1. Verify you can connect to the default database

   ```
   psql -U postgres -d postgres -c "SELECT * FROM pg_catalog.pg_tables order by tablename;"
   ```

   * The database postgres is created by the startup script `postgre-docker-entrypoint.sh`
   * The kubeflow database won't exist at this point which is why we test using hte default database

1. Verify you can connect to the database and run queries.

   ```
   sudo -E -u postgres psql -d postgres -U postgres -c "SELECT * FROM pg_catalog.pg_tables order by tablename;"
   ```

   * If this doesn't work there might be a problem with the environment variables telling psql how to connect to the DB
   * If this doesn't succeed most of the commands run by the scripts won't work.

1. Initialize the devstats DB

   ```
   cd /mount/data/src/git_kubeflow-community/devstats/config
   PGUSER=postgres PGDATABASE=postgres PG_PASS=${PG_PASS} PG_PASS_RO=${PG_PASS} PG_PASS_TEAM=kubeflow ./devel/init_database.sh
   ```

   * We need to override `PGUSER` and `PGDATABASE` when running this command because the `kubeflow` database
     doesn't exist it. 

   * So we connect to postgres using the database `postgres` and user `postgres` created by the `postgres` container
     on startup

   * Verify the devstats database exists

   	 ```
   	 psql -U postgres -d postgres -c 'select * from pg_database;'
   	 ```
   
   	 * devstats should be one of the listed databases.

   * The devststats db is used for logs

1. Create the Kubeflow database

   ```
   cd /mount/data/src/git_kubeflow-community/devstats/config
   PGUSER=postgres PGDATABASE=postgres PROJ=kubeflow PROJDB=kubeflow PDB=1 TSDB=1 SKIPTEMP=1 ./devel/create_databases.sh
   ```

   * This step creates the database table and backfills it based on the start date in `projects.yaml`

   * Since the kubeflow database doesn't exist yet we override `PGUSER` and `PGDATABASE` so that we 
     connect to the postgres database in order to create the kubeflow database

   * Verify the **kubeflow** database exists

     ```
     psql -c 'select * from pg_database;'
     ```

     * **kubeflow** should be one of the databases

   * Check the `gha_*` tables were created


   	 ```
   	 psql -d kubeflow -c "SELECT * FROM pg_catalog.pg_tables order by tablename;"
	 schemaname     |               tablename               | tableowner | tablespace | hasindexes | hasrules | hastriggers | rowsecurity 
	 --------------------+---------------------------------------+------------+------------+------------+----------+-------------+-------------
 	 public             | gha_actors                            | gha_admin  |            | t          | f        | f           | f
 	 public             | gha_actors_affiliations               | gha_admin  |            | t          | f        | f           | f
 	 public             | gha_actors_emails                     | gha_admin  |            | t          | f        | f           | f
 	 public             | gha_actors_names                      | gha_admin  |            | t          | f        | f           | f
   	 ...
   	 ```

   * Note that the tables containing metrics won't be created until later when we run `devstats`.

   * `import_affs.sh` crashes see https://github.com/cncf/devstats/issues/166

   	  * This step is related to importing user affiliations to generate company statistics
   	  * For now I just skipped it and ran the next step manually

   	  	```
   	  	GHA2DB_PROJECT=kubeflow PG_DB=kubeflow GHA2DB_LOCAL=1 ./vars 
   	  	```

1. Create tags

   ```
   cd /mount/data/src/git_kubeflow-community/devstats/config
   ./shared/tags.sh 
   ```

1. Run the following to create the annotations

   ```
   cd /mount/data/src/git_kubeflow-community/devstats/config
   ./annotations
   ```

   * This creates the time range selectors based on tags. So we need to run it along with previous step periodically
     to get new tags.

   * Verify that the table `tquick_ranges` now exists.

     ```
     psql -d kubeflow -c "SELECT * FROM pg_catalog.pg_tables where tablename='tquick_ranges';"
     ```

   * TODO(https://github.com/kubeflow/community/issues/230): Do we need to run this regularly?

1. Run devstats 

   ```
   cd /mount/data/src/git_kubeflow-community/devstats/config
   devstats
   ```

   * This should synchronize data and I think create metric and timeseries tables
   * It checks out source for repos so it can get tags
   * It should also be run as a cron job.

1. Known issues

    * Looks like the relation `tcountries` wasn't created and some tables use this see https://github.com/kubeflow/community/issues/231

## Grafana

To access the admin ui port-forward to port `3000` and use the default admin account
which has username admin and password admin.

```
kubectl port-forward service/grafana 3000:3000
```

Dashboards are defined in `devstats/grafana/dashboards/kubeflow/`

These are checked out from git onto the NFS volume mounted on all pods.


### Troublehoosting Postgres

Check the databases using the following query

```
psql -c 'select * from pg_database;'
```

  * Do the DB's **devstats** and **kubeflow** exist?



Check Kubeflow tables exist

```
psql -c -d kubeflow -c  'SELECT * FROM pg_catalog.pg_tables order by tablename;'
```

	* There should be a bunch of tables named `gha_*`


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

```
ks apply ${ENV} -c syncronjob
```

### Example running a query

After the backfill job completes you can run the following to verify data is in the SQL DB.

Run in the devstats-cli-0 container

```
./runq util_sql/top_unknowns.sql {{ago}} '1 month' {{lim}} 10

```

## Miscellaneous

Using psql from the CLI container (although you can also run from the postgre container and then you don't have to do a remote connect)

```
psql -h ${PG_HOST} -U gha_admin -d gha
```

List tables

```
SELECT * FROM pg_catalog.pg_tables order by tablename;
```

A simple query to look at events

```
select created_at, type from gha_events;
```

### Deleting the Kubeflow database

If you want to delete the kubeflow database in the devstats cli pod run

```
psql -d postgres -c "drop database kubeflow"
```

* We need to set -d and change to a database other than kubeflow because we can't delete the current database

