#!/bin/bash
# 
# This script is used to generate actors.txt
# That file is used to generate company affilations.
#
# This script is intended to run on the devstats-cli-0 pod.
#
# It is based on:
# https://github.com/cncf/gitdm/blob/master/src/generate_actors.sh
#
# 
ACTORS_FILE=$1
psql -tA kubeflow < /mount/data/src/git_cncf-devstats/util_sql/actors.sql >> ${ACTORS_FILE}
cat ${ACTORS_FILE} | sort | uniq > actors.tmp
tr '\n' ',' < actors.tmp > out
rm actors.tmp
mv out ${ACTORS_FILE}
truncate -s-1 ${ACTORS_FILE}
