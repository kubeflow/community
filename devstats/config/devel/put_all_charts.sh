#!/bin/bash
if [ -z "$ONLY" ]
then
  all="kubeflow"
else
  all=$ONLY
fi
for proj in $all
do
    suff=$proj
    NOCOPY=1 GRAFANA=$suff devel/import_jsons_to_sqlite.sh grafana/dashboards/$proj/*.json || exit 2
done
echo 'OK'
