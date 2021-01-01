#!/bin/bash

# Cassandra Compaction
# requires ssh password-less login setup
# script version : v04_20201224 : Sarma Pydipally

#####################################
# environment variables

### change settings according to your environment in cass_settings.sh file

#####################################


# load common settings
SCRIPT_FOLDER=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source ${SCRIPT_FOLDER}/cass_settings.sh > /dev/null ;

# log file
mkdir -p $LOG_FOLDER
LOG_FILE=$LOG_FOLDER/compact.log_`date +'%Y%m%d-%H%M%S'`

# main logic
for n in ${COMPACT_NODES}
do
  ssh ${n} " source ~/.bash_profile > /dev/null ; hostname -s ; date ; echo 'before compaction ${n}' ; nodetool garbagecollect ; date ; echo 'after compaction ${n}' ; " >> $LOG_FILE
done

# record final log
echo `printf "%0.s~" {1..50}` >> $LOG_FILE
egrep "EDT 20|before|after" $LOG_FILE > /tmp/cass_compact.log
cat /tmp/cass_compact.log | sed -z 's/\nbefore/ : before/g' | sed -z 's/\nafter/ :  after/g' >> $LOG_FILE


# final cleanup
rm -f /tmp/cass_compact.log

