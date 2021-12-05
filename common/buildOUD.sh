#!/bin/bash
# -----------------------------------------------------------------------------
# Trivadis - Part of Accenture, Platform Factory - Transactional Data Platform
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------------
# Name.......: buildOUD.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2019.05.06
# Revision...:  
# Purpose....: Build script to build Oracle database Docker image
# Notes......: 
# Reference..: --
# License....: Apache License Version 2.0, January 2004 as shown
#              at http://www.apache.org/licenses/
# -----------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# -----------------------------------------------------------------------------

# - Customization -----------------------------------------------------------
DOCKER_USER=${DOCKER_USER:-"oracle"}
DOCKER_REPO=${DOCKER_REPO:-"oud"}
BUILD_FLAG=${BUILD_FLAG:-""}
DOCKER_BASE_IMAGE="oraclelinux:7-slim"
SCRIPT_NAME=$(basename $0)
RELEASES="$@"
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

#export DOCKER_BUILDKIT=1
# - EOF Default Values ------------------------------------------------------

CURRENT_DIR=$(pwd)
if [ $# -eq 0 ]; then
    echo "INFO : Usage, ${SCRIPT_NAME} <RELEASES>"
    echo "INFO : <RELEASES> on or more Oracle release to build. (default NONE)"
    echo "INFO : Build files are available for the folloging Oracle releases:"
    for i in $(ls ${DOCKER_BUILD_BASE}/OracleOUD/*/*Dockerfile) ; do
        j=$(basename $i)
        h=$(basename $(dirname $i))
        if [ $j == "Dockerfile" ]; then
            echo "INFO : ${h}_latest"
        else
            echo "INFO : $(basename $i .Dockerfile)"
        fi
    done
    echo
else
    echo "INFO : try to pull latest ${DOCKER_BASE_IMAGE}"
    # get the latest base image
    docker pull ${DOCKER_BASE_IMAGE}

    # loop over the build string's from the command line
    for BUILD_VERSION in $(echo $RELEASES|sed s/\,/\ /g); do
        # get the DOCKER_FILES based on the build / release string
        if [[ "$BUILD_VERSION" =~ ^.*latest ]]; then    # check if the build string includes latest
            release=$(echo $BUILD_VERSION|cut -d_ -f1)  # get the release from the build string
            DOCKER_FILE=$(ls ${DOCKER_BUILD_BASE}/OracleOUD/$release/Dockerfile)
        else
            DOCKER_FILE=$(ls ${DOCKER_BUILD_BASE}/OracleOUD/*/*${BUILD_VERSION}.Dockerfile)
        fi
        if [ -f $DOCKER_FILE ]; then
            echo "INFO : Build docker images $BUILD_VERSION"
            echo "INFO : from Dockerfile=${DOCKER_FILE}"
            DOCKER_BUILD_DIR=$(dirname $DOCKER_FILE)
            cd ${DOCKER_BUILD_DIR}  # change working directory
            time docker build ${BUILD_FLAG} ${ORAREPO_FLAG} -t ${DOCKER_USER}/${DOCKER_REPO}:$BUILD_VERSION -f $DOCKER_FILE .
            docker image prune --force
        else
            echo "WARN : Dockerfile $DOCKER_FILE not available"
        fi
    done
    cd $CURRENT_DIR # go back to initial working directory
fi

# --- EOF --------------------------------------------------------------