#!/bin/bash
set -ex	

LOCATION=$1
# Modify some of the dashboards copied over from the devstats project
# e.g. the K8s dashboards
files=`find "${LOCATION}" -name "*.json"`	
for f in $files; do	
  # TODO(jlewi): I think this only matches the first occurrence on each line.
  # Use g to match multiple occurrences per line.
  sed -i "s/Knative/Kubeflow/g" ${f}	
  sed -i "s/knative/kubeflow/g" ${f}	
  # We need to strip out the id field of the dashboard otherwise we get an error  
  jq  'del(.id)' ${f} > /tmp/somefile
  cp /tmp/somefile ${f}
done