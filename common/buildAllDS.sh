#!/bin/bash
# -----------------------------------------------------------------------------
# Trivadis - Part of Accenture, Platform Factory - Transactional Data Platform
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
# License....: Apache License Version 2.0, January 2004 as shown
#              at http://www.apache.org/licenses/
# -----------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# -----------------------------------------------------------------------------

# - Customization -----------------------------------------------------------
DOCKER_USER=${DOCKER_USER:-"oracle"}
DOCKER_REPO=${DOCKER_REPO:-"oud"}
DOCKER_PROJECTS="OUD OUDSM Database"
DOCKER_TVD_USER=${DOCKER_TVD_USER:-"trivadis"}
DOCKER_TVD_REPO=${DOCKER_TVD_REPO:-"ora_oud"}
KEEP_VERSIONS=${KEEP_VERSIONS:-""}
DOCKER_IMAGES=${DOCKER_VOLUME_BASE}/../images
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
i=0
j=1
#export DOCKER_BUILDKIT=1
# - EOF Default Values ------------------------------------------------------

CURRENT_DIR=$(pwd)          # save current directory
echo "INFO : try to pull latest ${DOCKER_BASE_IMAGE}"
# get the latest base image
docker pull ${DOCKER_BASE_IMAGE}

# lets count the images
for n in ${DOCKER_PROJECTS}; do
    i=$((i+$(ls -1q $DOCKER_BUILD_BASE/Oracle${n}/*/*.Dockerfile|wc -l|sed 's/ *//g')))
done

for n in ${DOCKER_PROJECTS}; do
    for DOCKER_FILE in $(ls $DOCKER_BUILD_BASE/Oracle${n}/*/*.Dockerfile); do
        BUILD_VERSION=$(basename $DOCKER_FILE .Dockerfile)
        DOCKER_REPO=$(echo "$n" | tr '[:upper:]' '[:lower:]')

        echo "################################################################"
        echo "INFO : Build docker images $BUILD_VERSION [$j/$i]"
        echo "INFO : from Dockerfile=${DOCKER_FILE}"
        echo "INFO : for repository  ${DOCKER_USER}/${DOCKER_REPO}"
        DOCKER_BUILD_DIR=$(dirname $DOCKER_FILE)
        cd ${DOCKER_BUILD_DIR}  # change working directory
    echo    docker build ${ORAREPO_FLAG} -t ${DOCKER_USER}/${DOCKER_REPO}:$BUILD_VERSION -f $DOCKER_FILE .
        echo "INFO : tag image ${DOCKER_USER}/${DOCKER_REPO}:$BUILD_VERSION as ${DOCKER_TVD_USER}/${DOCKER_TVD_REPO}:$BUILD_VERSION"
    echo    docker tag ${DOCKER_USER}/${DOCKER_REPO}:$BUILD_VERSION ${DOCKER_TVD_USER}/${DOCKER_TVD_REPO}:$BUILD_VERSION
        echo "INFO : push image ${DOCKER_TVD_USER}/${DOCKER_TVD_REPO}:$BUILD_VERSION"
    echo    docker push ${DOCKER_TVD_USER}/${DOCKER_TVD_REPO}:$BUILD_VERSION
        echo "INFO : untag image ${DOCKER_TVD_USER}/${DOCKER_TVD_REPO}:$BUILD_VERSION"
    echo    docker rmi ${DOCKER_TVD_USER}/${DOCKER_TVD_REPO}:$BUILD_VERSION
    echo    docker image prune --force
    echo    echo "INFO : save image ${DOCKER_USER}/${DOCKER_REPO}:$BUILD_VERSION to ${DOCKER_IMAGES}/${DOCKER_USER}_${DOCKER_REPO}_$BUILD_VERSION.tar.gz"
    echo    docker save ${DOCKER_USER}/${DOCKER_REPO}:$BUILD_VERSION |gzip -c >${DOCKER_IMAGES}/${DOCKER_USER}_${DOCKER_REPO}_$BUILD_VERSION.tar.gz

        if [ -n "$BUILD_VERSION" ] && [[ $KEEP_VERSIONS == *"$BUILD_VERSION"* ]]; then
            echo "INFO : keep version $BUILD_VERSION"
        else
            echo "INFO : remove version $BUILD_VERSION"
    echo        docker rmi ${DOCKER_USER}/${DOCKER_REPO}:$BUILD_VERSION 
        fi
        ((j++))                 # increment counter
    done
done
cd $CURRENT_DIR # go back to initial working directory
# --- EOF -------------------------------------------------------------------