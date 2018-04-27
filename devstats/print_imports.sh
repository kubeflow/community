#!/bin/bash
# A simple helper script to generate the copy paste text for the configmap
# to use all the dashboards


set -e
# Modify some of the dashboards copied over from the devstats project
# e.g. the K8s dashboards
files=`find ./ks-app/components/grafana/dashboards -name *.json`

TMPFILE=".${0##*/}-$$"
for f in $files; do	
   filename=$(basename -- "$f")
   echo \"${filename}\": importstr \"grafana/dashboards/${filename}\", >> ${TMPFILE}
done   

cat ${TMPFILE} | sort