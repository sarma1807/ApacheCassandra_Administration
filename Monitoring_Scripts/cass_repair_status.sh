#!/bin/bash

# Cassandra Repair Status
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

# capture cluster name
source ~/.bash_profile > /dev/null ;
CASS_CLUSTER_NAME=`nodetool describecluster | grep Name | cut -f2 -d':'`

# temp files
LOGFILE1=/tmp/cass_repair_status1.log
LOGFILE2=/tmp/cass_repair_status2.log
LOGFILE3=/tmp/cass_repair_status3.log

cat /dev/null > $LOGFILE1

# main logic
for n in ${NODES}
do
  ssh ${n} " source ~/.bash_profile > /dev/null ; hostname ; echo '~' ; nodetool info | grep Repair ; echo '^' ; " >> $LOGFILE1
done

# prep for final report
tr '\n' ' ' < $LOGFILE1 > $LOGFILE2
tr '^' '\n' < $LOGFILE2 > $LOGFILE3

echo "`cat ${LOGFILE3} | wc -l` servers were verified for repair status." >> $LOGFILE3

sed -i 's/^ //' $LOGFILE3

SCRIPT_RUN_END="`date +'%a %d-%b-%Y %I:%M:%S %p %Z'`"
SCRIPT_RUN_END_NUM="`date +'%s'`"
(( SCRIPT_RUN_SECONDS = $SCRIPT_RUN_END_NUM - $SCRIPT_RUN_START_NUM ))

clear
# print report
echo `printf "%0.s-" {1..80}`
echo "Cassandra Repair Status (${CASS_CLUSTER_NAME} ) :"
cat $LOGFILE3
echo `printf "%0.s-" {1..80}`
echo -e "Script Started @ ${SCRIPT_RUN_START}"
echo -e "Script Ended   @ ${SCRIPT_RUN_END}"
echo -e "Script ran for ${SCRIPT_RUN_SECONDS} seconds"
echo `printf "%0.s-" {1..80}`


# final cleanup
rm -f $LOGFILE1
rm -f $LOGFILE2
rm -f $LOGFILE3

