# Docker Images from OraDBA

This repository contains Dockerfiles and samples to build Docker images mainly for Oracle Directory Server products and open source projects. The different Dockerfiles and build scripts are maintained by [OraDBA](http://www.oradba.ch) respectively [Trivadis AG](http://www.trivadis.com) and *do not* represent official Oracle Build scripts. Oracle has its own official repository for [Oracle Docker images](https://github.com/oracle/docker-images) on GitHub. 

This project offers Dockerfiles to build Docker images for:
* Standalone Oracle Unified Directory 12.2.1.3.0 to setup and run Oracle Unified Directory [OUD](https://github.com/oehrlis/docker/tree/master/oud).
* Collocated Oracle Unified Directory 12.2.1.3.0 and Oracle Fusion Middleware Infrastructure 12.2.1.3.0 to setup and run an Oracle Unified Directory Server Manager [OUDSM](https://github.com/oehrlis/docker/tree/master/oudsm).
* Oracle Directory Server Enterprise Edition 11.1.1.7.2 to setup and run Oracle Directory Server Enterprise Edition [ODSEE](https://github.com/oehrlis/docker/tree/master/odsee).
* Oracle Java Server JRE 1.8.0 u162 (which includes necessary JDK bits for backend Java based solutions) [Java](https://github.com/oehrlis/docker/tree/master/java)

And Open Source projects:

 - [OUD Base](https://github.com/oehrlis/docker/tree/master/oudbase)
 - [Trivadis Base](https://github.com/oehrlis/docker/tree/master/tvd)

## Pre-built Images with Commercial Software

Due to the licensing conditions of Oracle there are no pre-built images with commercial software available. Nevertheless the Dockerfiles in this repository depend on Oracle Linux image with is either available via [Oracle Container Registry](https://container-registry.oracle.com) server or on the [Docker Store](https://store.docker.com/search?certification_status=certified&q=oracle&source=verified&type=image).

## Support

There is no official support for the Dockerfiles and build scripts within this repository. They basically are provided as they are. Nevertheless, a [GitHub issue](https://github.com/oehrlis/docker/issues) can be opened for questions and problems around the Dockerfiles and build script.

For support and certification information, please consult the documentation for each product. eg. [Oracle Unified Directory 12.2.1.3.0](https://https://docs.oracle.com/middleware/12213/oud/docs.htm) and [Oracle Directory Server Enterprise Edition](https://docs.oracle.com/cd/E29127_01/index.htm) Alternatiely you may visit the [OTN Community OUD & ODSEE Space](https://community.oracle.com/community/fusion_middleware/identity_management/oracle_directory_server_enterprise_edition_sun_dsee) to get community support. Official Oracle product support is available through [My Oracle Support](https://support.oracle.com/). 

## License

To download and run Oracle Unified Directory, Oracle Directory Server Enterprise Edition and Oracle JDK, regardless whether inside or outside a Docker container, you must download the binaries from the Oracle website and accept the license indicated at that page.
