#!/bin/bash
if [ -z "${PG_PASS}" ]
then
  echo "You need to set PG_PASS environment variable to run this script"
  exit 1
fi
if [ -z "$ONLY" ]
then
  all="homebrew"
else
  all=$ONLY
fi
for proj in $all
do
    db=$proj
    if [ "$proj" = "kubernetes" ]
    then
      db="gha"
    elif [ "$proj" = "all" ]
    then
      db="allprj"
    fi
    echo "Project: $proj, PDB: $db"
    sudo -E -u postgres psql "$db" -c "delete from gha_vars" || exit 1
    GHA2DB_LOCAL=1 GHA2DB_PROJECT=$proj PG_DB=$db ./vars || exit 2
done
echo 'OK'
