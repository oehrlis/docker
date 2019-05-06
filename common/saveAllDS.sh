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
DOCKER_ORA_USER=oracle
DOCKER_ORA_REPO=database
DOCKER_IMAGES=${DOCKER_VOLUME_BASE}/../images

LOCAL_REPO="oud oudsm odsee serverjre"

DOCKER_ORA_OUD_REPO=oud
DOCKER_ORA_OUDSM_REPO=oudsm
DOCKER_ORA_ODSEE_REPO=odsee
DOCKER_ORA_JAVA_REPO=serverjre

for r in ${LOCAL_REPO}; do
    DOCKER_ORA_REPO=$r
    echo "--------------------------------------------------------------------------------"
    echo " Process all ${DOCKER_ORA_USER}/${r}:* images ...."
    IMAGES=$(docker images --filter=reference="${DOCKER_ORA_USER}/${r}:*" --format "{{.Repository}}:{{.Tag}}")
    for i in ${IMAGES}; do
        version=$(echo $i|cut -d: -f2)
        echo " save image ${DOCKER_ORA_USER}/${r}:$version"
        docker save ${DOCKER_ORA_USER}/${r}:$version |gzip -c >${DOCKER_IMAGES}/${DOCKER_ORA_USER}_${r}_$version.tar.gz
    done
done
# --- EOF -------------------------------------------------------------------