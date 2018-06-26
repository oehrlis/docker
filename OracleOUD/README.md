# Oracle Unified Directory on Docker
Docker build files to facilitate installation, configuration, and environment setup for Docker DevOps users. For more information about Oracle Unified Directory please see the [Oracle Unified Directory 12.2.1.3.0 Online Documentation](https://docs.oracle.com/middleware/12213/oud/).

Just to clarify these Docker build scripts are **unofficial** Oracle Build scripts. See [Oracle Docker images](https://github.com/oracle/docker-images) on GitHub for the official Oracle Docker build scripts.

### Docker Images Content
The resulting Docker images are based on the official Oracle Java image for Java 8 u172 (_oracle/serverjre:8_). It has either be build manually using the [official](https://github.com/oracle/docker-images/tree/master/OracleJava) or [my unofficial](https://github.com/oehrlis/docker/tree/master/OracleJava) Oracle Docker build scripts or pulled from [Docker Store](https://store.docker.com/images/oracle-serverjre-8). If you pull the java image from the docker store you may have to tag it to _oracle/serverjre:8_.

```
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
* Install Oracle Unified Directory 12c 12.2.1.3.0 (standalone)

### Environment Variable and Directories
Based on the idea of OFA (Oracle Flexible Architecture) we try to separate the data from the binaries. This means that the OUD instance as well as configuration files are explicitly stored in a separate directory. Ideally, a volume is assigned to this directory when a container is created. This ensures data persistence over the lifetime of a container. OUD Base supports the setup and operation of the environment based on OFA. See also [OraDBA](http://www.oradba.ch/category/oudbase/).

The following environment variables have been used for the installation. In particular it is possible to modify the variables ORACLE_ROOT, ORACLE_DATA and ORACLE_BASE via *build-arg* during image build to have a different directory structure. All other parameters are only relevant for the creation of the container. They may be modify via ```docker run``` environment variables.

Environment variable | Value / Directories                    | Modifiable   | Comment
-------------------- | -------------------------------------- | -------------| ---------------
ORACLE_ROOT          | ```/u00```                             | docker build | Root directory for all the Oracle software
ORACLE_BASE          | ```$ORACLE_ROOT/app/oracle```          | docker build | Oracle base directory
n/a                  | ```$ORACLE_BASE/product```             | no           | Oracle product base directory
ORACLE_HOME_NAME     | ```fmw12.2.1.3.0```                    | no           | Name of the Oracle Home, used to create to PATH to ORACLE_HOME eg. *$ORACLE_BASE/product/$ORACLE_HOME_NAME*
ORACLE_DATA          | ```/u01```                             | docker build | Root directory for the persistent data eg. OUD instances, etc. A docker volumes must be defined for */u01*
INSTANCE_BASE        | ```$ORACLE_DATA/instances```           | no           | Base directory for OUD instances
OUD_INSTANCE         | ```oud_docker```                       | docker run   | Default name for OUD instance
OUD_INSTANCE_HOME    | ```${INSTANCE_BASE}/${OUD_INSTANCE}``` | docker run   |
CREATE_INSTANCE      | ```TRUE```                             | docker run   | Flag to create OUD instance on first start of the container
OUD_PROXY            | ```FALSE```                            | docker run   | Flag to create proxy instance. Not yet implemented.
OUD_INSTANCE_INIT    | ```$ORACLE_DATA/scripts```             | docker run   | Directory for the instance configuration scripts
PORT                 | ```1389```                             | docker run   | Default LDAP port for the OUD instance
PORT_SSL             | ```1636```                             | docker run   | Default LDAPS port for the OUD instance
PORT_REP             | ```8989```                             | docker run   | Default replication port for the OUD instance
PORT_ADMIN           | ```4444```                             | docker run   | Default admin port for the OUD instance (4444)
ADMIN_USER           | ```cn=Directory Manager```             | docker run   | Default admin user for OUD instance
ADMIN_PASSWORD       |  n/a                                   | docker run   | No default password. Password will be autogenerated when not defined.
BASEDN               | ```dc=example,dc=com```                | docker run   | Default directory base DN
SAMPLE_DATA          | ```TRUE```                             | docker run   | Flag to load sample data. Not yet implemented.
ETC_BASE             | ```$ORACLE_DATA/etc```                 | no           | Oracle etc directory with configuration files
LOG_BASE             | ```$ORACLE_DATA/log```                 | no           | Oracle log directory with log files
DOWNLOAD             | ```/tmp/download```                    | no           | Temporary download directory, will be removed after build
DOCKER_BIN           | ```/opt/docker/bin```                  | no           | Docker build and setup scripts
JAVA_DIR             | ```/usr/java```                        | no           | Base directory for java home location
JAVA_HOME            | ```$JAVA_DIR/jdk1.8.0_162```           | no           | Java home directory when build manually. The official docker image may have an other minor release.

In general it does not make sense to change all possible variables. Although *BASEDN* and *ADMIN_PASSWORD* are good candidates for customization. all other variables can generally easily be ignored.

### Scripts to Build and Setup
The following scripts are used either during Docker image build or while setting up and starting the container.

| Script                       | Purpose
| ---------------------------- | ----------------------------------------------------------------------------
| ```check_oud_instance.sh```  | Check the status of the OUD instance for Docker HEALTHCHECK
| ```config_oud_instance.sh``` | Configure OUD instance using custom scripts
| ```create_oud_instance.sh``` | Script to create the OUD instance
| ```start_oud_instance.sh```  | Script to start the OUD instance

## Installation and Build
The Docker images have to be build manually based on [oehrlis/docker](https://github.com/oehrlis/docker) from GitHub. The required software has to be downloaded prior image build and must be part of the build context or made available in a local HTTP server. See [Build with local HTTP server](#build-with-local-http-server) below. When providing a local HTTP server to download the required software during image build will lead into smaller images, since the software will not be part of an intermediate intermediate container. The procedure was briefly described in the blog post [Smaller Oracle Docker images](http://www.oradba.ch/2018/03/smaller-oracle-docker-images/).

### Obtaining Product Distributions
The Oracle Software required to setup an Oracle Unified Directory Docker image is basically not public available. It is subject to Oracle's license terms. For this reason a valid license is required (eg. [OTN Developer License Terms](http://www.oracle.com/technetwork/licenses/standard-license-152015.html)). In addition, Oracle's license terms and conditions must be accepted before downloading.

The following software is required for the Oracle Unified Directory Docker image:
* Oracle Unified Directory 12.2.1.3.0

The software can either be downloaded from [My Oracle Support (MOS)](https://support.oracle.com), [Oracle Technology Network (OTN)](http://www.oracle.com/technetwork/index.html) or [Oracle Software Delivery Cloud (OSDC)](http://edelivery.oracle.com). The following links refer to the MOS software download to simplify the build process.

The corresponding links and checksum can be found in `*.download` files. Alternatively the Oracle Support Download Links:
* Oracle Unified Directory 12.2.1.3.0 [Patch 26270957](https://updates.oracle.com/ARULink/PatchDetails/process_form?patch_num=26270957) or [direct](https://updates.oracle.com/Orion/Services/download/p26270957_122130_Generic.zip?aru=21504981&patch_file=p26270957_122130_Generic.zip)

### Build using COPY
Simplest method to build the OUD image is to manually download the required software and put it into the build folder respectively context. However this will lead to bigger Docker images, since the software is copied during build, which temporary blow up the container file-system.

Copy all files to the `OracleOUD/12.2.1.3.0` folder.

```
cp p26270957_122130_Generic.zip OracleOUD/12.2.1.3.0
```

Build the docker image using `docker build`.

```
cd OracleOUD/12.2.1.3.0
docker build -t oracle/oud:12.2.1.3.0 .
```

### Build with local HTTP server
Alternatively the software can also be downloaded from a local HTTP server during build. For this a Docker image for an HTTP server is required eg. official Apache HTTP server Docker image based on alpine. See also [Smaller Oracle Docker images](http://www.oradba.ch/2018/03/smaller-oracle-docker-images/).

Start a local HTTP server. httpd:alpine will be pulled from Docker Hub:

```
docker run -dit --hostname orarepo --name orarepo \
    -p 8080:80 \
    -v /Data/vm/docker/volumes/orarepo:/usr/local/apache2/htdocs/ \
    httpd:alpine
```
Make sure, that the software is know copied to the volume folder not part of the build context any more:

```
cd OracleOUD/12.2.1.3.0
cp p26270957_122130_Generic.zip /Data/vm/docker/volumes/orarepo
rm p26270957_122130_Generic.zip
```

Get the IP address of the local HTTP server:

```
orarepo_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' orarepo)
```
Build the docker image using `docker build` and provide the HTTP server.

```
docker build --add-host=orarepo:${orarepo_ip} -t oracle/oud:12.2.1.3.0 .
```

The _RUN_ command in the Dockerfile will check if the software is part of the build context. If not, it will use the host _orarepo_ to download the software. This way the OUD Docker image will be about 400MB smaller.

### Build old OUD Images

Dockerfiles for older patch releases are as well part of the GitHub repository. eg. with the *Dockerfile.12.2.1.3.0* one can build the base release OUD 12.2.1.3.0. If a dedicate Dockerfile should be use, it has to be specified with -f.

```
docker build --add-host=orarepo:${orarepo_ip} -t oracle/oud:12.2.1.3.0 -f Dockerfile.12.2.1.3.0 .
```

Non-exhaustive overview of docker files

| Dockerfile                                                                                                                  | Version    | Patch Release         |
|-----------------------------------------------------------------------------------------------------------------------------|------------|-----------------------|
| [Dockerfile](https://github.com/oehrlis/docker/blob/master/OracleOUD/11.1.2.3.0/Dockerfile)                                 | 11.1.2.3.0 | latest PSU            |
| [Dockerfile.11.1.2.3.180116](https://github.com/oehrlis/docker/blob/master/OracleOUD/11.1.2.3.0/Dockerfile.11.1.2.3.180116) | 11.1.2.3.0 | PSU 180116            |
| [Dockerfile.11.1.2.3.0](https://github.com/oehrlis/docker/blob/master/OracleOUD/11.1.2.3.0/Dockerfile.11.1.2.3.0)           | 11.1.2.3.0 | base release / no PSU |
| [Dockerfile](https://github.com/oehrlis/docker/blob/master/OracleOUD/12.2.1.3.0/Dockerfile)                                 | 12.2.1.3.0 | latest PSU            |
| [Dockerfile.12.2.1.3.0](https://github.com/oehrlis/docker/blob/master/OracleOUD/12.2.1.3.0/Dockerfile.12.2.1.3.0)           | 12.2.1.3.0 | base release / no PSU |

## Running the Docker Images
### Setup an Oracle Unified Directory Container
Creating a OUD container is straight forward with **docker run** command. The script `start_oud_instance.sh` will make sure, that a new OUD instance is created, when the container is started the first time. The instance is created using predefined values. (see below). If an OUD instance already exists, the script simply starts it.

The creation of the OUD instance can be influenced by the following environment variables. You only have to set them with option -e when executing "docker run":

* **ADMIN_PASSWORD** OUD admin password (default *autogenerated*)
* **PORT_ADMIN** OUD admin port (default *4444*)
* **ADMIN_USER**  OUD admin user name (default *cn=Directory Manager*)
* **BASEDN** Directory base DN (default *dc=example,dc=com*)
* **CREATE_DOMAIN** Flag to create OUDS instance on first startup (default *TRUE*)
* **PORT_SSL** SSL LDAP port (default *1636*)
* **PORT** Regular LDAP port (default *1389*)
* **OUD_INSTANCE** OUD instance name (default *oud_docker*)
* **OUD_INSTANCE_HOME** OUD home path (default */u01/instances/oud_docker*)
* **OUD_INSTANCE_INIT** default folder for OUD instance init scripts. These scripts are used to modify and adjust the new OUD instance.
* **OUD_PROXY** Flag to create proxy instance (default *FALSE*) Not yet implemented.
* **PORT_REP** OUD replication port (default *8989*)
* **SAMPLE_DATA** Flag to load sample data (default *TRUE*) Not yet implemented.

Run your Oracle Unified Directory Docker image use the **docker run** command as follows:

```
docker run --name oud <container name> \
--hostname <container hostname> \
-p 1389:1389 -p 1636:1636 -p 4444:4444 \
-e OUD_INSTANCE=<your oud instance name> \
--volume [<host mount point>:]/u01 \
--volume [<host mount point>:]/u01/scripts \
oracle/oud:12.2.1.3.0

Parameters:
--name:           The name of the container (default: auto generated)
-p:               The port mapping of the host port to the container port.
                  for ports are exposed: 1389 (LDAP), 1636 (LDAPS), 4444 (Admin Port), 8989 (Replication Port)
-e OUD_INSTANCE:  The Oracle Database SYS, SYSTEM and PDB_ADMIN password (default: auto generated)
-e <Variables>    Other environment variable according "Environment Variable and Directories"
-v /u01
                  The data volume to use for the OUD instance.
                  Has to be writable by the Unix "oracle" (uid: 1000) user inside the container!
                  If omitted the OUD instance will not be persisted over container recreation.
-v /u01/app/oracle/scripts | /docker-entrypoint-initdb.d
                  Optional: A volume with custom scripts to be run after OUD instance setup.
                  For further details see the "Running scripts after setup" section below.
```

There are four ports that are exposed in this image:
* 1389 which is the regular LDAP port to connect to the OUD instance.
* 1636 which is the SSL LDAP port to connect to the OUD instance.
* 4444 which is the admin port to connect and configure the OUD instance using dsconfig.
* 8989 which is the replication port of the OUD instance.

On the first startup of the container a random password will be generated for the OUD instance if not provided. You can find this password in the output line. If you need to find the passwords at a later time, grep for "password" in the Docker logs generated during the startup of the container. To look at the Docker Container logs run:

```
docker logs --details oud|grep -i password
```

#### Running Bash in a Docker container
Access your OUD container via bash.

```
docker exec -u oracle -it oud bash --login
```

#### Running dsconfig in a Docker container
Execute `dsconfig` within the OUD container.

```
docker exec -u oracle -it oud dsconfig
```
#### Running scripts after setup
The OUD Docker image can be configured to run scripts after setup. Currently `sh`, `ldif` and `conf` extensions are supported. For post-setup scripts just create a folder `scripts/setup` in generic volume `/u01`, mount a dedicated volume `/u01/scripts/setup` or extend the image to include scripts in this directory. The location is also represented under the symbolic link `/docker-entrypoint-initdb.d`. This is done to provide synergy with other Docker images. The user is free to decide whether he wants to put his setup scripts under `/u01/scripts/setup` or `/docker-entrypoint-initdb.d`.

After the OUD instance is setup the scripts in those folders will be executed against the instance in the container. LDIF files (`ldif`) will be loaded using `ldapmodify` as *cn=Directory Manager* (ADMIN_USER). CONF files (`conf`) are interpreted as `dsconfig` batch files and will be executed accordingly. Shell scripts will be executed as the current user (oracle). To ensure proper order it is recommended to prefix your scripts with a number. For example `01_instance.conf`, `02_schema_extention.ldif`, etc.

## Frequently asked questions
Please see [FAQ.md](./FAQ.md) for frequently asked questions.

## Issues
Please file your bug reports, enhancement requests, questions and other support requests within [Github's issue tracker](https://help.github.com/articles/about-issues/):

* [Existing issues](https://github.com/oehrlis/docker/issues)
* [submit new issue](https://github.com/oehrlis/docker/issues/new)

## License
oehrlis/docker is licensed under the GNU General Public License v3.0. You may obtain a copy of the License at <https://www.gnu.org/licenses/gpl.html>.

To download and run Oracle Unified Directory, Oracle Directory Server Enterprise Edition or any other Oracle product, regardless whether inside or outside a Docker container, you must download the binaries from the Oracle website and accept the license indicated at that page. See [OTN Developer License Terms](http://www.oracle.com/technetwork/licenses/standard-license-152015.html) and [Oracle Database Licensing Information User Manual](https://docs.oracle.com/database/122/DBLIC/Licensing-Information.htm#DBLIC-GUID-B6113390-9586-46D7-9008-DCC9EDA45AB4)
