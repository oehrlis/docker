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
DOCKER_TVD_USER=trivadis
DOCKER_TVD_REPO=ora_db
DOCKER_ORA_USER=oracle
DOCKER_ORA_REPO=database

echo "--------------------------------------------------------------------------------"
echo " Process all ${DOCKER_ORA_USER}/${DOCKER_ORA_REPO}:* images ...."

ORACLE_IMAGES=$(docker images --filter=reference="${DOCKER_ORA_USER}/${DOCKER_ORA_REPO}:*" --format "{{.Repository}}:{{.Tag}}")

for i in ${ORACLE_IMAGES}; do
    version=$(echo $i|cut -d: -f2)
    echo " tag image ${DOCKER_ORA_USER}/${DOCKER_ORA_REPO}:$version"
    docker tag ${DOCKER_ORA_USER}/${DOCKER_ORA_REPO}:$version ${DOCKER_TVD_USER}/${DOCKER_TVD_REPO}:$version
    echo " push image ${DOCKER_TVD_USER}/${DOCKER_TVD_REPO}:$version"
    docker push ${DOCKER_TVD_USER}/${DOCKER_TVD_REPO}:$version
    echo " untag image ${DOCKER_TVD_USER}/${DOCKER_TVD_REPO}:$version"
    docker rmi ${DOCKER_TVD_USER}/${DOCKER_TVD_REPO}:$version
done
# --- EOF -------------------------------------------------------------------