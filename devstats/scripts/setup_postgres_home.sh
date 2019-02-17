#!/bin/bash
#
# Create a home directory for the postgres user
set -ex
mkdir -p /home/postgres
cp -f /etc/skel/.bashrc /home/postgres/

# We need to export all the PG variables and source them from 
# the .bash file. We need to do this because the devstats scripts
# sudo to user postgres and we need these environment variables
env | grep PG | awk '{print "export "$0}'  > /home/postgres/postgres_env.sh

echo "source /home/postgres/postgres_env.sh" >> /home/postgres/.bashrc

# .profile but not .bashrc is sourced when doing sudo
echo "source /home/postgres/postgres_env.sh" > "/home/postgres/.profile"

chown -R postgres /home/postgres
chgrp -R postgres /home/postgres
