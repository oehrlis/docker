#!/bin/bash
# -----------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------------
# Name.......: buildDB.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2019.05.06
# Revision...:  
# Purpose....: Build script to build Oracle database Docker image
# Notes......: 
# Reference..: --
# License....: Licensed under the Universal Permissive License v 1.0 as 
#              shown at http://oss.oracle.com/licenses/upl.
# -----------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# -----------------------------------------------------------------------------

# - Customization -----------------------------------------------------------
BUILD_VERSION=${1:-"11.2.0.4"}
DOCKER_USER=oracle
DOCKER_REPO=database
DOCKER_BASE_IMAGE="oraclelinux:7-slim"
# - End of Customization ----------------------------------------------------

# - Default Values ----------------------------------------------------------
DOCKER_BUILD_BASE="$(cd $(dirname $0)/.. 2>&1 >/dev/null; pwd -P)"
DOCKER_BUILD_DIR=${DOCKER_BUILD_BASE}/OracleDatabase/${BUILD_VERSION}
orarepo_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' orarepo)
ORAREPO=${ORAREPO:-${orarepo_ip}}
# - EOF Default Values ------------------------------------------------------

if [ -d "${DOCKER_BUILD_DIR}" ]; then
    echo "--------------------------------------------------------------------------------"
    echo " Build image ${BUILD_VERSION} from ${DOCKER_BUILD_DIR}"
    echo " try to pull latest ${DOCKER_BASE_IMAGE}"
    # get the latest base image
    docker pull ${DOCKER_BASE_IMAGE}
    cd ${DOCKER_BUILD_DIR}
    echo " start to build ${BUILD_VERSION}"
    echo docker build --add-host=orarepo:${ORAREPO} -t ${DOCKER_USER}/${DOCKER_REPO}:$BUILD_VERSION .
    #docker image prune --force
    echo "--------------------------------------------------------------------------------"
    exit 0
else
    echo "--------------------------------------------------------------------------------"
    echo " Can not find build directory for version ${BUILD_VERSION}"
    echo "--------------------------------------------------------------------------------"
    exit 1
fi
# --- EOF -------------------------------------------------------------------