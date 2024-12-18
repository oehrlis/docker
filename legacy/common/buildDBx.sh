#!/bin/bash
# ------------------------------------------------------------------------------
# Trivadis - Part of Accenture, Platform Factory - Transactional Data Platform
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ------------------------------------------------------------------------------
# Name.......: buildDB.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2019.05.06
# Revision...:  
# Purpose....: Build script to build Oracle database Docker image
# Notes......: 
# Reference..: --
# License....: Apache License Version 2.0, January 2004 as shown
#              at http://www.apache.org/licenses/
# ------------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# ------------------------------------------------------------------------------

# - Customization --------------------------------------------------------------
DOCKER_USER=${DOCKER_USER:-"trivadis"}
DOCKER_REPO=${DOCKER_REPO:-"ora_db"}
BUILD_FLAG=${BUILD_FLAG:-""}
ORAREPO=${ORAREPO:-"orarepo"}
DOCKER_BASE_IMAGE=${DOCKER_BASE_IMAGE:-"oraclelinux:8"}
SCRIPT_NAME=$(basename $0)
RELEASES="$@"
#BUILD_PLATFORMS="arm64"
#BUILD_PLATFORMS="amd64"
BUILD_PLATFORMS="arm64 amd64"
# - End of Customization -------------------------------------------------------

# - Default Values -------------------------------------------------------------
DOCKER_BUILD_BASE="$(cd $(dirname $0)/.. 2>&1 >/dev/null; pwd -P)"
orarepo_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' orarepo 2>/dev/null)
ORAREPO=${ORAREPO:-${orarepo_ip}}
if [ -n "$ORAREPO" ]; then
    ORAREPO_FLAG="--add-host=orarepo:${ORAREPO}"
else
    ORAREPO_FLAG=""
fi

# - EOF Default Values ---------------------------------------------------------

CURRENT_DIR=$(pwd)
if [ $# -eq 0 ]; then
    echo "INFO : Usage, ${SCRIPT_NAME} <RELEASES>"
    echo "INFO : <RELEASES> on or more Oracle release to build. (default NONE)"
    echo "INFO : Build files are available for the folloging Oracle releases:"
    for i in $(ls ${DOCKER_BUILD_BASE}/OracleDatabase/*/*Dockerfile) ; do
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
    # loop over the build string's from the command line
    for BUILD_VERSION in $(echo $RELEASES|sed s/\,/\ /g); do
        # get the DOCKER_FILES based on the build / release string
        if [[ "$BUILD_VERSION" =~ ^.*latest ]]; then    # check if the build string includes latest
            release=$(echo $BUILD_VERSION|cut -d_ -f1)  # get the release from the build string
            DOCKER_FILE=$(ls ${DOCKER_BUILD_BASE}/OracleDatabase/$release/Dockerfile|head -1)
        else
            DOCKER_FILE=$(ls ${DOCKER_BUILD_BASE}/OracleDatabase/*/*${BUILD_VERSION}.Dockerfile|head -1 )
        fi
        if [ -f $DOCKER_FILE ]; then
            DOCKER_BUILD_DIR=$(dirname $DOCKER_FILE)
            cd ${DOCKER_BUILD_DIR}  # change working directory
            #for p in ${BUILD_PLATFORMS}; do
                echo "INFO : -----------------------------------------------------------------"
                echo "INFO : Build docker images $BUILD_VERSION for plattform linux/arm64,linux/amd64"
                echo "INFO : from Dockerfile   => ${DOCKER_FILE}"
                echo "INFO : with base image   => ${DOCKER_BASE_IMAGE}"
                echo "INFO : using build flags => ${BUILD_FLAG}"
                echo "INFO : as Docker TAG ${DOCKER_USER}/${DOCKER_REPO}"
                echo "INFO : ORAREPO           => ${ORAREPO}"
                echo "INFO : -----------------------------------------------------------------"
                time docker buildx build ${DOCKER_BUILD_DIR} ${BUILD_FLAG} --push \
                    --build-arg "BASE_IMAGE=${DOCKER_BASE_IMAGE}" \
                    --build-arg "ORAREPO=${ORAREPO}" \
                    --tag ${DOCKER_USER}/${DOCKER_REPO}:${BUILD_VERSION} \
                    --platform=linux/arm64 --file $DOCKER_FILE
                docker pull ${DOCKER_USER}/${DOCKER_REPO}:$BUILD_VERSION
                docker tag ${DOCKER_USER}/${DOCKER_REPO}:$BUILD_VERSION oracle/database:$BUILD_VERSION
                docker buildx prune --force
            #done
        else
            echo "WARN : Dockerfile $DOCKER_FILE not available"
        fi
    done
    cd -
fi
# --- EOF --------------------------------------------------------------