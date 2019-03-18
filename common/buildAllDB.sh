#!/bin/bash
# -----------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------------
# Name.......: buildAllDB.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2018.03.13
# Revision...:  
# Purpose....: Build script to build all trivadis/xxx docker images
# Notes......: 
# Reference..: --
# License....: Licensed under the Universal Permissive License v 1.0 as 
#              shown at http://oss.oracle.com/licenses/upl.
# -----------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# -----------------------------------------------------------------------------

# - Customization -----------------------------------------------------------
# - End of Customization ----------------------------------------------------

# - Default Values ----------------------------------------------------------

DOCKER_BUILD_DIR="$(cd $(dirname $0)/.. 2>&1 >/dev/null; pwd -P)"
DOCKER_USER=trivadis
DOCKER_REPO=ora_db
echo "--------------------------------------------------------------------------------"
echo " Build all image from $DOCKER_BUILD_DIR...."
orarepo_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' orarepo)

# get the latest oraclelinux slim image
docker pull oraclelinux:7-slim

# build Database Containers
cd $DOCKER_BUILD_DIR/OracleDatabase
for version in 1?.?.?.?; do
    echo "### Build $version #######################################################"
    cd $DOCKER_BUILD_DIR/OracleDatabase/$version
    time docker build --add-host=orarepo:${orarepo_ip} --force-rm -t ${DOCKER_USER}/${DOCKER_REPO}:$version .
    time docker push ${DOCKER_USER}/${DOCKER_REPO}:$version
    docker tag oracle/database:$version ${DOCKER_USER}/${DOCKER_REPO}:$version
    docker image prune --force
done
# --- EOF -------------------------------------------------------------------