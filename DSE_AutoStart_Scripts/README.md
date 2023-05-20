##### auto-start scripts for DataStax Enterprise when installed using tarball

##### systemd (based on system V) : use this method on systems with Linux 7.x and above

##### scripts assume that DSE is configured to run as "cassandra" OS user

##### scripts assume ~/.bash_profile for "cassandra" OS user has <DSE_HOME>/bin is included into $PATH

---

##### as "cassandra" user

```
mkdir ~/admin
mkdir ~/logs
```

##### upload following 2 files to ~/admin folder and change file permissions

```
cp start_dse.sh ~/admin
cp stop_dse.sh ~/admin
```

```
chmod u+rwx ~/admin/start_dse.sh
chmod u+rwx ~/admin/stop_dse.sh

chmod go-rwx ~/admin/start_dse.sh
chmod go-rwx ~/admin/stop_dse.sh
```

---

##### as "root" user

##### upload following file to "/etc/systemd/system" folder

```
cp dseDB.service /etc/systemd/system
```

##### reload systemd daemon

```
systemctl daemon-reload
```

##### verify if auto-start service exists
```
systemctl list-unit-files | egrep -i "cassandra|dse|UNIT FILE"
```

##### disable/enable the auto-start service

```
systemctl disable dseDB.service
systemctl enable  dseDB.service
```

##### service [ status | start | stop ]
```
systemctl status dseDB.service
systemctl start  dseDB.service
systemctl stop   dseDB.service
```

