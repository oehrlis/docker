#!/bin/bash
# -----------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------------
# Name.......: buildAll.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2018.03.13
# Revision...:  
# Purpose....: Build script to build all oehrlis/xxx docker images
# Notes......: 
# Reference..: --
# License....: Licensed under the Universal Permissive License v 1.0 as 
#              shown at http://oss.oracle.com/licenses/upl.
# -----------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# -----------------------------------------------------------------------------

# - Customization -----------------------------------------------------------at ses
# - End of Customization ----------------------------------------------------

# - Default Values ----------------------------------------------------------

DOCKER_BUILD_DIR="$(cd $(dirname $0)/.. 2>&1 >/dev/null; pwd -P)"
echo "--------------------------------------------------------------------------------"
echo " Build all image from $DOCKER_BUILD_DIR...."
orarepo_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' orarepo)

# first build java
      --------------------------------------------------------------------------------
echo "### Build Java #################################################################"
cd $DOCKER_BUILD_DIR/OracleJava
$DOCKER_BUILD_DIR/OracleJava/java-8/build.sh

# build ODSEE
echo "### Build ODSEE ################################################################"
cd $DOCKER_BUILD_DIR/OracleODSEE/11.1.1.7.0
docker rmi oracle/odsee:11.1.1.7.0
docker build --add-host=orarepo:${orarepo_ip} -t oracle/odsee:11.1.1.7.171017 .
docker tag oracle/odsee:11.1.1.7.171017 oracle/odsee:11.1.1.7.0

# build OUD 11.1.2.3.0
echo "### Build OUD 11.1.2.3.0 #######################################################"
cd $DOCKER_BUILD_DIR/OracleOUD/11.1.2.3.0
docker build --add-host=orarepo:${orarepo_ip} -t oracle/oud:11.1.2.3.180116 -f Dockerfile.11.1.2.3.180116 .
docker build --add-host=orarepo:${orarepo_ip} -t oracle/oud:11.1.2.3.0 -f Dockerfile.11.1.2.3.0 .
docker build --add-host=orarepo:${orarepo_ip} -t oracle/oud:11.1.2.3.0.slim -f Dockerfile.slim .

echo "### Build OUD 12.2.1.3.0 #######################################################"
cd $DOCKER_BUILD_DIR/OracleOUD/12.2.1.3.0
docker build --add-host=orarepo:${orarepo_ip} -t oracle/oud:12.2.1.3.180322 .
docker build --add-host=orarepo:${orarepo_ip} -t oracle/oud:12.2.1.3.0 -f Dockerfile.12.2.1.3.0 .
docker build --add-host=orarepo:${orarepo_ip} -t oracle/oud:12.2.1.3.0.slim -f Dockerfile.slim .

# build OUDSM
echo "### Build OUDSM 12.2.1.3.0 #####################################################"
cd $DOCKER_BUILD_DIR/OracleOUDSM/12.2.1.3.0
docker build --add-host=orarepo:${orarepo_ip} -t oracle/oudsm:12.2.1.3.180417 .
docker build --add-host=orarepo:${orarepo_ip} -t oracle/oudsm:12.2.1.3.180116 -f Dockerfile.12.2.1.3.180116 .
docker build --add-host=orarepo:${orarepo_ip} -t oracle/oudsm:12.2.1.3.0.slim -f Dockerfile.slim .
