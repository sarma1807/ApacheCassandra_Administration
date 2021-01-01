#!/bin/bash

# Cassandra Restart Cluster
# requires ssh password-less login setup
# THIS SCRIPT DOES NOT NEED TO RUN FROM CRONTAB
# script version : v04_20201224 : Sarma Pydipally

#####################################
# environment variables

### change settings according to your environment in cass_settings.sh file

#####################################

# load common settings
SCRIPT_FOLDER=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source ${SCRIPT_FOLDER}/cass_settings.sh > /dev/null ;

# main logic
for n in ${NODES}
do
  ssh ${n} " source ~/.bash_profile > /dev/null ; nodetool drain ; sleep 5 ; nodetool stopdaemon ; sleep 5 ; cassandra ; sleep 30 ; "
done


clear

# print final status
source ~/.bash_profile > /dev/null ;
nodetool status

echo "`nodetool status | grep UN | wc -l` nodes are up."
echo "`nodetool status | grep DN | wc -l` nodes are down."

