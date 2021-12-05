# Oracle Unified Directory Serivces Manager (OUDSM) on Docker

Docker build files to facilitate installation, configuration, and environment setup for Docker DevOps users. For more information about Oracle Unified Directory please see the [Oracle Unified Directory 12.2.1.4.0 Online Documentation](https://docs.oracle.com/en/middleware/idm/unified-directory/12.2.1.4/books.html/).

Just to clarify these Docker build scripts are **unofficial** Oracle Build scripts. See [Oracle Docker images](https://github.com/oracle/docker-images) on GitHub for the official Oracle Docker build scripts.

## Docker Images Content

The resulting Docker images are based on the official Oracle Java image for Java 8 u172 (_oracle/serverjre:8_). It has either be build manually using the [official](https://github.com/oracle/docker-images/tree/master/OracleJava) or [my unofficial](https://github.com/oehrlis/docker/tree/master/OracleJava) Oracle Docker build scripts or pulled from [Docker Store](https://store.docker.com/images/oracle-serverjre-8). If you pull the java image from the docker store you may have to tag it to _oracle/serverjre:8_.

```bash
docker login
docker pull store/oracle/serverjre:8
docker tag store/oracle/serverjre:8 oracle/serverjre:8
```

They base image should provide some additional linux package for tar, gzip and libaio. If not yet available the following Linux packages and configuration:

* Install the following additional packages including there dependencies:
  * *libaio* Linux-native asynchronous I/O access library
  * *tar* A GNU file archiving program
  * *gzip* The GNU data compression program
* Operating system user *oracle* (uid 1000)
* Dedicated groups for user *oracle*, oracle (gid 1000), oinstall (gid 1010)
* ~~[OUD Base](https://github.com/oehrlis/oudbase) environment developed by [ORAdba](www.oradba.ch)~~
* Oracle OFA Directories see below
* Install Oracle Fusion Middleware Infrastructure 12c 12.2.1.3.0
* Install January 2018 PSU for WLS 27438258
* Install Oracle Unified Directory 12c 12.2.1.3.0 (collocated)

### Environment Variable and Directories

Based on the idea of OFA (Oracle Flexible Architecture) we try to separate the data from the binaries. This means that the OUDSM domain as well as configuration files are explicitly stored in a separate directory. Ideally, a volume is assigned to this directory when a container is created. This ensures data persistence over the lifetime of a container. OUD Base supports the setup and operation of the environment based on OFA. See also [OraDBA](http://www.oradba.ch/category/oudbase/).

The following environment variables have been used for the installation. In particular it is possible to modify the variables ORACLE_ROOT, ORACLE_DATA and ORACLE_BASE via *build-arg* during image build to have a different directory structure. All other parameters are only relevant for the creation of the container. They may be modify via ```docker run``` environment variables.

| Environment variable | Value / Directories                                    | Modifiable   | Comment                                                                                                     |
|----------------------|--------------------------------------------------------|--------------|-------------------------------------------------------------------------------------------------------------|
| ORACLE_ROOT          | ```/u00```                                             | docker build | Root directory for all the Oracle software                                                                  |
| ORACLE_BASE          | ```$ORACLE_ROOT/app/oracle```                          | docker build | Oracle base directory                                                                                       |
| n/a                  | ```$ORACLE_BASE/product```                             | no           | Oracle product base directory                                                                               |
| ORACLE_HOME_NAME     | ```fmw12.2.1.3.0```                                    | no           | Name of the Oracle Home, used to create to PATH to ORACLE_HOME eg. *$ORACLE_BASE/product/$ORACLE_HOME_NAME* |
| ORACLE_DATA          | ```/u01```                                             | docker build | Root directory for the persistent data eg. OUD instances, etc. A docker volumes must be defined for */u01*  |
| OUDSM_DOMAIN_BASE    | ```$ORACLE_DATA/domains```                             | no           | Base directory for OUDSM Domain                                                                             |
| DOMAIN_NAME          | ```oudsm_domain```                                     | docker run   | Default name for OUDSM domain                                                                               |
| DOMAIN_HOME          | ```${OUDSM_DOMAIN_BASE}/${DOMAIN_NAME}``` | docker run |              |                                                                                                             |
| CREATE_DOMAIN        | ```TRUE```                                             | docker run   | Flag to create OUD instance on first start of the container                                                 |
| PORT                 | ```7001```                                             | docker run   | Default HTTP port for the OUDSM domain                                                                      |
| PORT_SSL             | ```7002```                                             | docker run   | Default HTTPS port for the OUDSM domain                                                                     |
| ADMIN_USER           | ```weblogic```                                         | docker run   | Default admin user for OUDSM domain                                                                         |
| ADMIN_PASSWORD       | n/a                                                    | docker run   | No default password. Password will be autogenerated when not defined.                                       |
| ETC_BASE             | ```$ORACLE_DATA/etc```                                 | no           | Oracle etc directory with configuration files                                                               |
| LOG_BASE             | ```$ORACLE_DATA/log```                                 | no           | Oracle log directory with log files                                                                         |
| DOWNLOAD             | ```/tmp/download```                                    | no           | Temporary download directory, will be removed after build                                                   |
| DOCKER_BIN           | ```/opt/docker/bin```                                  | no           | Docker build and setup scripts                                                                              |
| JAVA_DIR             | ```/usr/java```                                        | no           | Base directory for java home location                                                                       |
| JAVA_HOME            | ```$JAVA_DIR/jdk1.8.0_162```                           | no           | Java home directory when build manually. The official docker image may have an other minor release.         |

In general it does not make sense to change all possible variables. Although *BASEDN* and *ADMIN_PASSWORD* are good candidates for customization. all other variables can generally easily be ignored.

### Scripts to Build and Setup

The following scripts are used either during Docker image build or while setting up and starting the container.

| Script                       | Purpose                                                     |
|------------------------------|-------------------------------------------------------------|
| ```check_oudsm_console.sh``` | Check the status of the OUDSM domain for Docker HEALTHCHECK |
| ```create_oudsm_domain.py``` | WLST / phyton script to create the OUDSM domain             |
| ```create_oudsm_domain.sh``` | Script to create the OUDSM domain                           |
| ```start_oudsm_domain.sh```  | Script to start the OUDSM domain                            |

## Installation and Build

The Docker images have to be build manually based on [oehrlis/docker](https://github.com/oehrlis/docker) from GitHub. The required software has to be downloaded prior image build and must be part of the build context or made available in a local HTTP server. See [Build with local HTTP server](#build-with-local-http-server) below. When providing a local HTTP server to download the required software during image build will lead into smaller images, since the software will not be part of an intermediate intermediate container. The procedure was briefly described in the blog post [Smaller Oracle Docker images](http://www.oradba.ch/2018/03/smaller-oracle-docker-images/).

### Obtaining Product Distributions

The Oracle Software required to setup an Oracle Unified Directory Docker image is basically not public available. It is subject to Oracle's license terms. For this reason a valid license is required (eg. [OTN Developer License Terms](http://www.oracle.com/technetwork/licenses/standard-license-152015.html)). In addition, Oracle's license terms and conditions must be accepted before downloading.

The following software is required for the Oracle Unified Directory Docker image:

* Oracle Fusion Middleware 12.2.1.3.0 Fusion Middleware Infrastructure
* January 2018 WLS PATCH SET UPDATE 12.2.1.3.180116 Oracle WebLogic Server 12.2.1.3.0
* Oracle Fusion Middleware 12.2.1.3.0 Oracle Unified Directory

The software can either be downloaded from [My Oracle Support (MOS)](https://support.oracle.com), [Oracle Technology Network (OTN)](http://www.oracle.com/technetwork/index.html) or [Oracle Software Delivery Cloud (OSDC)](http://edelivery.oracle.com). The following links refer to the MOS software download to simplify the build process.

The corresponding links and checksum can be found in `*.download` files. Alternatively the Oracle Support Download Links:

* Oracle Fusion Middleware 12.2.1.3.0 Fusion Middleware Infrastructure [Patch 26269885](https://updates.oracle.com/ARULink/PatchDetails/process_form?patch_num=26269885) or [direct](https://updates.oracle.com/Orion/Services/download/p26269885_122130_Generic.zip?aru=21502041&patch_file=p26269885_122130_Generic.zip)
* Oracle WLS PATCH SET UPDATE 12.2.1.3.180116 Oracle WebLogic Server 12.2.1.3.0 [Patch 27438258](https://updates.oracle.com/ARULink/PatchDetails/process_form?patch_num=27438258) or [direct](https://updates.oracle.com/Orion/Services/download/p27438258_122130_Generic.zip?aru=21899283&patch_file=p27438258_122130_Generic.zip)
* Oracle Fusion Middleware 12.2.1.3.0 Oracle Unified Directory [Patch 26270957](https://updates.oracle.com/ARULink/PatchDetails/process_form?patch_num=26270957) or [direct](https://updates.oracle.com/Orion/Services/download/p26270957_122130_Generic.zip?aru=21504981&patch_file=p26270957_122130_Generic.zip)

### Build using COPY

Simplest method to build the OUDSM image is to manually download the required software and put it into the build folder respectively context. However this will lead to bigger Docker images, since the software is copied during build, which temporary blow up the container file-system.

Copy all files to the `OracleOUDSM/12.2.1.3.0` folder.

```bash
cp p26270957_122130_Generic.zip OracleOUDSM/12.2.1.3.0
cp p27438258_122130_Generic.zip OracleOUDSM/12.2.1.3.0
cp p26270957_122130_Generic.zip OracleOUDSM/12.2.1.3.0
```

Build the docker image using `docker build`.

```bash
cd OracleOUDSM/12.2.1.3.0
docker build -t oracle/oudsm:12.2.1.3.0 .
```

### Build with local HTTP server

Alternatively the software can also be downloaded from a local HTTP server during build. For this a Docker image for an HTTP server is required eg. official Apache HTTP server Docker image based on alpine.

Start a local HTTP server. httpd:alpine will be pulled from Docker Hub:

```bash
docker run -dit --hostname orarepo --name orarepo \
    -p 8080:80 \
    -v /Data/vm/docker/volumes/orarepo:/usr/local/apache2/htdocs/ \
    httpd:alpine
```

Make sure, that the software is know copied to the volume folder not part of the build context any more:

```bash
cd OracleOUDSM/12.2.1.3.0
cp p26270957_122130_Generic.zip /Data/vm/docker/volumes/orarepo
cp p27438258_122130_Generic.zip /Data/vm/docker/volumes/orarepo
cp p26270957_122130_Generic.zip /Data/vm/docker/volumes/orarepo
rm p26270957_122130_Generic.zip p27438258_122130_Generic.zip p26270957_122130_Generic.zip
```

Get the IP address of the local HTTP server:

```bash
orarepo_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' orarepo)
```

Build the docker image using `docker build` and provide the HTTP server.

```bash
docker build --add-host=orarepo:${orarepo_ip} -t oracle/oudsm:12.2.1.3.0 .
```

The _RUN_ command in the Dockerfile will check if the software is part of the build context. If not, it will use the host _orarepo_ to download the software. This way the OUDSM Docker image will be about 400MB smaller.

### Build old OUD Images

Dockerfiles for older patch releases are as well part of the GitHub repository. eg. with the *Dockerfile.12.2.1.3.180116* one can build OUDSM with the PSU 180116 for WLS and the base release OUD 12.2.1.3.0, since there has no PSU 180116 for OUD. If a dedicate Dockerfile should be use, it has to be specified with -f.

```bash
docker build --add-host=orarepo:${orarepo_ip} -t oracle/oudsm:12.2.1.3.180116 -f Dockerfile.12.2.1.3.180116 .
```

Non-exhaustive overview of docker files

| Dockerfile                                                                                                                    | Version    | Patch Release (WLS/OUD) |
|-------------------------------------------------------------------------------------------------------------------------------|------------|-------------------------|
| [Dockerfile](https://github.com/oehrlis/docker/blob/master/OracleOUDSM/12.2.1.3.0/Dockerfile)                                 | 12.2.1.3.0 | latest PSU              |
| [Dockerfile.12.2.1.3.180116](https://github.com/oehrlis/docker/blob/master/OracleOUDSM/12.2.1.3.0/Dockerfile.12.2.1.3.180116) | 12.2.1.3.0 | PSU 180116              |

## Running the Docker Images

### Setup an Oracle Unified Directory Server Manager Container

Creating a OUDSM container is straight forward with **docker run** command. The script `start_oudsm_domain.sh` will make sure, that a new OUDSM domain is created, when the container is started the first time.  The domain is created using predefined values. (see below). If an OUDSM domain already exists, the script simply starts it.

The creation of the OUDSM domain can be influenced by the following environment variables. You only have to set them with option -e when executing "docker run":

* **ADMIN_PASSWORD** Weblogic admin password (default *autogenerated*)
* **PORT** OUDSM admin port (default *7001*)
* **PORT_SSL** OUDSM SSL admin port (default *7002*)
* **ADMIN_USER**  Weblogic admin user name (default *weblogic*)
* **CREATE_DOMAIN** Flag to create OUDS instance on first startup (default *TRUE*)
* **DOMAIN_HOME** Domain home path (default */u01/domains/oudsm_domain*)
* **DOMAIN_NAME** OUDSM weblogic domain name (default *oudsm_domain*)

Run your Oracle Unified Directory Docker image use the **docker run** command as follows:

```bash
docker run --name oudsm <container name> \
--hostname <container hostname> \
-p 7001:7001 -p 7002:7002 \
-e <Variables>=<values> \
--volume [<host mount point>:]/u01 \
oracle/oudsm:12.2.1.3.0

Parameters:
--name:           The name of the container (default: auto generated)
-p:               The port mapping of the host port to the container port.
                  for ports are exposed: 7001 (WLS Console), 7002 (WLS Console SSL)
-e <Variables>    Other environment variable according "Environment Variable and Directories"
-v /u01
                  The data volume to use for the OUD instance.
                  Has to be writable by the Unix "oracle" (uid: 1000) user inside the container!
                  If omitted the OUD instance will not be persisted over container recreation.
```

There are two ports that are exposed in this image:

* 7001 which is the regular LDAP port to connect to the OUD instance.
* 7002 which is the SSL LDAP port to connect to the OUD instance.

On the first startup of the container a random password will be generated for the OUDSM domain if not provided. You can find this password in the output line:
If you need to find the passwords at a later time, grep for "password" in the Docker logs generated during the startup of the container. To look at the Docker Container logs run:

```bash
docker logs --details oudsm|grep -i password
```

## Frequently asked questions

Please see [FAQ.md](./FAQ.md) for frequently asked questions.

## Issues

Please file your bug reports, enhancement requests, questions and other support requests within [Github's issue tracker](https://help.github.com/articles/about-issues/):

* [Existing issues](https://github.com/oehrlis/docker/issues)
* [submit new issue](https://github.com/oehrlis/docker/issues/new)

## License

oehrlis/docker is licensed under the GNU General Public License v3.0. You may obtain a copy of the License at <https://www.gnu.org/licenses/gpl.html>.

To download and run Oracle Unified Directory, Oracle Directory Server Enterprise Edition or any other Oracle product, regardless whether inside or outside a Docker container, you must download the binaries from the Oracle website and accept the license indicated at that page. See [OTN Developer License Terms](http://www.oracle.com/technetwork/licenses/standard-license-152015.html) and [Oracle Database Licensing Information User Manual](https://docs.oracle.com/database/122/DBLIC/Licensing-Information.htm#DBLIC-GUID-B6113390-9586-46D7-9008-DCC9EDA45AB4)
