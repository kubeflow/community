#!/bin/bash
# ARTWORK
# GET=1 (attempt to fetch Postgres database and Grafana database from the test server)
# INIT=1 (needs PG_PASS_RO, PG_PASS_TEAM, initialize from no postgres database state, creates postgres logs database and users)
# SKIPVARS=1 (if set it will skip final Postgres vars regeneration)
set -o pipefail
exec > >(tee run.log)
exec 2> >(tee errors.txt)
if [ -z "$PG_PASS" ]
then
  echo "$0: You need to set PG_PASS environment variable to run this script"
  exit 1
fi
if ( [ ! -z "$INIT" ] && ( [ -z "$PG_PASS_RO" ] || [ -z "$PG_PASS_TEAM" ] ) )
then
  echo "$0: You need to set PG_PASS_RO, PG_PASS_TEAM when using INIT"
  exit 1
fi

GRAF_USRSHARE="/usr/share/grafana"
GRAF_VARLIB="/var/lib/grafana"
GRAF_ETC="/etc/grafana"
export GRAF_USRSHARE
export GRAF_VARLIB
export GRAF_ETC

host=`hostname`
function finish {
    sync_unlock.sh
    rm -f /tmp/deploy.wip 2>/dev/null
}
if [ -z "$TRAP" ]
then
  sync_lock.sh || exit -1
  trap finish EXIT
  export TRAP=1
  > /tmp/deploy.wip
fi

if [ ! -z "$INIT" ]
then
  ./devel/init_database.sh || exit 1
fi

PROJ=kubeflow PROJDB=kubeflow PROJREPO="kubeflow/kubeflow" ORGNAME="kubeflow" PORT=3001 ICON="-" GRAFSUFF=kubeflow GA="-" ./devel/deploy_proj.sh || exit 2

if [ -z "$SKIPVARS" ]
then
  ./devel/vars_all.sh || exit 3
fi
echo "$0: All deployments finished"
