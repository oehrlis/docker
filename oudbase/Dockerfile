# ----------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ----------------------------------------------------------------------
# Name.......: Dockerfile 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2018.03.13
# Revision...: 
# Purpose....: Dockerfile to build oudbase image
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
LABEL maintainer="stefan.oehrli@trivadis.com"

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
ENV ORACLE_BASE=${ORACLE_BASE:-$ORACLE_ROOT/app/oracle}

# same same but third ENV so that variable get substituted
ENV PATH=${PATH}:"${ORACLE_BASE}/local/bin:${DOCKER_SCRIPTS}"

# copy all setup scripts to DOCKER_BIN
#COPY scripts ${DOCKER_SCRIPTS}
COPY software ${DOWNLOAD}

# get common scripts from github
ADD https://raw.githubusercontent.com/oehrlis/docker/master/common/setup_oudbase.sh ${DOCKER_SCRIPTS}

# image setup via shell script to reduce layers and optimize final disk usage
RUN chmod 755 ${DOCKER_SCRIPTS}/*.sh && \
    ${DOCKER_SCRIPTS}/setup_oudbase.sh

# set workding directory
WORKDIR "${ORACLE_BASE}"

# Define default command to start OUD instance
CMD exec "bash"
# --- EOF --------------------------------------------------------------
