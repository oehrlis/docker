# docker-database

## DB Container

```bash
export MY_CONTAINER="db1830"
export MY_VOLUME_PATH="/data/docker/volumes/$MY_CONTAINER"
export MY_HOST="$MY_CONTAINER.postgasse.org"
export MY_ORACLE_SID="TDB183D"
```

Just create a container without starting it. Adjust ports, base DN etc.

```bash
docker container create --name ${MY_CONTAINER} \
    --volume ${MY_VOLUME_PATH}:/u01 -P  \
    -e ORACLE_SID=${MY_ORACLE_SID} \
    --hostname ${MY_HOST} \
    oracle/database:18.3.0.0
```

```bash
docker cp /Users/soe/Development/docker-database/OracleDatabase/18.3.0.0/scripts/create_database.sh $MY_CONTAINER:/opt/docker/bin
docker cp /Users/soe/Development/docker-database/OracleDatabase/18.3.0.0/scripts/run_database.sh $MY_CONTAINER:/opt/docker/bin
docker cp /Users/soe/Development/oradba_init/rsp/dbca.rsp.tmpl $MY_CONTAINER:/opt/oradba/rsp
```

Lets go. Start the container and let the scripts create the DB instance.

```bash
docker start $MY_CONTAINER
```

Enjoy the log and see how our DB instance is created.

```bash
docker logs -f $MY_CONTAINER
```

Enjoy the log and see how our DB instance is created.

```bash
docker exec -e COLUMNS="`tput cols`" -e LINES="`tput lines`" -it -u oracle $MY_CONTAINER bash --login
```

```bash
docker cp create_database.sh $MY_CONTAINER:/opt/docker/bin
```

build DB image

```bash
orarepo_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' orarepo)

docker build --add-host=orarepo:${orarepo_ip} -t oracle/database:11.2.0.4_new .

docker build --add-host=orarepo:${orarepo_ip} -t oracle/database:18.4.0.0 .

x
```

## Issues DB Create

Issues beim erstellen der DB

* lokales /u02
* controlfile name ohne DB Unique Name
* Datafile name ohne DB Unique Name
* redolog's ohne DB Unique Name
* nur ein set von RedoLogs
* Basenv Config für SID
* Files in ORACLE_HOME/dbs sind lokal

```sql
SQL> select name from v$controlfile;

NAME
--------------------------------------------------------------------------------
/u01/oradata/TE18EUS/control01.ctl
/u02/fast_recovery_area/TE18EUS/control02.ctl
```

```sql
SQL> select name from v$datafile;

NAME
--------------------------------------------------------------------------------
/u01/oradata/TE18EUS/system01.dbf
/u01/oradata/TE18EUS/sysaux01.dbf
/u01/oradata/TE18EUS/undotbs01.dbf
/u01/oradata/TE18EUS/users01.dbf
```

```sql
SQL> select member from v$logfile;

MEMBER
--------------------------------------------------------------------------------
/u01/oradata/TE18EUS/redo03.log
/u01/oradata/TE18EUS/redo02.log
/u01/oradata/TE18EUS/redo01.log
```


/opt/docker/bin/run_database.sh: line 113: /u00/app/oracle/product/18.3.0.0/network/admin/sqlnet.ora: No such file or directory
/opt/docker/bin/run_database.sh: line 113: /u00/app/oracle/product/18.3.0.0/network/admin/listener.ora: No such file or directory
/opt/docker/bin/run_database.sh: line 113: /u00/app/oracle/product/18.3.0.0/network/admin/ldap.ora: No such file or directory
/opt/docker/bin/run_database.sh: line 113: /u00/app/oracle/product/18.3.0.0/network/admin/tnsnames.ora: No such file or directory
mv: cannot stat '/u00/app/oracle/product/18.3.0.0/ldap/admin/dsi.ora': No such file or directory
mv: '/u00/app/oracle/etc/oratab' and '/u01/etc/oratab' are the same file
ln: failed to create symbolic link '/u00/app/oracle/etc/oratab': File exists

/opt/oradba/bin/50_run_database.sh: line 120: /u00/app/oracle/product/18.3.0.0/network/admin/sqlnet.ora: No such file or directory
/opt/oradba/bin/50_run_database.sh: line 120: /u00/app/oracle/product/18.3.0.0/network/admin/listener.ora: No such file or directory
/opt/oradba/bin/50_run_database.sh: line 120: /u00/app/oracle/product/18.3.0.0/network/admin/ldap.ora: No such file or directory
/opt/oradba/bin/50_run_database.sh: line 120: /u00/app/oracle/product/18.3.0.0/network/admin/tnsnames.ora: No such file or directory
mv: cannot stat '/u00/app/oracle/product/18.3.0.0/ldap/admin/dsi.ora': No such file or directory
mv: target '/u01/etc/sid.*.conf' is not a directory
mv: '/u00/app/oracle/etc/oratab' and '/u01/etc/oratab' are the same file
/opt/oradba/bin/50_run_database.sh: line 161: [: /u00/app/oracle/local/dba/etc/sid.TDB183D.conf: binary operator expected
ln: failed to create symbolic link '/u00/app/oracle/etc/oratab': File exists