##### auto-start scripts for Apache Cassandra when installed using tarball

##### systemd (based on system V) : use this method on systems with Linux 7.x and above

##### scripts assume that Cassandra is configured to run as "cassandra" OS user

---

##### scripts assume ~/.bash_profile for "cassandra" OS user has following entries :

```
export CASSANDRA_HOME=/apps/opt/cassandra/cassandra
export CASSANDRA_CONF=/apps/opt/cassandra/conf
export CASSANDRA_LOG_DIR=/apps/opt/cassandra/logs
export CASSANDRA_HEAPDUMP_DIR=/apps/opt/cassandra/logs
export PATH=$PATH:$CASSANDRA_HOME/bin:
```

---

##### as "cassandra" user

```
mkdir ~/admin
mkdir ~/logs
```

##### upload following 2 files to ~/admin folder and change file permissions

```
cp start_cassandra.sh ~/admin
cp stop_cassandra.sh ~/admin
```

```
chmod u+rwx ~/admin/start_cassandra.sh
chmod u+rwx ~/admin/stop_cassandra.sh

chmod go-rwx ~/admin/start_cassandra.sh
chmod go-rwx ~/admin/stop_cassandra.sh
```

---

##### as "root" user

##### upload following file to "/etc/systemd/system" folder

```
cp cassandraDB.service /etc/systemd/system
```

##### reload systemd daemon

```
systemctl daemon-reload
```

##### verify if auto-start service exists
```
systemctl list-unit-files | egrep -i "cassandra|dse"
```

##### disable/enable the auto-start service

```
systemctl disable cassandraDB.service
systemctl enable  cassandraDB.service
```

##### service [ status | start | stop ]
```
systemctl status cassandraDB.service
systemctl start  cassandraDB.service
systemctl stop   cassandraDB.service
```
