#!/bin/bash
if [ -z "$DEVSTATS_DIR" ]
then
  echo "$0: you need to set DEVSTATS_DIR"
  exit 1
 fi
cd "$DEVSTATS_DIR"
./run.sh || exit 1
