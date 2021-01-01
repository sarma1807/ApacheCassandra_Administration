#!/bin/bash

# Cassandra run a command on all nodes of cluster
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
  # EXAMPLE : ssh ${n} " source ~/.bash_profile > /dev/null ; nodetool clearsnapshot ; "
  ssh ${n} " source ~/.bash_profile > /dev/null ; date ; "
done

clear
# print report
echo `printf "%0.s-" {1..80}`
echo "Completed."
echo `printf "%0.s-" {1..80}`

