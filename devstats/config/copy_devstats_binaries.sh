#!/bin/bash
binaries="structure runq gha2db calc_metric gha2db_sync import_affs annotations tags webhook devstats get_repos merge_dbs replacer vars ghapi2db columns hide_data website_data sync_issues devstats_api_server gha2es sqlitedb"
for f in $binaries
do
  cp $GOPATH/bin/$f ./ || exit 1
done
echo "DevStats binaries copied."
