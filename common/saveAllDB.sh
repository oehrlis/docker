#!/bin/bash
# -----------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------------
# Name.......: saveAllDS.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2019.04.06
# Revision...:  
# Purpose....: Scripts to save / export all Oracle Directory Server images
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
echo "--------------------------------------------------------------------------------"
echo " Process all ${DOCKER_LOCAL_USER}/${DOCKER_LOCAL_REPO}:* images ...."

ORACLE_IMAGES=$(docker images --filter=reference="${DOCKER_LOCAL_USER}/${DOCKER_LOCAL_REPO}:*" --format "{{.Repository}}:{{.Tag}}")

for i in ${ORACLE_IMAGES}; do
    version=$(echo $i|cut -d: -f2)
    echo " save image ${DOCKER_LOCAL_USER}/${DOCKER_LOCAL_REPO}:$version"
    time docker save ${DOCKER_LOCAL_USER}/${DOCKER_LOCAL_REPO}:$version |gzip -c >${DOCKER_IMAGES}/${DOCKER_LOCAL_USER}_${DOCKER_LOCAL_REPO}_$version.tar.gz
done
# --- EOF -------------------------------------------------------------------