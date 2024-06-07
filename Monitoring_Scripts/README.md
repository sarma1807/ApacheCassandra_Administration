##### Linux bash scripts for monitoring Cassandra

##### scripts assume that Cassandra is configured to run as "cassandra" OS user

##### requires ssh password-less login setup between all nodes of the Cassandra cluster

```
These scripts were tested on :
Apache Cassandra 3.11.9 and above
and
DataStax Enterprise 6.8.6 and above
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

### on cass cluster - create login credentials required for cqlsh_connection_check.sh

```
CREATE ROLE cql_monitor WITH SUPERUSER = false AND LOGIN = true AND PASSWORD = '2baf811bc6428f9dda5d876c643136b5' ;
GRANT SELECT ON system.local TO cql_monitor ;
LIST ALL PERMISSIONS OF cql_monitor ;
```

##### password generated using : ` echo -n ILovePlayStation | md5sum | cut -f1 -d" " `

### crontab entries

```
#####################################
# repair - process run every night - only from 1 node on a cluster
15 23  * * * sh /apps/opt/cassandra/dba/bin/cass_repair.sh &

# monitor process run every 10 minutes - only from 1 node on a cluster
*/10 * * * * sh /apps/opt/cassandra/dba/bin/cass_monitor.sh &

# cql connection monitor process run every 8 minutes - only from 1 node on a cluster
*/8 * * * * sh /apps/opt/cassandra/dba/bin/cqlsh_connection_check.sh &
#####################################
```

### Sample Email Alert
![cass_monitor.jpg](https://github.com/sarma1807/ApacheCassandra_Administration/blob/main/Monitoring_Scripts/cass_monitor.jpg) <br><br>

