# ----------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ----------------------------------------------------------------------
# Name.......: Dockerfile 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2017.09.22
# Revision...: 
# Purpose....: Dockerfile to build a base image for oud, wls and oudsm
# Notes......: --
# Reference..: https://github.com/oehrlis/docker
# License....: GPL-3.0+
# ----------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# ----------------------------------------------------------------------

# Pull base image
# ----------------------------------------------------------------------
FROM oraclelinux:7-slim

# Maintainer
# ----------------------------------------------------------------------
MAINTAINER Stefan Oehrli <stefan.oehrli@trivadis.com>

# Arguments for Oracle Installation
ARG ORACLE_ROOT
ARG ORACLE_DATA
ARG ORACLE_BASE

# Environment variables required for this build (do NOT change)
# -------------------------------------------------------------
ENV DOWNLOAD="/tmp/download" \
    DOCKER_SCRIPTS="/opt/docker/bin" \
    ORACLE_ROOT=${ORACLE_ROOT:-/u00} \
    ORACLE_DATA=${ORACLE_DATA:-/u01}

# Use second ENV so that variable get substituted
ENV ORACLE_BASE=${ORACLE_BASE:-$ORACLE_ROOT/app/oracle} \
    TNS_ADMIN=${ORACLE_ROOT}/app/oracle/network \
    PATH=${PATH}:${DOCKER_SCRIPTS}

# copy all setup scripts to DOCKER_BIN
COPY scripts ${DOCKER_SCRIPTS}
# get common scripts from github
ADD https://raw.githubusercontent.com/oehrlis/docker/master/common/setup_tvd.sh ${DOCKER_SCRIPTS}

# image setup via shell script to reduce layers and optimize final disk usage
RUN chmod 755 ${DOCKER_SCRIPTS}/*.sh && sleep 1 && \
    ${DOCKER_SCRIPTS}/setup_tvd.sh

# Oracle data volume
VOLUME ["${ORACLE_DATA}"]

# set workding directory
WORKDIR "${ORACLE_BASE}"

# Define bash as default command 
CMD ["bash", "--login"]
# --- EOF --------------------------------------------------------------
