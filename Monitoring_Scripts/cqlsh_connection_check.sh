#!/bin/bash

# Cassandra cqlsh_connection_check
# requires ssh password-less login setup

#####################################
# environment variables

### change settings according to your environment in cass_settings.sh file

#####################################

#####################################
# crontab & usage
# this script needs to run ONLY on 1 node of the cluster
# */8 * * * * sh <SCRIPT_FOLDER>/cqlsh_connection_check.sh &
#####################################

# load common settings
SCRIPT_FOLDER=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source ${SCRIPT_FOLDER}/cass_settings.sh > /dev/null ;

SCRIPT_RUN_START="`date +'%a %d-%b-%Y %I:%M:%S %p %Z'`"
SCRIPT_RUN_START_NUM="`date +'%s'`"

# log file
mkdir -p $LOG_FOLDER
LOG_FILE=$LOG_FOLDER/cqlsh_connection_check.log

CQLSH_CONNECTED_NODES=0
CQLSH_NOT_CONNECTED_NODES=0

CASS_CLUSTER_NAME=`nodetool describecluster | grep Name | cut -f2 -d':'`

# temp files and remove them if already exists
CQLSH_STATUS_EMAIL=/tmp/cqlsh_status_email.txt
rm -f $CQLSH_STATUS_EMAIL
### prepare email
echo -e "From: `echo $FROM_EMAIL_ID`\nTo: `echo $TO_EMAIL_LIST`\nSubject: `echo $CASS_CLUSTER_NAME` got cqlsh connection errors.\nContent-Type: text/html\n\n" > $CQLSH_STATUS_EMAIL
echo -e "<html><body>\n" >> $CQLSH_STATUS_EMAIL
echo -e "<h3> <font color=RED> cqlsh was unable to connect to following nodes : </font> </h3>\n" >> $CQLSH_STATUS_EMAIL
echo -e "<table border=1 cellpadding=5> <tr> <td> HOSTNAME </td> </tr>\n" >> $CQLSH_STATUS_EMAIL

# main logic
for n in ${NODES}
do
  source ~/.bash_profile > /dev/null ;
  cqlsh --username=$CQL_USER --password=$CQL_PWD --execute="SELECT host_id FROM system.local" ${n} > /dev/null ;
  CQLSH_EXIT_CODE=$?

  if [[ "$CQLSH_EXIT_CODE" -ne "0" ]]
  then
    # looks like cqlsh was not able to establish connection to specific node in cassandra cluster
    echo "`date +'%Y-%m-%d %H:%M:%S'` : ${n} : cqlsh got connection error." >> $LOG_FILE
    CQLSH_NOT_CONNECTED_NODES=$((CQLSH_NOT_CONNECTED_NODES+1))
    echo "<tr> <td> ${n} </td> </tr>" >> $CQLSH_STATUS_EMAIL
  else
    CQLSH_CONNECTED_NODES=$((CQLSH_CONNECTED_NODES+1))
  fi
done

### send email
if [[ "$CQLSH_NOT_CONNECTED_NODES" -ne "0" ]]
then
  echo -e "</table>\n" >> $CQLSH_STATUS_EMAIL
  echo -e "<br><br>Steps to verify and solve this issue :\n"                                                                  >> $CQLSH_STATUS_EMAIL
  echo -e "<br>0. verify that cql_monitor user is created on the cassandra cluster.\n"                                        >> $CQLSH_STATUS_EMAIL
  echo -e "<br>1. connect to node which is having issue.\n"                                                                   >> $CQLSH_STATUS_EMAIL
  echo -e "<br>2. use 'cqlsh' to connect to cassandra and it might fail. if it fails to connect then proceed to next step.\n" >> $CQLSH_STATUS_EMAIL
  echo -e "<br>3. use 'sh ~/admin/start_dse.sh' to restart DSE.\n"                                                            >> $CQLSH_STATUS_EMAIL
  echo -e "<br>4. use 'cqlsh' to connect to cassandra and it should no longer fail.\n"                                        >> $CQLSH_STATUS_EMAIL
  echo -e "</body></html>\n"                                                                                                  >> $CQLSH_STATUS_EMAIL
  echo -e "<br><br>Report generated on `hostname` @ `date +'%Y-%m-%d %H:%M:%S'` \n\n"                                         >> $CQLSH_STATUS_EMAIL
  cat $CQLSH_STATUS_EMAIL | $SENDMAIL_LOCATION/sendmail -r $DO_NOT_REPLY_EMAIL -t
fi

SCRIPT_RUN_END="`date +'%a %d-%b-%Y %I:%M:%S %p %Z'`"
SCRIPT_RUN_END_NUM="`date +'%s'`"
(( SCRIPT_RUN_SECONDS = $SCRIPT_RUN_END_NUM - $SCRIPT_RUN_START_NUM ))

# record final log
# echo `printf "%0.s~" {1..80}` >> $LOG_FILE
echo -e "${SCRIPT_RUN_END} : CONNECTED TO ${CQLSH_CONNECTED_NODES} NODES & FAILED TO CONNECT TO ${CQLSH_NOT_CONNECTED_NODES} NODES." >> $LOG_FILE
echo -e "Script Started @ ${SCRIPT_RUN_START}" >> $LOG_FILE
echo -e "Script Ended   @ ${SCRIPT_RUN_END}" >> $LOG_FILE
echo -e "Script ran for ${SCRIPT_RUN_SECONDS} seconds" >> $LOG_FILE
echo `printf "%0.s~" {1..80}` >> $LOG_FILE


