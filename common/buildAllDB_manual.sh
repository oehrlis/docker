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
DOCKER_USER=oracle
DOCKER_REPO=database
echo "--------------------------------------------------------------------------------"
echo " Build all image from $DOCKER_BUILD_DIR...."
orarepo_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' orarepo)

# get the latest oraclelinux slim image
docker pull oraclelinux:7-slim

# build Database Containers
cd $DOCKER_BUILD_DIR/OracleDatabase
for major in 1?.0.?.?; do
    cd $DOCKER_BUILD_DIR/OracleDatabase/$major
        for i in *.Dockerfile; do
            version=$(echo $i|sed 's/\.Dockerfile//')
            echo "### Build $version #######################################################"
            time docker build --add-host=orarepo:${orarepo_ip} -t ${DOCKER_USER}/${DOCKER_REPO}:$version -f $i .
        done
    docker image prune --force
done
# --- EOF -------------------------------------------------------------------
