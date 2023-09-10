#!/bin/bash

# Cassandra run a command on all nodes of cluster
# requires ssh password-less login setup
# THIS SCRIPT DOES NOT NEED TO RUN FROM CRONTAB

#####################################
# environment variables

### change settings according to your environment in cass_settings.sh file

#####################################

# load common settings
SCRIPT_FOLDER=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source ${SCRIPT_FOLDER}/cass_settings.sh > /dev/null ;

SCRIPT_RUN_START="`date +'%a %d-%b-%Y %I:%M:%S %p %Z'`"
SCRIPT_RUN_START_NUM="`date +'%s'`"

# main logic
for n in ${NODES}
do
  ssh ${n} " source ~/.bash_profile > /dev/null ; hostname ; nodetool info ; "
done

SCRIPT_RUN_END="`date +'%a %d-%b-%Y %I:%M:%S %p %Z'`"
SCRIPT_RUN_END_NUM="`date +'%s'`"
(( SCRIPT_RUN_SECONDS = $SCRIPT_RUN_END_NUM - $SCRIPT_RUN_START_NUM ))

# print report
echo `printf "%0.s-" {1..80}`
echo "Completed."
echo `printf "%0.s-" {1..80}`
echo -e "Script Started @ ${SCRIPT_RUN_START}"
echo -e "Script Ended   @ ${SCRIPT_RUN_END}"
echo -e "Script ran for ${SCRIPT_RUN_SECONDS} seconds"
echo `printf "%0.s-" {1..80}`

