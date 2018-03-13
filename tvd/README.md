# Docker Base Image for Trivadis Engineering
Trivadis Docker base image for Oracle Instance Clients, Oracle Databases, Unified Directory, WebLogic and more.

## Content
This docker image is based on the official Oracle Linux slim image ([oraclelinux](https://hub.docker.com/r/_/oraclelinux/)). It has been extended with the following Linux packages and configuration:

* Upgrade of all installed packages to the latest release (yum upgrade)
* Dedicated groups for user *oracle*, oinstall (gid 1000), osdba (gid 1010), osoper (gid 1020), osbackupdba (gid 1030), oskmdba (gid 1040), osdgdba (gid 1050)
* Operating system user *oracle* (uid 1000)
* Create of basic Oracle OFA directories see below.

The purpose of this image is provide common base image for any kind of engineering with Oracle Database, Oracle Unified Directory and Oracle Fusion Middleware. The following docker images are based on this images or build with similar structures.

   * [oehrlis/oudbase](https://github.com/oehrlis/docker/tree/master/oudbase)

## Environment Variable and Directories

The following environment variable have been used for the installation:

Environment variable | Value / Directories         | Comment
-------------------- | --------------------------- | ---------------
ORACLE_ROOT          | ```/u00```                  | Root directory for all the Oracle software
ORACLE_BASE          | ```/u00/app/oracle```       | Oracle base directory
n/a                  | ```$ORACLE_BASE/product```  | Oracle product base directory
ORACLE_BASE          | ```$ORACLE_BASE/local```    | Oracle base directory
ORACLE_DATA          | ```/u01```                  | Root directory for the persistent data eg. database, OUD instances etc. A docker volumes must be defined for /u01

### Scripts to Build and Setup
The following scripts are used either during Docker image build or while setting up and starting the container. The scripts itself are located in the repository root folder [scripts](). Due to this the build context must be the repository root.

| Script                    | Purpose
| ------------------------- | ----------------------------------------------------------------------------
| ``build.sh```             | Build helper script for docker tvd image
| ```setup_tvd.sh```        | Setup script for the Oracle environment when creating Docker images

## Installation and build
The docker image can be build manually based on [oehrlis/docker](https://github.com/oehrlis/docker) from GitHub or pull from the public repository [oehrlis/tvd](https://hub.docker.com/r/trivadis/tvdbase/) on DockerHub.

* Manual build the image based on the source from GitHub ([oehrlis/tvd](https://github.com/oehrlis/docker/tree/master/tvd)) with docker build

        cd tvd
        docker build -t oehrlis/tvd .

* or with the provided build script

        ./tvd/build.sh

* Pull the image from Docker hub.

        docker pull oehrlis/tvd

* Create a new named container and run it interactive (-i -t)

        docker run -v [<host mount point>:]/u01 --name ttc oehrlis/tvd

## Issues
Please file your bug reports, enhancement requests, questions and other support requests within [Github's issue tracker](https://help.github.com/articles/about-issues/):

* [Existing issues](https://github.com/oehrlis/docker/issues)
* [submit new issue](https://github.com/oehrlis/docker/issues/new)

## License
oehrlis/docker is licensed under the GNU General Public License v3.0. You may obtain a copy of the License at <https://www.gnu.org/licenses/gpl.html>.

To download and run Oracle Unified Directory, Oracle Directory Server Enterprise Edition or any other Oracle product, regardless whether inside or outside a Docker container, you must download the binaries from the Oracle website and accept the license indicated at that page. See [OTN Developer License Terms](http://www.oracle.com/technetwork/licenses/standard-license-152015.html) and [Oracle Database Licensing Information User Manual](https://docs.oracle.com/database/122/DBLIC/Licensing-Information.htm#DBLIC-GUID-B6113390-9586-46D7-9008-DCC9EDA45AB4)
