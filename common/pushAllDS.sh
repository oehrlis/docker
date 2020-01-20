#!/bin/bash
# -----------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------------
# Name.......: pushAllDS.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2018.03.13
# Revision...:  
# Purpose....: Build script to push all directory server Docker images to trivadis/xxx
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
DOCKER_USER=${DOCKER_USER:-"trivadis"}
DOCKER_LOCAL_USER=${DOCKER_LOCAL_USER:-"oracle"}
LOCAL_REPO="oud oudsm odsee serverjre"

for r in ${LOCAL_REPO}; do
    DOCKER_ORA_REPO=$r
    DOCKER_TVD_REPO="ora_$r"
    echo "--------------------------------------------------------------------------------"
    echo " Process all ${DOCKER_LOCAL_USER}/${DOCKER_ORA_REPO}:* images ...."
    IMAGES=$(docker images --filter=reference="${DOCKER_LOCAL_USER}/${DOCKER_ORA_REPO}:*" --format "{{.Repository}}:{{.Tag}}")
    for i in ${IMAGES}; do
        version=$(echo $i|cut -d: -f2)
        echo " tag image ${DOCKER_LOCAL_USER}/${DOCKER_ORA_REPO}:$version ${DOCKER_USER}/${DOCKER_TVD_REPO}:$version"
        docker tag ${DOCKER_LOCAL_USER}/${DOCKER_ORA_REPO}:$version ${DOCKER_USER}/${DOCKER_TVD_REPO}:$version
        echo " push image ${DOCKER_USER}/${DOCKER_TVD_REPO}:$version"
        docker push ${DOCKER_USER}/${DOCKER_TVD_REPO}:$version
        echo " untag image ${DOCKER_USER}/${DOCKER_TVD_REPO}:$version"
        docker rmi ${DOCKER_USER}/${DOCKER_TVD_REPO}:$version
    done
done
# --- EOF -------------------------------------------------------------------