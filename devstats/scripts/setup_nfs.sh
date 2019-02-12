#!/bin/bash
#
# Onetime script to setup the Cloud NFS share used for Devstats.

# make the share world writable/readable
# Do this so the postgres containers can read and write to the share.
chmod -R a+rw /mount/data
