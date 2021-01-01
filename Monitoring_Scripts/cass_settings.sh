#!/bin/bash

# Cassandra Monitoring Scripts Will Require This Settings File
# script version : v04_20201224 : Sarma Pydipally

#####################################
# environment variables

### change following settings according to your environment

# Email list for notifications (multiple email IDs in comma separated format)
TO_EMAIL_LIST=<email1,email2,...>
TO_PAGER_LIST=<pager_number_as_email>
FROM_EMAIL_ID=`hostname`

SCRIPT_FOLDER=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
LOG_FOLDER="${SCRIPT_FOLDER}/../logs"

# space separated cassandra hosts list
# EXAMPLE : NODES="DooM1.OracleByExample.com,DooM2.OracleByExample.com,DooM3.OracleByExample.com"
NODES="<node1,node2,...>"


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

# nodes for compaction
# following can be used to run job on few selected nodes during each week day
# space separated
# if [[ "`date +'%a'`" = "Sat" ]]; then COMPACT_NODES=""; fi
# if [[ "`date +'%a'`" = "Sun" ]]; then COMPACT_NODES=""; fi
# if [[ "`date +'%a'`" = "Mon" ]]; then COMPACT_NODES=""; fi
# if [[ "`date +'%a'`" = "Tue" ]]; then COMPACT_NODES=""; fi
# if [[ "`date +'%a'`" = "Wed" ]]; then COMPACT_NODES=""; fi
# if [[ "`date +'%a'`" = "Thu" ]]; then COMPACT_NODES=""; fi
# if [[ "`date +'%a'`" = "Fri" ]]; then COMPACT_NODES=""; fi

if [[ "${#REPAIR_NODES}" -eq "0" ]];  then REPAIR_NODES="${NODES}";  fi
if [[ "${#COMPACT_NODES}" -eq "0" ]]; then COMPACT_NODES="${NODES}"; fi

#####################################
