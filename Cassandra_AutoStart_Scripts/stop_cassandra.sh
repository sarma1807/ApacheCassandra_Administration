#!/bin/bash
#########################
source ~/.bash_profile
export CASSANDRA_LOG_DIR=~/logs
export LOGFILE=$CASSANDRA_LOG_DIR/cassandra_shutdown.log

### stop Cassandra
echo `printf "%0.s-" {1..20}` >> $LOGFILE
echo `date` >> $LOGFILE
echo "Attempting to stop Cassandra (if it is already running) ..." >> $LOGFILE
nodetool drain
nodetool stopdaemon
sleep 30
#########################
exit 0

