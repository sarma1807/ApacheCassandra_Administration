#!/bin/bash

# Cassandra Cluster Monitor
# requires ssh password-less login setup

#####################################
# environment variables

### change settings according to your environment in cass_settings.sh file

#####################################
# crontab & usage
# this script needs to run ONLY on 1 node of the cluster
# */10 * * * * sh <SCRIPT_FOLDER>/cass_monitor.sh &
#####################################

# load common settings
SCRIPT_FOLDER=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source ${SCRIPT_FOLDER}/cass_settings.sh > /dev/null ;

# log file
mkdir -p $LOG_FOLDER
LOG_FILE=$LOG_FOLDER/cass_monitor.log


# capture script start date and time
SCRIPT_START_DATE=`date +'%Y-%m-%d'`
SCRIPT_START_TIME=`date +'%H:%M:%S'`

# temp files and remove them if already exists
CASS_STATUS_EMAIL=/tmp/cass_status_email.txt
CASS_STATUS_UP=/tmp/cass_status.up
CASS_STATUS_DN=/tmp/cass_status.dn
CASS_STATUS_IP=/tmp/cass_status.ip
CASS_STATUS_A1=/tmp/cass_status.a1
CASS_STATUS_A2=/tmp/cass_status.a2
CASS_STATUS_PG=/tmp/cass_status.pg
CASS_STATUS_C1=/tmp/cass_status.c1

rm -f $CASS_STATUS_EMAIL
rm -f $CASS_STATUS_UP
rm -f $CASS_STATUS_DN
rm -f $CASS_STATUS_IP
rm -f $CASS_STATUS_A1
rm -f $CASS_STATUS_A2
rm -f $CASS_STATUS_C1


# get cassandra nodes status - collect from each node
for n in ${NODES}
do
  ssh ${n} " source ~/.bash_profile > /dev/null ; nodetool status | egrep -v 'Datacenter|Status|State|Address|keyspaces|=' | grep . ; " >> $CASS_STATUS_A1
done

# previous code was causing duplicate counts
# cat $CASS_STATUS_A1 | sort | uniq > $CASS_STATUS_A2
# new code change on 10-Sep-2023
cat $CASS_STATUS_A1 | awk '{ print $1" "$2 }' | sort | uniq > $CASS_STATUS_A2

# get count of nodes based on status
COUNT_UP_NODES=`cat $CASS_STATUS_A2 | grep 'UN ' | wc -l`
COUNT_DN_NODES=`cat $CASS_STATUS_A2 | grep -v '^UN ' | wc -l`

# check if all nodes are down
COUNT_NODES_FROM_CONFIG=`echo ${NODES} | wc -w`
if [[ "$COUNT_UP_NODES" -eq "0" ]]
then
  # looks like all nodes are down
  COUNT_DN_NODES=$COUNT_NODES_FROM_CONFIG
  ALL_NODES_DOWN=Y
fi

### if some nodes are down
if [[ "$COUNT_DN_NODES" -gt "0" ]]
then
  ### get cassandra cluster name
  for n in ${NODES}
  do
    ssh ${n} " source ~/.bash_profile > /dev/null ; nodetool describecluster | grep 'Name:' | awk -F ':' '{ print $2 }' ; " >> $CASS_STATUS_C1
  done

  CASS_CLUSTER_NAME=`cat $CASS_STATUS_C1 | sort | uniq | awk -F ':' '{ print $2 }'`

  ### get cassandra node ips
  cat $CASS_STATUS_A2 | grep -v '^UN ' | awk '{ print $2 }' > $CASS_STATUS_DN
  cat $CASS_STATUS_A2 | grep 'UN '     | awk '{ print $2 }' > $CASS_STATUS_UP

  while IFS= read -r ipAddr
  do
	ipHostName=`nslookup ${ipAddr} | grep name | cut -d' ' -f3 | rev | cut -c 2- | rev`
	echo "<tr> <td> <b> <font color=RED> DOWN </font> </b> </td> <td> <b> ${ipHostName} </b> </td> <td> <b> ${ipAddr} </b> </td> </tr>" >> ${CASS_STATUS_IP}
  done < "$CASS_STATUS_DN"

  while IFS= read -r ipAddr
  do
	ipHostName=`nslookup ${ipAddr} | grep name | cut -d' ' -f3 | rev | cut -c 2- | rev`
	echo "<tr> <td> UP & RUNNING </td> <td> ${ipHostName} </td> <td> ${ipAddr} </td> </tr>" >> ${CASS_STATUS_IP}
  done < "$CASS_STATUS_UP"

  
  ### prepare email
  echo -e "From: `echo $FROM_EMAIL_ID`\nTo: `echo $TO_EMAIL_LIST`\nSubject: nodes in `echo $CASS_CLUSTER_NAME` might be down\nContent-Type: text/html\n\n" > $CASS_STATUS_EMAIL
  echo -e "<html><body>\n" >> $CASS_STATUS_EMAIL
  
  if [[ "${ALL_NODES_DOWN}" = "Y" ]]
  then
    echo -e "<h3> <font color=RED> `echo $NODES` <br> ALL NODES might be down </font> </h3>\n" >> $CASS_STATUS_EMAIL
  else
    echo -e "<h3> <font color=RED> `echo $COUNT_DN_NODES` node(s) in `echo $CASS_CLUSTER_NAME` might be down </font> </h3>\n" >> $CASS_STATUS_EMAIL
  fi
  
  echo -e "<table border=1 cellpadding=5> <tr> <td> STATUS </td> <td> HOSTNAME </td> <td> IP </td> </tr>\n" >> $CASS_STATUS_EMAIL
  sort ${CASS_STATUS_IP} >> $CASS_STATUS_EMAIL
  echo -e "</table></body></html>\n" >> $CASS_STATUS_EMAIL
  echo -e "<br><br>Report generated on `hostname` @ `date +'%Y-%m-%d %H:%M:%S'` \n\n" >> $CASS_STATUS_EMAIL

  ### send email
  cat $CASS_STATUS_EMAIL | sendmail -r $DO_NOT_REPLY_EMAIL -t

  ### send pager alert, if it was previously NOT sent
  if [[ ! -f "$CASS_STATUS_PG" ]]
  then
    if [[ "${ALL_NODES_DOWN}" = "Y" ]]
    then
      SINGLE_LINE_MAIL_MSG="Subject: ALL NODES might be down in ${CASS_CLUSTER_NAME}"
      echo $SINGLE_LINE_MAIL_MSG | sendmail -r $DO_NOT_REPLY_EMAIL -v $TO_PAGER_LIST
    else
      SINGLE_LINE_MAIL_MSG="Subject: ${COUNT_DN_NODES} node(s) in ${CASS_CLUSTER_NAME} might be down."
      echo $SINGLE_LINE_MAIL_MSG | sendmail -r $DO_NOT_REPLY_EMAIL -v $TO_PAGER_LIST
    fi

    touch $CASS_STATUS_PG
  fi
else
  ### nodes are all UP, pager file is no longer required
  rm -f $CASS_STATUS_PG
fi

# clear log file on SUNDAY and 23rd hour
DAY_OF_WEEK=`date +'%w'`
HOUR_OF_DAY=`date +'%H'`
if [[ "$DAY_OF_WEEK" -eq "0" ]]
then
  if [[ "$HOUR_OF_DAY" -eq "23" ]]
  then
    cat /dev/null > $LOG_FILE
  fi
fi


# final cleanup
rm -f $CASS_STATUS_EMAIL
rm -f $CASS_STATUS_UP
rm -f $CASS_STATUS_DN
rm -f $CASS_STATUS_IP
rm -f $CASS_STATUS_A1
rm -f $CASS_STATUS_A2
rm -f $CASS_STATUS_C1


# capture script end time
SCRIPT_END_TIME=`date +'%H:%M:%S'`
echo "$SCRIPT_START_DATE : SCRIPT START $SCRIPT_START_TIME : SCRIPT END $SCRIPT_END_TIME : $COUNT_UP_NODES NODES UP : $COUNT_DN_NODES NODES DOWN" >> $LOG_FILE

