# ----------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ----------------------------------------------------------------------
# Name.......: Dockerfile 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: 
# Date.......: 
# Revision...: 
# Purpose....: Dockerfile to build OUD image
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

# Environment variables required for this build (do NOT change)
# -------------------------------------------------------------
ENV DOWNLOAD="/tmp/download" \
    DOCKER_SCRIPTS="/opt/docker/bin" \
    START_SCRIPT="start_ODSEE_Instance.sh" \
    CHECK_SCRIPT="check_ODSEE_Instance.sh" \
    ORACLE_HOME_NAME="dsee7" \
    ORACLE_ROOT=${ORACLE_ROOT:-/u00} \
    ORACLE_DATA=${ORACLE_DATA:-/u01} \
    PORT=${PORT:-1389} \
    PORT_SSL=${PORT_SSL:-1636}

# Use second ENV so that variable get substituted
ENV ORACLE_BASE=${ORACLE_BASE:-$ORACLE_ROOT/app/oracle} \
    OUD_INSTANCE_BASE=${OUD_INSTANCE_BASE:-$ORACLE_DATA/instances}
    

# same same but third ENV so that variable get substituted
ENV PATH=${PATH}:"${ORACLE_BASE}/product/${ORACLE_HOME_NAME}/bin:${ORACLE_BASE}/product/${ORACLE_HOME_NAME}/dsrk/bin:${DOCKER_SCRIPTS}"

# copy all setup scripts to DOCKER_BIN
COPY scripts ${DOCKER_SCRIPTS}

# install ODSEE requirements
# ODSEE environment setup via shell script to reduce layers and 
# optimize final disk usage
RUN ${DOCKER_SCRIPTS}/setup_odsee.sh

# Switch to user oracle, oracle software as to be installed with regular user
USER oracle

COPY software ${ORACLE_BASE}/product/

# OUD admin and ldap ports as well the OUDSM console
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