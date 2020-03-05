# ----------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ----------------------------------------------------------------------
# Name.......: Dockerfile
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2018.03.19
# Revision...: 1.0
# Purpose....: This Dockerfile is to build Oracle Unifid Directory
# Notes......: --
# Reference..: --
# License....: Licensed under the Universal Permissive License v 1.0 as
#              shown at http://oss.oracle.com/licenses/upl.
# ----------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# ----------------------------------------------------------------------

# Pull base image
# ----------------------------------------------------------------------
FROM oraclelinux:7-slim

# Maintainer
# ----------------------------------------------------------------------
LABEL maintainer="stefan.oehrli@trivadis.com"

# Arguments for Oracle Installation
ARG ORACLE_ROOT
ARG ORACLE_DATA
ARG ORACLE_BASE
ARG ORAREPO

# Environment variables required for this build (do NOT change)
# ----------------------------------------------------------------------
ENV ORAREPO=${ORAREPO:-orarepo} \
    DOWNLOAD="/tmp/download" \
    DOCKER_SCRIPTS="/opt/docker/bin" \
    START_SCRIPT="start_odsee_instance.sh" \
    CHECK_SCRIPT="check_odsee_instance.sh" \
    USER_MEM_ARGS="-Djava.security.egd=file:/dev/./urandom" \
    ORACLE_HOME_NAME="dsee7" \
    ORACLE_ROOT=${ORACLE_ROOT:-/u00} \
    ORACLE_DATA=${ORACLE_DATA:-/u01} \
    ODSEE_INSTANCE=${ODSEE_INSTANCE:-dsDocker} \
    PORT="1389" \
    PORT_SSL="1636" \
    FMW_ODSEE_PKG=p29893742_111170_Linux-x86-64.zip \
    FMW_ODSEE_TAR=dsee.11.1.1.7.190716.Redhat5-opt-64.full.zip.tar.gz \
    FMW_ODSEE=sun-dsee7.zip

# Use second ENV so that variable get substituted
ENV ORACLE_BASE=${ORACLE_BASE:-$ORACLE_ROOT/app/oracle} \
    OUD_INSTANCE_BASE=${OUD_INSTANCE_BASE:-$ORACLE_DATA/instances}

# same same but different...
# third ENV so that variable get substituted
ENV PATH=${PATH}:"${ODSEE_INSTANCE_HOME}/OUD/bin:${ODSEE_HOME}/bin:${DOCKER_SCRIPTS}" \
    ODSEE_HOME=${ORACLE_BASE}/product/${ORACLE_HOME_NAME}

# RUN as user root
# ----------------------------------------------------------------------
# - create group oracle and oinstall
# - create user oracle
# - setup subdirectory to install OUD package and container-scripts
# - create softlink for the OUD setup scripts
# - limit instal language / local to english
# - install unzip zip gzip tar procps-ng libstdc++.i686 glibc.i686 zlib.i686
# - remove yum cache     yum upgrade -y && \
# ----------------------------------------------------------------------
RUN groupadd --gid 1000 oracle && \
    groupadd --gid 1010 oinstall && \
    useradd --create-home --gid oracle --groups oracle,oinstall \
        --shell /bin/bash oracle && \
    install --owner oracle --group oracle --mode=775 --verbose --directory \
        ${ORACLE_ROOT} \
        ${ORACLE_BASE} \
        ${ORACLE_DATA} \
        ${DOWNLOAD} \
        ${DOCKER_SCRIPTS} && \
    ln -s ${ORACLE_DATA}/scripts /docker-entrypoint-initdb.d && \
    echo "%_install_langs   en" >/etc/rpm/macros.lang && \
    yum install -y unzip zip gzip tar \
        libstdc++.x86_64 libstdc++.i686 \
        glibc.i686 zlib.i686 && \
    rm -rf /var/cache/yum

# Copy scripts and software
# ----------------------------------------------------------------------
# copy all setup scripts to DOCKER_BIN
COPY scripts/* "${DOCKER_SCRIPTS}/"

# COPY oud/software and response files
COPY ${FMW_ODSEE_PKG}* "${DOWNLOAD}/"
COPY ${FMW_ODSEE}* "${DOWNLOAD}/"

# RUN as oracle
# Switch to user oracle, oracle software as to be installed with regular user
# ----------------------------------------------------------------------
USER oracle

# - check if software has been copied [ -s ... ]
# - alternatively download patched software with curl from orarepo
# ----------------------------------------------------------------------
RUN cd ${DOWNLOAD} && \
    [ -s "${DOWNLOAD}/${FMW_ODSEE_PKG}" ] || [ -s "${DOWNLOAD}/${FMW_ODSEE}" ] || \
    curl -f http://orarepo/${FMW_ODSEE_PKG} -o ${DOWNLOAD}/${FMW_ODSEE_PKG}

# - unpack patch software using unzip, tar when present
# -----------------------------------------------------------------
RUN cd ${DOWNLOAD} && \
    if [ -s "${DOWNLOAD}/${FMW_ODSEE_PKG}" ]; then \
        unzip -o ${DOWNLOAD}/${FMW_ODSEE_PKG} && \
        tar zxvf ${DOWNLOAD}/${FMW_ODSEE_TAR}; \
    fi

# - install OUDSEE using unzip
# - clean up and remove unused stuff
# -----------------------------------------------------------------
RUN cd ${DOWNLOAD} && \
    unzip -o ${DOWNLOAD}/${FMW_ODSEE} -d ${ORACLE_BASE}/product/ && \
    rm -rf ${DOWNLOAD}/${FMW_ODSEE_PKG} \
        ${DOWNLOAD}/${FMW_ODSEE_TAR} \
        ${DOWNLOAD}/${FMW_ODSEE} \
        ${DOWNLOAD}/readme.html \
        ${DOWNLOAD}/idsktune

# get the latest OUD base from GitHub and install it
RUN ${DOCKER_SCRIPTS}/setup_oudbase.sh

# Finalize image
# ----------------------------------------------------------------------
# expose the OUD admin, replication and ldap ports
EXPOSE ${PORT} ${PORT_SSL}

# run container health check
HEALTHCHECK --interval=1m --start-period=5m \
   CMD "${DOCKER_SCRIPTS}/${CHECK_SCRIPT}" >/dev/null || exit 1

# Oracle data volume for OUD instance and configuration files
VOLUME ["${ORACLE_DATA}"]

# set workding directory
WORKDIR "${ORACLE_BASE}"

# Define default command to start OUD instance
CMD exec "${DOCKER_SCRIPTS}/${START_SCRIPT}"
# --- EOF --------------------------------------------------------------