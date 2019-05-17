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

### Company Affilitations

We need to create a json file containing company affiliations for each user in order to get company stats.

These instructions are based on [sync.md](https://github.com/cncf/gitdm/blob/master/SYNC.md)

All commands should be run in the `devstats-cli-0` pod.

1. Make sure the repos are checked out on NFS

   * Directory is set in ${GHA2DB_REPOS_DIR}

   * To manually update

     ```
     cd /mount/data/src/git_kubeflow-community/devstats/config
	 GHA2DB_PROCESS_REPOS=1 ./get_repos
     ```

1. Generate a list of all repos and the command to generate the repo log

   ```
    cd /mount/data/src/git_kubeflow-community/devstats/config
	GHA2DB_PROCESS_REPOS=1 GHA2DB_EXTERNAL_INFO=1 ./get_repos
   ```

1. Update `/mount/data/src/git_cncf-gitdm/src/repos.txt` with the list of repos outputted by the previous command

1. Setup gitdm

   ```
   cd /mount/data/src/git_cncf-gitdm/src
   gem install pry
   gem install octokit
   ```

   * TODO(jlewi): Should we do gem install in the image?

1. Generate a git log.

   ```
   ./all_repos_log.sh /mount/data/devstats_repos/kubeflow/*
   ```

   * This should create a git log `/mount/data/src/git_cncf-gitdm/src/git.log`

 1. To run cncf/gitdm on a generated git.log file do: 

    ```
 	cd /mount/data/src/git_cncf-gitdm/src 
 	./cncfdm.py -i git.log -r "^vendor/|/vendor/|^Godeps/" -R -n -b ./ -t -z -d -D -A -U -u -o all.txt -x all.csv -a all_affs.csv > all.out 	
    ```
 1. Generate actors

    ```
    cd /mount/data/src/git_kubeflow-community/devstats
    bash -x ./scripts/generate_actors.sh /mount/data/src/git_cncf-gitdm/src/actors.txt 
    ```

    * TODO(jlewi): Should we store the actors file someplace other than git_cncf-gitdm? We currently put it there
      because all the gitdm scripts make assumptions about the locations of the files

 
 1. Create a secret containing 

    * A GitHub OAuth API token
      * Can use the same token as before
    * A GitHub OAuth client secret
    * A GitHub client id

    ```
    kubectl create secret generic gitdm-github-oauth --from-literal=oauth=${GITDM_GITHUB_OAUTH_TOKEN} --from-literal=client_id=${GITDM_GITHUB_CLIENT_ID}  --from-literal=client_secret=${GITDM_GITHUB_CLIENT_SECRET}
    ```
 1. Pull GitHub users

    ```   
    cd /mount/data/src/git_cncf-gitdm/src/
    echo [] > github_users.json
    ruby ghusers.rb
	./encode_emails.rb github_users.json temp
	mv temp github_users.json
    ```
    * Ensure repos.txt doesn't include any repos that shouldn't count as contributors
    	* In particular ensure [kubeflow/homebrew-cask](https://github.com/kubeflow/homebrew-cask) and 
    	  [homebrew-core](https://github.com/kubeflow/homebrew-core) are excluded
    * TODO(jlewi): I'm not sure we want to zero out github_users.json on each successive run
    	* I think we only wanted to do that once because github_users.json was originally for the CNCF projects
    	* ghusers.rb has to make API requests for each user so if we don't cache results we hit API limits.
    * ghusers.rb appears to crash if github_users.json doesn't exist and doesn't have at least a json list
 	* See also these [instructions](https://github.com/cncf/gitdm/blob/master/README.md#github-users-can-be-pulled-using-octokit-gihub-api)

 	* The processing of repos.txt is very brittle
 	  * I had to modify the code ala Ran into https://github.com/cncf/gitdm/issues/104 
 	  * I also had to remove the quotes around the repo names

 	* TODO(jlewi): Could we just use ghusesrs.sh? The reason I didn't was because it didn't seem to handle things
 	  like the file github_users.json not existing

 1.  Update github_users.json

     ```
     cd /mount/data/src/git_cncf-gitdm/src/
     ./enhance_json.sh
     ```

     * Output is
       ```

	  Found 1, not found 420 from 425 additional actors
      Processed 425 users, enchanced: 306, not found in CSV: 4, unknowns not found in JSON: 13614.
      ```

     * I think this script sets affiliation field in `github_users.json`

     * Check in `github_users.json` to `kubeflow/community/devststats/data`
       * This makes it easy for people to check their affiliation.

1. See https://github.com/cncf/gitdm/blob/master/SYNC.md; there are a whole bunhch of steps that seem like they might be semi optional

   * TODO(jlewi): We should create a script or something to run all the steps.

1. Import affiliations

   ```
   cd /mount/data/src/git_kubeflow-community/devstats/config
   ./import_affs /mount/data/src/git_cncf-gitdm/src/github_users.json 
	2019-02-20 21:40:30 kubeflow/import_affs: Processing non-empty: 566 names, 707 emails lists and 116 affiliations lists
	2019-02-20 21:40:30 kubeflow/import_affs: Empty/Not found: names: 142, emails: 0, affiliations: 612
	2019-02-20 21:40:32 kubeflow/import_affs: 566 non-empty names, added actors: 0, updated actors: 314
	2019-02-20 21:40:34 kubeflow/import_affs: 707 emails lists, added actors: 0, all emails: 735
	2019-02-20 21:40:35 kubeflow/import_affs: 566 names lists, all names: 566
	2019-02-20 21:40:35 kubeflow/import_affs: 116 affiliations, unique: 112, non-unique: 4, all user-company connections: 153
	2019-02-20 21:40:35 kubeflow/import_affs: Processed 64 companies
	2019-02-20 21:40:36 kubeflow/import_affs: Processed 153 affiliations, added 0 actors, cache hit: 153, miss: 0
	2019-02-20 21:40:36 kubeflow/import_affs: Non-acquired companies: checked all regexp: 64, cache hit: 153
	2019-02-20 21:40:36 kubeflow/import_affs: Time: 5.621040111s
   ```

   * Verify there are companies

     ```
     psql -c "select * from gha_companies;"
     ```

1. If affiliations are changed on a deployed setup, run

    ```
    cd /mount/data/src/git_kubeflow-community/devstats/config
    ./shared/reinit.sh
    ```
    This will regenerate the precomputed data for grafana without altering GH tables data.    

1. TODO: Do we need to run devstats to compute various metrics?

### Deleting the Kubeflow database

If you want to delete the kubeflow database in the devstats cli pod run

```
psql -d postgres -c "drop database kubeflow"
```

* We need to set -d and change to a database other than kubeflow because we can't delete the current database

