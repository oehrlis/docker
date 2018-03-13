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
# Purpose....: Generic build script for docker images on https://github.com/oehrlis/docker
# Notes......: --
# Reference..: https://github.com/oehrlis/docker
# License....: GPL-3.0+
# -----------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# -----------------------------------------------------------------------------
DOCKER_REPOSITORY="oehrlis"
DOCKER_IMAGE_NAME="$(basename $(cd $(dirname $0); pwd -P))"
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