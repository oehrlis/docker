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
# - End of Customization ----------------------------------------------------

# - Default Values ----------------------------------------------------------
DOCKER_ORA_USER=oracle
DOCKER_ORA_REPO=database
DOCKER_IMAGES=${DOCKER_VOLUME_BASE}/../images
echo "--------------------------------------------------------------------------------"
echo " Process all ${DOCKER_ORA_USER}/${DOCKER_ORA_REPO}:* images ...."

ORACLE_IMAGES=$(docker images --filter=reference="${DOCKER_ORA_USER}/${DOCKER_ORA_REPO}:*" --format "{{.Repository}}:{{.Tag}}")

for i in ${ORACLE_IMAGES}; do
    version=$(echo $i|cut -d: -f2)
    echo " save image ${DOCKER_ORA_USER}/${DOCKER_ORA_REPO}:$version"
    docker save ${DOCKER_ORA_USER}/${DOCKER_ORA_REPO}:$version |gzip -c >${DOCKER_IMAGES}/${DOCKER_ORA_USER}_${DOCKER_ORA_REPO}_$version.tar.gz
done
# --- EOF -------------------------------------------------------------------