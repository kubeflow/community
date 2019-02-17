#!/bin/bash
if [ -z "$1" ]
then
  echo "$0: you need to provide db name"
  exit 1
fi
sudo -E -u postgres psql -c "select pg_terminate_backend(pid) from pg_stat_activity where datname = '$1'"
sudo -E -u postgres psql -c "drop database $1"
