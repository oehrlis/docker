# ----------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ----------------------------------------------------------------------
# Name.......: Dockerfile 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: 
# Date.......: 
# Revision...: 
# Purpose....: Dockerfile to build OUDSM image
# Notes......: --
# Reference..: --
# License....: CDDL 1.0 + GPL 2.0
# ----------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# TODO.......:
# --
# ----------------------------------------------------------------------

# Pull base image
# ----------------------------------------------------------------------
FROM oraclelinux:7-slim

# Maintainer
# ----------------------------------------------------------------------
LABEL maintainer="stefan.oehrli@trivadis.com"

# Arguments for MOS Download
ARG MOS_USER
ARG MOS_PASSWORD
ARG LOCALHOST

# Arguments for Oracle Installation
ARG ORACLE_ROOT
ARG ORACLE_DATA
ARG ORACLE_BASE

# Environment variables required for this build (do NOT change)
# -------------------------------------------------------------
ENV DOWNLOAD="/tmp/download" \
    DOCKER_SCRIPTS="/opt/docker/bin" \
    START_SCRIPT="start_OUDSM_Domain.sh" \
    CHECK_SCRIPT="check_OUDSM_Domain.sh" \
    ORACLE_HOME_NAME="fmw12.2.1.3.0" \
    ORACLE_ROOT=${ORACLE_ROOT:-/u00} \
    ORACLE_DATA=${ORACLE_DATA:-/u01} \
    PORT=${PORT:-7001} \
    PORT_SSL=${PORT_SSL:-7002}

# Use second ENV so that variable get substituted
ENV ORACLE_BASE=${ORACLE_BASE:-$ORACLE_ROOT/app/oracle} \
    OUDSM_DOMAIN_BASE=${OUDSM_DOMAIN_BASE:-$ORACLE_DATA/domains}

# same same but third ENV so that variable get substituted
ENV PATH=${PATH}:"${ORACLE_BASE}/product/${ORACLE_HOME_NAME}/oud/bin:${DOCKER_SCRIPTS}"

# copy all scripts to DOCKER_BIN
COPY scripts ${DOCKER_SCRIPTS}
COPY software ${DOWNLOAD}

# Java and OUD base environment setup via shell script to reduce layers and 
# optimize final disk usage
RUN ${DOCKER_SCRIPTS}/setup_oudbase.sh && \
    ${DOCKER_SCRIPTS}/setup_java.sh MOS_USER=${MOS_USER} MOS_PASSWORD=${MOS_PASSWORD} LOCALHOST=${LOCALHOST}

# Switch to user oracle, oracle software as to be installed with regular user
USER oracle

# Instal OUD / OUDSM via shell script to reduce layers and optimize final disk usage
RUN ${DOCKER_SCRIPTS}/setup_oudsm.sh MOS_USER=${MOS_USER} MOS_PASSWORD=${MOS_PASSWORD} LOCALHOST=${LOCALHOST}

# OUDSM console / Weblogic ports
EXPOSE ${PORT} ${PORT_SSL}

# run container health check
HEALTHCHECK --interval=1m --start-period=5m \
   CMD "/opt/docker/bin/check_OUDSM_console.sh" >/dev/null || exit 1

# Oracle data volume for OUD instance and configuration files
VOLUME ["${ORACLE_DATA}"]

# set workding directory
WORKDIR "${ORACLE_BASE}"

# Define default command to start OUDSM domain
CMD exec "${DOCKER_SCRIPTS}/${START_SCRIPT}"
# --- EOF --------------------------------------------------------------