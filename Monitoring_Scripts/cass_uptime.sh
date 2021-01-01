#!/bin/bash

# Cassandra Uptime
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

# capture cluster name
source ~/.bash_profile > /dev/null ;
CASS_CLUSTER_NAME=`nodetool describecluster | grep Name | cut -f2 -d':'`

# temp files
LOGFILE1=/tmp/cass_uptime1.log
LOGFILE2=/tmp/cass_uptime2.log
LOGFILE3=/tmp/cass_uptime3.log

cat /dev/null > $LOGFILE1

# main logic
for n in ${NODES}
do
  ssh ${n} " source ~/.bash_profile > /dev/null ; hostname -s ; echo '~' ; nodetool info | grep Uptime ; echo '^' ; " >> $LOGFILE1
done

# prep for final report
tr '\n' ' ' < $LOGFILE1 > $LOGFILE2
tr '^' '\n' < $LOGFILE2 > $LOGFILE3

echo "verified `cat ${LOGFILE3} | wc -l` servers." >> $LOGFILE3

sed -i 's/^ //' $LOGFILE3

clear
# print report
echo `printf "%0.s-" {1..80}`
echo "Cassandra Uptime (${CASS_CLUSTER_NAME} ) :"
cat $LOGFILE3
echo `printf "%0.s-" {1..80}`


# final cleanup
rm -f $LOGFILE1
rm -f $LOGFILE2
rm -f $LOGFILE3

