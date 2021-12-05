#!/bin/bash
# -----------------------------------------------------------------------------
# Trivadis - Part of Accenture, Platform Factory - Transactional Data Platform
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------------
# Name.......: saveOUD.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2019.05.06
# Revision...:  
# Purpose....: Script to save Oracle database Docker images
# Notes......: 
# Reference..: --
# License....: Apache License Version 2.0, January 2004 as shown
#              at http://www.apache.org/licenses/
# -----------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# -----------------------------------------------------------------------------

# - Customization -----------------------------------------------------------
DOCKER_LOCAL_USER=${DOCKER_LOCAL_USER:-"oracle"}
DOCKER_LOCAL_REPO=${DOCKER_LOCAL_REPO:-"oud"}
DOCKER_IMAGES=${DOCKER_VOLUME_BASE}/../images
SCRIPT_NAME=$(basename $0)
RELEASES="$@"
# - End of Customization ----------------------------------------------------

# - Default Values ----------------------------------------------------------
DOCKER_BUILD_BASE="$(cd $(dirname $0)/.. 2>&1 >/dev/null; pwd -P)"
# - EOF Default Values ------------------------------------------------------

CURRENT_DIR=$(pwd)
if [ $# -eq 0 ]; then
    echo "INFO : Usage, ${SCRIPT_NAME} <RELEASES>"
    echo "INFO : <RELEASES> on or more Oracle images to save. (default NONE)"
    echo "INFO : Images are available for the folloging Oracle releases:"
    for i in $(docker images --filter=reference="${DOCKER_LOCAL_USER}/${DOCKER_LOCAL_REPO}:*" --format "{{.Tag}}") ; do
        echo "INFO : $i "
    done
else
    # loop over the build string's from the command line
    for TAG in $(echo $RELEASES|sed s/\,/\ /g); do
        echo " save image ${DOCKER_LOCAL_USER}/${DOCKER_LOCAL_REPO}:$TAG"
        time docker save ${DOCKER_LOCAL_USER}/${DOCKER_LOCAL_REPO}:$TAG |gzip -c >${DOCKER_IMAGES}/${DOCKER_LOCAL_USER}_${DOCKER_LOCAL_REPO}_$TAG.tar.gz
    done
    cd $CURRENT_DIR # go back to initial working directory
fi
# --- EOF -------------------------------------------------------------------