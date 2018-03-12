#!/bin/bash
# ----------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ----------------------------------------------------------------------
# Name.......: setup_java.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2017.12.04
# Revision...: 
# Purpose....: Setup script for Java installation to build docker OUD image 
# Notes......: Requires MOS credentials in .netrc
# Reference..: --
# License....: CDDL 1.0 + GPL 2.0
# ----------------------------------------------------------------------
# Modified...: 
# see git revision history for more information on changes/updates
# TODO.......: 
# ----------------------------------------------------------------------

# get the MOS Credentials
MOS_USER="${1#*=}"
MOS_PASSWORD="${2#*=}"
LOCALHOST="${3#*=}"

# Download and Package Variables
# JAVA 1.8u162 https://updates.oracle.com/ARULink/PatchDetails/process_form?patch_num=27217289
export JAVA_URL="https://updates.oracle.com/Orion/Services/download/p27217289_180162_Linux-x86-64.zip?aru=21855272&patch_file=p27217289_180162_Linux-x86-64.zip"
export JAVA_PKG=${JAVA_URL#*patch_file=}

# define environment variables
export JAVA_DIR=/usr/java           # java home location
mkdir -p ${DOWNLOAD}
chmod 777 ${DOWNLOAD}

# create a .netrc if it does not exists
if [[ ! -z "${MOS_USER}" ]]
then
    if [[ ! -z "${MOS_PASSWORD}" ]]
    then
        echo "machine login.oracle.com login ${MOS_USER} password ${MOS_PASSWORD}" >${DOCKER_SCRIPTS}/.netrc
        echo "machine updates.oracle.com login ${MOS_USER} password ${MOS_PASSWORD}" >>${DOCKER_SCRIPTS}/.netrc
    else
        echo "MOS_PASSWORD is empty"
    fi
elif [ ! -e ${DOCKER_SCRIPTS}/.netrc ]
then
    >&2 echo "================================================================================="
    >&2 echo "MOS_USER nor .netrc definend. Download from MOS will fail. "
    >&2 echo "Make sure to copy ${JAVA_PKG} to software."
    >&2 echo "================================================================================="
fi

# Download Server JRE 8u162 package if it does not exist /tmp/download
if [ ! -e ${DOWNLOAD}/${JAVA_PKG} ]; then
    if [ ! "${LOCALHOST}" = "" ]; then
        echo "--- Download Server JRE 8u162 from ${LOCALHOST} -----------------------------------------"
        curl --location-trusted ${LOCALHOST}/${JAVA_PKG} -o ${DOWNLOAD}/${JAVA_PKG}
    else
        echo "--- Download Server JRE 8u162 from MOS -----------------------------------------"
        curl --netrc-file ${DOCKER_SCRIPTS}/.netrc --cookie-jar cookie-jar.txt \
        --location-trusted ${JAVA_URL} -o ${DOWNLOAD}/${JAVA_PKG}
    fi
else
    echo "--- Use local copy of ${DOWNLOAD}/${JAVA_PKG} --------------------------------------"
fi

echo "--- Install Server JRE 8 Update ------------------------------------------------"
# create java default folder
mkdir -p ${JAVA_DIR}

# unzip and untar Server JRE
if [[ ${DOWNLOAD}/${JAVA_PKG} =~ \.zip$ ]]
then
    unzip -p ${DOWNLOAD}/${JAVA_PKG} *tar* |tar zvx -C ${JAVA_DIR}
else
    tar zxvf ${DOWNLOAD}/${JAVA_PKG} -C ${JAVA_DIR}
fi

# set the JAVA alternatives directories and links
export JAVA_DIR=$(ls -1 -d /usr/java/*)
ln -s ${JAVA_DIR} /usr/java/latest
ln -s ${JAVA_DIR} /usr/java/default
alternatives --install /usr/bin/java java ${JAVA_DIR}/bin/java 20000 
alternatives --install /usr/bin/javac javac ${JAVA_DIR}/bin/javac 20000
alternatives --install /usr/bin/jar jar ${JAVA_DIR}/bin/jar 20000

# clean up
echo "--- Clean up yum cache and temporary download files ----------------------------"
yum clean all
rm -rf /var/cache/yum
rm -rf ${DOWNLOAD}/*
echo "=== Done runing $0 =================================="