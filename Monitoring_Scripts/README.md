##### Linux bash scripts for monitoring Cassandra

##### scripts assume that Cassandra is configured to run as "cassandra" OS user

##### requires ssh password-less login setup between all nodes of the Cassandra cluster

```
These scripts were tested on :
OpenSource Version of Apache Cassandra ReleaseVersion: 3.11.9
and
DataStax Enterprise 6.8.6
```

---

##### SCRIPTS CAN RUN FROM 1 NODE IN THE CLUSTER
##### as "cassandra" user

```
mkdir -p ~/dba/bin
mkdir -p ~/dba/logs
```

##### upload all bash scripts to : "~/dba/bin" folder

### change settings according to your environment in "cass_settings.sh" file

```
for cluster restarts :
on Apache Cassandra cluster use    : cass_restart_cluster.sh
on DataStax Enterprise cluster use : dse_restart_cluster.sh
```

##### crontab entries

```
#####################################
# repair - process run every night - only from 1 node on a cluster
15 23  * * * sh /apps/opt/cassandra/dba/bin/cass_repair.sh &

# monitor process run every 10 minutes - only from 1 node on a cluster
*/10 * * * * sh /apps/opt/cassandra/dba/bin/cass_monitor.sh &
#####################################
```

