#!/bin/bash
#########################
source ~/.bash_profile
export LOGFILE=~/logs/dse_startup.log

### stop Cassandra
echo `printf "%0.s-" {1..20}` >> $LOGFILE
echo `date` >> $LOGFILE
echo "Attempting to stop DSE (if it is already running) ..." >> $LOGFILE
nodetool drain
dse cassandra-stop
sleep 30

### start Cassandra
echo `printf "%0.s-" {1..20}` >> $LOGFILE
echo `date` >> $LOGFILE
echo "Attempting to start DSE ..." >> $LOGFILE
dse cassandra
sleep 5
#########################
exit 0

