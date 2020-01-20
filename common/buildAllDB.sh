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
DOCKER_USER=${DOCKER_USER:-"oracle"}
DOCKER_REPO=${DOCKER_REPO:-"database"}
DOCKER_BASE_IMAGE="oraclelinux:7-slim"
SCRIPT_NAME=$(basename $0)
# - End of Customization ----------------------------------------------------

# - Default Values ----------------------------------------------------------
DOCKER_BUILD_BASE="$(cd $(dirname $0)/.. 2>&1 >/dev/null; pwd -P)"
orarepo_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' orarepo)
ORAREPO=${ORAREPO:-${orarepo_ip}}
if [ -n "$ORAREPO" ]; then
    ORAREPO_FLAG="--add-host=orarepo:${ORAREPO}"
else
    ORAREPO_FLAG=""
fi
export DOCKER_BUILDKIT=1
# - EOF Default Values ------------------------------------------------------

CURRENT_DIR=$(pwd)          # save current directory
echo "INFO : try to pull latest ${DOCKER_BASE_IMAGE}"
# get the latest base image
#docker pull ${DOCKER_BASE_IMAGE}
i=$(ls -1q $DOCKER_BUILD_BASE/OracleDatabase/*/*.Dockerfile|wc -l|sed 's/ *//g')
j=1
for DOCKER_FILE in $(ls $DOCKER_BUILD_BASE/OracleDatabase/*/*.Dockerfile); do
    BUILD_VERSION=$(basename $DOCKER_FILE .Dockerfile)
    echo "INFO : Build docker images $BUILD_VERSION [$j/$i]"
    echo "INFO : from Dockerfile=${DOCKER_FILE}"
    DOCKER_BUILD_DIR=$(dirname $DOCKER_FILE)
    cd ${DOCKER_BUILD_DIR}  # change working directory
    echo docker build ${ORAREPO_FLAG} -t ${DOCKER_USER}/${DOCKER_REPO}:$BUILD_VERSION -f $DOCKER_FILE .
    echo docker image prune --force
    ((j++))                 # increment counter
done
cd $CURRENT_DIR # go back to initial working directory
# --- EOF -------------------------------------------------------------------