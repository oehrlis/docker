#!/bin/bash
# -----------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------------
# Name.......: saveAllDB.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2019.04.06
# Revision...:  
# Purpose....: Scripts to save / export all Oracle database images
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
DOCKER_LOCAL_USER=${DOCKER_LOCAL_USER:-"oracle"}
DOCKER_LOCAL_REPO=${DOCKER_LOCAL_REPO:-"database"}
DOCKER_IMAGES=${DOCKER_VOLUME_BASE}/../images
LOCAL_REPO="oud oudsm odsee serverjre"

for r in ${LOCAL_REPO}; do
    DOCKER_LOCAL_REPO=$r
    echo "--------------------------------------------------------------------------------"
    echo " Process all ${DOCKER_LOCAL_USER}/${r}:* images ...."
    IMAGES=$(docker images --filter=reference="${DOCKER_LOCAL_USER}/${r}:*" --format "{{.Repository}}:{{.Tag}}")
    for i in ${IMAGES}; do
        version=$(echo $i|cut -d: -f2)
        echo " save image ${DOCKER_LOCAL_USER}/${r}:$version"
        docker save ${DOCKER_LOCAL_USER}/${r}:$version |gzip -c >${DOCKER_IMAGES}/${DOCKER_LOCAL_USER}_${r}_$version.tar.gz
    done
done
# --- EOF -------------------------------------------------------------------