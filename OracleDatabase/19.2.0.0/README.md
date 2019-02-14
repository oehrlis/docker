
# Oracle Database Beta

The Oracle Database 19c Beta1 has been packet in a Docker image. This image contains a simple Oracle Installation including Trivadis BasEnv 18.05. When creating a container out of this image, a simple single tenant or container DB's will be create using *dbca* templates. Behavior can be customized by setting some environment variable see below.

## Import the Image

Due to the Oracle NDA this Docker image is not available on any public nor Trivadis internal Docker repository. It has to be build manually using the scripts [oehrlis/docker-database](https://github.com/oehrlis/docker-database) and [oehrlis/oradba_init](https://github.com/oehrlis/oradba_init) or you can import the image locally.

Import the TAR file of the Oracle 19.1.0.0 beta image.

```bash
gunzip -c oracle_database_19.1.0.0.tar.gz | docker load
```

## Setup Oracle 19c Beta Container

Below you find some basic use cases to create the containers. Drop me a line for more complicated use cases. 

### DB Container with Single Tenant DB

Setup a single tenant container. Adapt the container name, hostname, ORACLE_SID and volume according your requirements. 

```bash
docker run --detach --name tdb191s \
    --volume /data/docker/volumes/tdb191s:/u01   \
    -e ORACLE_SID=TDB191S \
    -P --hostname tdb191s.trivadislabs.com \
    oracle/database:19.1.0.0
```

Check the container logs to see how the DB is created

```bash
docker logs -f ttc19_single
```

### DB Container with Multi Tenant DB

Setup a multi tenant container. Adapt the container name, hostname, ORACLE_SID and volume according your requirements. As you can see it container DB's are created by setting environment variable *CONTAINER=TRUE*. Optionally you also can define the PDB name by setting *ORACLE_PDB*. By default one PDB named *PDB1* is created.

```bash
docker run --detach --name ttc19_cdb \
    --volume /data/docker/volumes/ttc19_cdb:/u01 \
    -e ORACLE_SID=TDB191C \
    -e CONTAINER=TRUE \
    -P --hostname ttc19_cdb.trivadislabs.com \
    oracle/database:19.1.0.0
```

### Access and Use the Container

Open a bash shell to the container. 

```bash
docker exec -it -u oracle ttc19_single bash --login
```

On MacOS I do sometimes have some issues with the terminal size due to this I adapt a few terminal settings

```bash
docker exec -e COLUMNS="`tput cols`" -e LINES="`tput lines`" -it -u oracle ttc19_single bash --login
```

Or use an alias...

```bash
alias deo='docker exec -e COLUMNS="`tput cols`" -e LINES="`tput lines`" -it -u oracle'
deo ttc19_single bash --login
```

Access the container via sqlplus.

* check which ports are used

```bash
docker ps
```

* get the sys password from docker logs. If you do not want that the password is dynamically create you may set a password when creating the container by setting *ORACLE_PWD*.

```bash
docker logs ttc19_cdb|grep Password
```

* use sqlplus from you client

```bash
sqlplus sys/xKGTtf1Fh5@localhost:32769/TDB191C as sysdba
```

## Build the image

The Docker image has been build using the Docker file from [oehrlis/docker-database](https://github.com/oehrlis/docker-database) and the setup scripts from [oehrlis/oradba_init](https://github.com/oehrlis/oradba_init). Software will be downloaded from a local webserver to keep the Docker image small.

Setup a container as local software repository. See also gist [oehrlis/docker_build_orarepo.md](https://gist.github.com/oehrlis/7c2948bfb5334f9327cd15078471f350).

```bash
docker run -dit \
  --hostname orarepo \
  --name orarepo \
  -p 80:80 \
  -v /data/docker/volumes/orarepo:/www \
  busybox httpd -fvvv -h /www
```

Get the IP from the OraRepo container and build the Oracle database image.

```bash
orarepo_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' orarepo)
docker build --add-host=orarepo:${orarepo_ip} -t oracle/database:19.1.0.0 .
```

## Save the image

The following command is used to save the Docker image into a TAR file including GZIP.

```bash
docker save oracle/database:19.1.0.0 |gzip -c >oracle_database_19.1.0.0.tar.gz
```
