#!/bin/bash

# Cassandra Monitoring Scripts Will Require This Settings File

#####################################
# environment variables

SCRIPT_VERSION=v07_20230910_SarmaPydipally

### change following settings according to your environment

# Email list for notifications (multiple email IDs in comma separated format)
TO_EMAIL_LIST=<email_1>,<email_2>,<email_3>
TO_PAGER_LIST=<pager_1>,<pager_2>
FROM_EMAIL_ID=`hostname`
DO_NOT_REPLY_EMAIL=<email>

SCRIPT_FOLDER=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
LOG_FOLDER="${SCRIPT_FOLDER}/../logs"

# space separated
NODES="server1 server2"


# nodes for repair
# following can be used to run job on few selected nodes during each week day
# space separated
# if [[ "`date +'%a'`" = "Sat" ]]; then REPAIR_NODES=""; fi
# if [[ "`date +'%a'`" = "Sun" ]]; then REPAIR_NODES=""; fi
# if [[ "`date +'%a'`" = "Mon" ]]; then REPAIR_NODES=""; fi
# if [[ "`date +'%a'`" = "Tue" ]]; then REPAIR_NODES=""; fi
# if [[ "`date +'%a'`" = "Wed" ]]; then REPAIR_NODES=""; fi
# if [[ "`date +'%a'`" = "Thu" ]]; then REPAIR_NODES=""; fi
# if [[ "`date +'%a'`" = "Fri" ]]; then REPAIR_NODES=""; fi


if [[ "${#REPAIR_NODES}" -eq "0" ]];  then REPAIR_NODES="${NODES}";  fi

#####################################
