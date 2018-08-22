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
# Notes......: The script does look for the server JRE package. If not 
#              available it does fall back to the java patch package or 
#              tries to download the java patch package from MOS. The
#              download does require a .netrc file with the MOS credentials
# Reference..: --
# License....: Licensed under the Universal Permissive License v 1.0 as 
#              shown at http://oss.oracle.com/licenses/upl.
# -----------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# -----------------------------------------------------------------------------

# - Customization -----------------------------------------------------------
DOCKER_REPOSITORY="oracle"
DOCKER_MAJOR_IMAGE_NAME="serverjre:8"
# - End of Customization ----------------------------------------------------

# - Default Values ----------------------------------------------------------
DOCKER_BUILD_DIR="$(cd $(dirname $0) 2>&1 >/dev/null; pwd -P)"
DOCKERFILE="$DOCKER_BUILD_DIR/Dockerfile"
cd $DOCKER_BUILD_DIR
# get the latest download file
DOWNLOAD=$(find ${DOCKER_BUILD_DIR} -name "*_Linux-x86-64.zip.download"|sort|tail -1)
# get the download URL from file
JAVA_URL=$(grep -i "# Direct Download" ./p27890736_180181_Linux-x86-64.zip.download|cut -d' ' -f7)
# get java package name from download url
JAVA_PKG=${JAVA_URL#*patch_file=}
# get java version from java package name
JAVA_UPDATE=$(echo $JAVA_PKG|sed 's/.*[0-9]\{3\}\([0-9]\{3\}\)_.*/\1/')
# get java update from java package name
JAVA_VERSION=$(echo $JAVA_PKG|sed 's/.*\([0-9]\)\([0-9]\)\([0-9]\)[0-9]\{3\}_.*/\1\.\2\.\3/')
# define server jre package name 
SERVER_JRE_PACKAGE="server-jre-8u${JAVA_UPDATE}-linux-x64.tar.gz"
# define image name based on Java version and update
DOCKER_IMAGE_NAME="serverjre:${JAVA_VERSION}_${JAVA_UPDATE}"

if [ ! -f "${DOCKERFILE}" ]; then
    echo " ERROR : Can not build ${DOCKER_IMAGE_NAME}. Please run build.sh "
    echo "         from a corresponding subdirectory."
    exit 1
fi
echo "--------------------------------------------------------------------------------"
echo " Build docker image ${DOCKER_REPOSITORY}/${DOCKER_IMAGE_NAME} using"
echo " Dockerfile             : ${DOCKERFILE}"
echo " Docker build directory : ${DOCKER_BUILD_DIR}"
echo " Java Version           : $JAVA_VERSION u$JAVA_UPDATE"
echo "--------------------------------------------------------------------------------"

# check if there is a server jre package
if [ -f "${DOCKER_BUILD_DIR}/${SERVER_JRE_PACKAGE}" ]; then
    echo "Did found a server JRE 1.8 package ${SERVER_JRE_PACKAGE}"
elif [ -f "${DOCKER_BUILD_DIR}/${JAVA_PKG}" ]; then
    echo "Did found server JRE 1.8 patch package ${JAVA_PKG}"
    echo "Unzip ${JAVA_PKG}"
    unzip -o ${DOCKER_BUILD_DIR}/${JAVA_PKG}
elif [ -f "${DOCKER_BUILD_DIR}/.netrc" ]; then
    echo "Try to download Server JRE 8u${JAVA_UPDATE} patch package from MOS"
    curl --netrc-file ${DOCKER_BUILD_DIR}/.netrc --cookie-jar cookie-jar.txt \
        --location-trusted ${JAVA_URL} -o ${JAVA_PKG} && unzip -o ${JAVA_PKG}
    rm -f cookie-jar.txt
else
    echo "Missing Server JRE 8u${JAVA_UPDATE} package."
    echo "Fallback to ${JAVA_PKG} or MOS download failed"
    echo "Can not build docker image ${DOCKER_REPOSITORY}/${DOCKER_IMAGE_NAME}"
    exit 1
fi
docker rmi ${DOCKER_REPOSITORY}/${DOCKER_MAJOR_IMAGE_NAME} 2>/dev/null||echo "No image ${DOCKER_REPOSITORY}/${DOCKER_MAJOR_IMAGE_NAME} to remove"

docker build -t ${DOCKER_REPOSITORY}/${DOCKER_IMAGE_NAME} -f "${DOCKERFILE}" "${DOCKER_BUILD_DIR}"

docker tag ${DOCKER_REPOSITORY}/${DOCKER_IMAGE_NAME} ${DOCKER_REPOSITORY}/${DOCKER_MAJOR_IMAGE_NAME}
