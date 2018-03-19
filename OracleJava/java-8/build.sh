#!/bin/bash
# -----------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------------
# Name.......: build.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2018.03.13
# Revision...:  
# Purpose....: Build script to build Oracle Java 1.8
# Notes......: --
# Reference..: --
# License....: Licensed under the Universal Permissive License v 1.0 as 
#              shown at http://oss.oracle.com/licenses/upl.
# -----------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# -----------------------------------------------------------------------------
DOCKER_REPOSITORY="oracle"
DOCKER_IMAGE_NAME="serverjre:8"
DOCKERFILE="$(dirname $0)/Dockerfile"
DOCKER_BUILD_DIR="$(cd $(dirname $0) 2>&1 >/dev/null; pwd -P)"

if [ ! -f "${DOCKERFILE}" ]; then
    echo " ERROR : Can not build ${DOCKER_IMAGE_NAME}. Please run build.sh "
    echo "         from a corresponding subdirectory."
    exit 1
fi
echo "--------------------------------------------------------------------------------"
echo " Build docker image ${DOCKER_REPOSITORY}/${DOCKER_IMAGE_NAME} using"
echo " Dockerfile             : ${DOCKERFILE}"
echo " Docker build directory : ${DOCKER_BUILD_DIR}" 
echo "--------------------------------------------------------------------------------"

docker build -t ${DOCKER_REPOSITORY}/${DOCKER_IMAGE_NAME} -f "${DOCKERFILE}" "${DOCKER_BUILD_DIR}"