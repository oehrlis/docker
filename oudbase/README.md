# Docker Base Image for Trivadis Engineering
Docker base image used for miscellaneous Oracle Directory Service engineering .

## Content

This docker image is based on the official Oracle Linux slim image ([oraclelinux](https://hub.docker.com/r/_/oraclelinux/)). It has been extended with the following Linux packages and configuration:

* Upgrade of all installed packages to the latest release (yum upgrade)
* Install the following additional packages including there dependencies:

    * *hostname* Utility to set/show the host name or domain name
    * *which* Displays where a particular program in your path is located
    * *unzip* A utility for unpacking zip files
    * *zip* A file compression and packaging utility compatible with PKZIP
    * *tar* A GNU file archiving program
    * *gzip* The GNU data compression program
    * *procps-ng* System and process monitoring utilities
* Dedicated groups for user *oracle*, oinstall (gid 1000), osdba (gid 1010), osoper (gid 1020), osbackupdba (gid 1030), oskmdba (gid 1040), osdgdba (gid 1050)
* Operating system user *oracle* (uid 1000)
* Oracle Inventory file *oraInst.loc* in *$ORACLE_DATA/etc/oraInst.loc*
* Generic ResponseFile *install.rsp* in *$ORACLE_DATA/etc/install.rsp* used for OUD and FMW installations
* Create of Oracle OFA Directories see below
* Install OUD Base environment scripts from (www.oradba.ch) 

The purpose of this image is provide base image for other docker images for OUD Directory, Proxy Server or OUDSM. The following docker images are based on this images or build with similar structures.

   * [oehrlis/docker-oud](https://github.com/oehrlis/docker-oud)
   * [oehrlis/docker-oudsm](https://github.com/oehrlis/docker-oudsm)
   * [oehrlis/docker-odsee](https://github.com/oehrlis/docker-odsee)

### Environment Variable and Directories
The following environment variable have been used for the installation. In particular it is possible to modify the variables ORACLE_ROOT, ORACLE_DATA and ORACLE_BASE via *build-arg* during image build to have a different directory structure. All other parameters are only relevant for the creation of the container. They may be modify via `docker run` environment variables.

Environment variable | Value / Directories                    | Modifiable   | Comment
-------------------- | -------------------------------------- | -------------| ---------------
ORACLE_ROOT          | `/u00`                                  | docker build | Root directory for all the Oracle software
ORACLE_BASE          | `$ORACLE_ROOT/app/oracle`              | docker build | Oracle base directory
n/a                  | `$ORACLE_BASE/product`                   | no           | Oracle product base directory
ORACLE_DATA          | `/u01`                                  | docker build | Root directory for the persistent data eg. OUD instances, OUDSM domain etc. A docker volumes must be defined for */u01*
INSTANCE_BASE        | `$ORACLE_DATA/instances`               | no           | Base directory for OUD instances
OUD_INSTANCE_INIT    | `$ORACLE_DATA/scripts`                   | docker run   | Directory for the instance configuration scripts
OUD_INSTANCE_BASE    | `$ORACLE_DATA/instances`                 | no           | Base directory for OUD instances
OUD_ADMIN_BASE       | `$ORACLE_DATA/admin`                     | no           | Base directory for OUD admin directories
OUD_BACKUP_BASE      | `$ORACLE_DATA/backup`                    | no           | Base directory for OUD backups
ETC_CORE             | `$ORACLE_BASE/local/etc`               | no           | OUD base core etc directory with some core configuration files
ETC_BASE             | `$ORACLE_DATA/etc`                     | no           | Oracle etc directory with configuration files
LOG_BASE             | `$ORACLE_DATA/log`                     | no           | Oracle log directory with log files
DOWNLOAD             | `/tmp/download`                         | no           | Temporary download directory, will be removed after build
DOCKER_BIN           | `/opt/docker/bin`                       | no           | Docker build and setup scripts


In general it does not make sense to change all possible variables.

### Scripts to Build and Setup
The following scripts are used either during Docker image build or while setting up and starting the container.

| Script                    | Purpose
| ------------------------- | ----------------------------------------------------------------------------
| `build.sh`                 | Build helper script for docker oudbase image
| `setup_oudbase.sh`         | Setup script for the Oracle environment when creating Docker images

## Installation and build
The docker image can be build manually based on [oehrlis/docker-tvd](https://github.com/oehrlis/docker-oudbase) from GitHub or pull from the public repository [oehrlis/oudbase](https://hub.docker.com/r/oehrlis/oudbase/) on DockerHub.

* Manual build the image based on the source from GitHub ([oehrlis/docker-oudbase](https://github.com/oehrlis/docker-oudbase)).

        docker build -t oehrlis/oudbase .

* Pull the image from Docker hub.

        docker pull oehrlis/oudbase

* Create a new named container and run it interactive (-i -t)

        docker run -v [<host mount point>:]/u01 -h oudbase --name OUD-engineering oehrlis/oudbase
        docker start -ai OUD-engineering

## Issues
Please file your bug reports, enhancement requests, questions and other support requests within [Github's issue tracker](https://help.github.com/articles/about-issues/):

* [Existing issues](https://github.com/oehrlis/docker-oudbase/issues)
* [submit new issue](https://github.com/oehrlis/docker-oudbase/issues/new)

## License
docker-oudbase is licensed under the Apache License, Version 2.0. You may obtain a copy of the License at <http://www.apache.org/licenses/LICENSE-2.0>.

To download and run Oracle Unifified Directory , regardless whether inside or outside a Docker container, you must download the binaries from the Oracle website and accept the license indicated at that page. See [OTN Developer License Terms](http://www.oracle.com/technetwork/licenses/standard-license-152015.html) and [Oracle Database Licensing Information User Manual](https://docs.oracle.com/database/122/DBLIC/Licensing-Information.htm#DBLIC-GUID-B6113390-9586-46D7-9008-DCC9EDA45AB4)
