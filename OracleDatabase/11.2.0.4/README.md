# Docker Build Files Oracle Database 11.2.0.4

## General information

This folder contains the Docker build as well compose files for Oracle Database 11.2.0.4. The Oracle binaries are not included and must be copied separately into the software directory. The following binary packages are required to create a base installation of 11.2.0.4.

* *p13390677_112040_Linux-x86-64_1of7.zip* 11.2.0.4.0 PATCH SET FOR ORACLE DATABASE SERVER (Patchset)
* *p13390677_112040_Linux-x86-64_2of7.zip* 11.2.0.4.0 PATCH SET FOR ORACLE DATABASE SERVER (Patchset)

Optionally, the following latest patch set updates can be used.

* *p28729262_112040_Linux-x86-64.zip* DATABASE PATCH SET UPDATE 11.2.0.4.190115 (Patch)
* *p28790660_112040_Linux-x86-64.zip* OJVM PATCH SET UPDATE 11.2.0.4.190115 (Patch)
* *p6880880_112000_Linux-x86-64.zip* OPatch patch of version 11.2.0.3.20 for Oracle software releases 11.2.0.x and 18.x (OCT 2018) (Patch)

The exact download URLs are listed in the various **.download* files in the software folder.

## Building Oracle Database Docker Image

The *Dockerfile* is setup to use multistage build. The software can either be local in the *software* folder or downloaded during build from a local HTTP server. Both methods will create a space optimized Docker image.

Building the Docker images with local software packages:

```bash
docker build -t oracle/database:11.2.0.4 .
```

Building the Docker images with software packages from a local HTTP server. Where *orarepo_ip* is the name / IP address of the HTTP server:

```bash
export orarepo_ip=192.168.1.5
docker build --add-host=orarepo:${orarepo_ip} -t  oracle/database:11.2.0.4 .
```

## Running Oracle Database in a Docker container

Run your Oracle Database Docker image use the **docker run** command as follows:

```bash
docker run --name oud <container name> \
--hostname <container hostname> -p 1521:1521 
-e ORACLE_SID=<your oud instance name> \
-e INSTANCE_INIT=/u01/config \
--volume [<host mount point>:]/u01 \
--volume [<host mount point>:]/u01/config \
oracle/database:11.2.0.4
```

Alternatively you can use the provided Docker compose file.

```bash
docker-compose up -d
```