#!/bin/bash
set -ex	
# Modify some of the dashboards copied over from the devstats project
# e.g. the K8s dashboards
files=`find ./ks-app/components/grafana/dashboards -name *.json`	
for f in $files; do	
  # The k8s dashboard was named gha but we use influxdb
  sed -i "s/gha/influxdb/" ${f}	
  # TODO(jlewi): I think this only matches the first occurrence on each line.
  sed -i "s/Kubernetes/Kubeflow/" ${f}	
  sed -i "s/kubernetes/kubeflow/" ${f}	
  # We need to strip out the id field of the dashboard otherwise we get an error  
  jq  'del(.id)' ${f} > /tmp/somefile
  cp /tmp/somefile ${f}
done