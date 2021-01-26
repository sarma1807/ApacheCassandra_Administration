#!/bin/bash

# Cassandra Repair
# requires ssh password-less login setup

#####################################
# environment variables

### change settings according to your environment in cass_settings.sh file

#####################################

#####################################
# crontab & usage
# this script needs to run ONLY on 1 node of the cluster
# 15 23 * * * sh <SCRIPT_FOLDER>/cass_repair.sh &
#####################################

# load common settings
SCRIPT_FOLDER=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source ${SCRIPT_FOLDER}/cass_settings.sh > /dev/null ;

SCRIPT_RUN_START="`date +'%a %d-%b-%Y %I:%M:%S %p %Z'`"
SCRIPT_RUN_START_NUM="`date +'%s'`"

# log file
mkdir -p $LOG_FOLDER
LOG_FILE=$LOG_FOLDER/repair.log_`date +'%Y%m%d-%H%M%S'`

# main logic
for n in ${REPAIR_NODES}
do
  ssh ${n} " source ~/.bash_profile > /dev/null ; hostname ; nodetool repair --partitioner-range ; " >> $LOG_FILE
done

SCRIPT_RUN_END="`date +'%a %d-%b-%Y %I:%M:%S %p %Z'`"
SCRIPT_RUN_END_NUM="`date +'%s'`"
(( SCRIPT_RUN_SECONDS = $SCRIPT_RUN_END_NUM - $SCRIPT_RUN_START_NUM ))

# record final log
echo `printf "%0.s~" {1..80}` >> $LOG_FILE
echo -e "Script Started @ ${SCRIPT_RUN_START}" >> $LOG_FILE
echo -e "Script Ended   @ ${SCRIPT_RUN_END}" >> $LOG_FILE
echo -e "Script ran for ${SCRIPT_RUN_SECONDS} seconds" >> $LOG_FILE
echo `printf "%0.s-" {1..80}` >> $LOG_FILE


# final cleanup
rm -f /tmp/cass_repair.log

