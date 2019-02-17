#!/bin/bash
# Modify the scripts https://github.com/cncf/devstats-example
# We add the -E option to the sudo commands so that the environment is preserved
set -ex	

LOCATION=$1
# Modify some of the dashboards copied over from the devstats project
# e.g. the K8s dashboards
files=`find "${LOCATION}" -name "*.sh"`	
for f in $files; do	
  # TODO(jlewi): I think this only matches the first occurrence on each line.
  # Use g to match multiple occurrences per line.
  sed -i "s/sudo/sudo -E/g" ${f}	
done