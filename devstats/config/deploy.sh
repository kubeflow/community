#!/bin/bash
mkdir /var/www 2>/dev/null
mkdir /var/www/html 2>/dev/null
./copy_devstats_binaries.sh || exit 1
cp cron/net_tcp_config.sh devel/sync_lock.sh devel/sync_unlock.sh $GOPATH/bin/ || exit 2
INIT=1 EXTERNAL=1 GHA2DB_GHAPISKIP=1 SKIPTEMP=1 ./devel/deploy_all.sh || exit 3
echo 'Deploy succeeded'
