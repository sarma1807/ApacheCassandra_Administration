###### cassandra OS user on Linux systems will require following entries to avoid "Too many open files error"

---

###### as "root" user :
```
vi /etc/security/limits.conf
```
###### add following entries above file :
```
cassandra  soft  memlock  unlimited
cassandra  hard  memlock  unlimited
cassandra  soft  nofile   100000
cassandra  hard  nofile   100000
cassandra  soft  nproc    32768
cassandra  hard  nproc    32768
cassandra  soft  as       unlimited
cassandra  hard  as       unlimited
```

---
