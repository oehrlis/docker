#!/bin/bash
# -----------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------------
# Name.......: pushDB.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2019.05.06
# Revision...:  
# Purpose....: Build script to push Oracle database Docker images
# Notes......: 
# Reference..: --
# License....: Licensed under the Universal Permissive License v 1.0 as 
#              shown at http://oss.oracle.com/licenses/upl.
# -----------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# -----------------------------------------------------------------------------

# - Customization -----------------------------------------------------------
DOCKER_LOCAL_USER=${DOCKER_LOCAL_USER:-"oracle"}
DOCKER_LOCAL_REPO=${DOCKER_LOCAL_REPO:-"database"}
DOCKER_TVD_USER=${DOCKER_TVD_USER:-"trivadis"}
DOCKER_TVD_REPO=${DOCKER_TVD_REPO:-"ora_db"}
SCRIPT_NAME=$(basename $0)
RELEASES="$@"
# - End of Customization ----------------------------------------------------

# - Default Values ----------------------------------------------------------
DOCKER_BUILD_BASE="$(cd $(dirname $0)/.. 2>&1 >/dev/null; pwd -P)"
# - EOF Default Values ------------------------------------------------------

CURRENT_DIR=$(pwd)
if [ $# -eq 0 ]; then
    echo "INFO : Usage, ${SCRIPT_NAME} <RELEASES>"
    echo "INFO : <RELEASES> on or more Oracle release to push. (default NONE)"
    echo "INFO : Images are available for the folloging Oracle releases:"
    for i in $(docker images --filter=reference="${DOCKER_LOCAL_USER}/${DOCKER_LOCAL_REPO}:*" --format "{{.Tag}}") ; do
        echo "INFO : $i "
    done
else
    # loop over the build string's from the command line
    for TAG in $(echo $RELEASES|sed s/\,/\ /g); do
        echo "INFO : tag image ${DOCKER_LOCAL_USER}/${DOCKER_LOCAL_REPO}:$TAG"
        docker tag ${DOCKER_LOCAL_USER}/${DOCKER_LOCAL_REPO}:$TAG ${DOCKER_TVD_USER}/${DOCKER_TVD_REPO}:$TAG
        echo "INFO : push image ${DOCKER_TVD_USER}/${DOCKER_TVD_REPO}:$TAG"
        docker push ${DOCKER_TVD_USER}/${DOCKER_TVD_REPO}:$TAG
        echo "INFO : untag image ${DOCKER_TVD_USER}/${DOCKER_TVD_REPO}:$TAG"
        docker rmi ${DOCKER_TVD_USER}/${DOCKER_TVD_REPO}:$TAG
    done
    cd $CURRENT_DIR # go back to initial working directory
fi
# --- EOF -------------------------------------------------------------------