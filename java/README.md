# Docker Java Image for Trivadis Engineering
Docker Java-Image with Oracle Server JRE 8 Update 152 as basis for Trivadis Engineering, especially for the work on Oracle Unified Directory (OUD) and Docker.

## Content

This docker image is based on the official Oracle Linux slim image ([oraclelinux](https://hub.docker.com/r/_/oraclelinux/)). It has been extended with the following Linux packages and configuration:

* Upgrade of all installed packages to the latest release (yum upgrade)
* Install the following additional packages including there dependencies:
    * *unzip* A utility for unpacking zip files
    * *zip* A file compression and packaging utility compatible with PKZIP
    * *tar* A GNU file archiving program
* Install Oracle Server JRE 8 update 152

The purpose of this image is provide base image for miscellaneous engineering work on Oracle Unified Directory (OUD) and Docker. The following docker images are indirectly based on this images or build with similar structures.

   * [oehrlis/docker-oud](https://github.com/oehrlis/docker-oud)
   * [oehrlis/docker-oudsm](https://github.com/oehrlis/docker-oudsm)

## Environment Variable and Directories

The following environment variable have been used for the installation:

Environment variable | Value / Directories         | Comment
-------------------- | --------------------------- | ---------------
DOWNLOAD             | ```/tmp/download```         | Temporary download directory, will be removed after build
DOCKER_BIN           | ```/opt/docker/bin```       | Docker build and setup scripts
JAVA_DIR             | ```/usr/java```             | Base directory for java home location
JAVA_HOME            | ```$JAVA_DIR/jdk1.8.0_152```| Java home directory

## Installation and Build
The docker image has to be build manually based on [oehrlis/docker-java](https://github.com/oehrlis/docker-java) from GitHub. Due to license restrictions from Oracle I can not provide this image on a public Docker repository (see [OTN Developer License Terms](http://www.oracle.com/technetwork/licenses/standard-license-152015.html)). The required Software has to be downloaded prior image build. Alternatively it is possible to specify MOS credentials in ```scripts/.netrc``` or via build arguments.

### Obtaining Product Distributions
The Oracle Software required to setup the docker image is not public available. It is subject to Oracle's license terms. For this reason a valid license is required (eg. [OTN Developer License Terms](http://www.oracle.com/technetwork/licenses/standard-license-152015.html)). In addition, Oracle's license terms and conditions must be accepted before downloading.

The following software is required for the Oracle Unified Directory docker image:
* Oracle Java Development Kit (JDK) 1.8 (1.8u152)

The software can either be downloaded from [My Oracle Support (MOS)](https://support.oracle.com), [Oracle Technology Network (OTN)](http://www.oracle.com/technetwork/index.html) or [Oracle Software Delivery Cloud (OSDC)](http://edelivery.oracle.com). The following steps will refer to the MOS software download to simplify the build process.

### Manual download Software
Simplest method to build the Java image is to manually download the required software. However this will lead to bigger docker images, since the software is copied during build, which temporary blow up the container file-system. But its more safe because you do not have to store any MOS credentials.

The corresponding links and checksum can be found in ```*.download``` files in the ```software```folder. Alternatively the Oracle Support Download Links:
* Oracle Java Server JRE 8 update 152 [Patch 26595894](https://updates.oracle.com/ARULink/PatchDetails/process_form?patch_num=26595894) or [direct](https://updates.oracle.com/Orion/Services/download/p26595894_180152_Linux-x86-64.zip?aru=21611278&patch_file=p26595894_180152_Linux-x86-64.zip)

Copy the file to the ```software```folder.

    cp p26595894_180152_Linux-x86-64.zip.zip docker-java/software

Build the docker image either by using ```docker build``` or ```build.sh```.

    docker build -t oehrlis/java .

    scripts/build.sh

### Automatic download with .netrc
The advantage of an automatic software download during build is the reduced image size. No additional image layers are created for the software and the final docker image is about 50MB smaller. But the setup script (```setup_java.sh```) requires the MOS credentials to download the software with [curl](https://linux.die.net/man/1/curl). Curl does read the credentials from the ```.netrc``` file in ```scripts``` folder. The ```.netrc``` file will be copied to ```/opt/docker/bin/.netrc```, but it will be removed at the end of the build.

Create a ```.netrc``` file with the credentials for *login.oracle.com*.

    echo "machine login.oracle.com login <MOS_USER> password <MOS_PASSWORD>" >docker-oud/scripts/.netrc

Build the docker image either by using ```docker build``` or ```build.sh```.

        docker build -t oehrlis/java .

        scripts/build.sh

### Automatic download with Build Arguments
This method is similar to the automatic download with ```.netrc``` file. Instead of manually creating a ```.netrc``` file it will created based on build parameter. Also with this method the ```.netrc``` file is deleted at the end.

Build the docker image with MOS credentials as arguments.

    docker build --build-arg MOS_USER=<MOS_USER> --build-arg MOS_PASSWORD=<MOS_PASSWORD> -t oehrlis/java .

### Using the Image 
Since this is more of a basic image for further development work, it makes only limited sense to create a container. Nevertheless it is simple to just create a container by executing *docker run*.

        docker run -it --name java oehrlis/java
        
        docker run -it --name java oehrlis/java java -version

## Issues
Please file your bug reports, enhancement requests, questions and other support requests within [Github's issue tracker](https://help.github.com/articles/about-issues/):

* [Existing issues](https://github.com/oehrlis/docker-java/issues)
* [submit new issue](https://github.com/oehrlis/docker-java/issues/new)

## License
docker-oud is licensed under the Apache License, Version 2.0. You may obtain a copy of the License at <http://www.apache.org/licenses/LICENSE-2.0>.

To download and run Oracle Unifified Directory , regardless whether inside or outside a Docker container, you must download the binaries from the Oracle website and accept the license indicated at that page. See [OTN Developer License Terms](http://www.oracle.com/technetwork/licenses/standard-license-152015.html) and [Oracle Database Licensing Information User Manual](https://docs.oracle.com/database/122/DBLIC/Licensing-Information.htm#DBLIC-GUID-B6113390-9586-46D7-9008-DCC9EDA45AB4)
