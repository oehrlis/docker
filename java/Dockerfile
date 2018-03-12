# ----------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ----------------------------------------------------------------------
# Name.......: Dockerfile 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2017.12.04
# Revision...: 1.0
# Purpose....: Dockerfile to build java image
# Notes......: --
# Reference..: --
# License....: CDDL 1.0 + GPL 2.0
# ----------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# TODO.......:
# - avoid temporary oud jar file in image
# - add oud or base env
# ----------------------------------------------------------------------

# Pull base image
# ----------------------------------------------------------------------
FROM oraclelinux:7-slim

# Maintainer
# ----------------------------------------------------------------------
MAINTAINER Stefan Oehrli <stefan.oehrli@trivadis.com>

# Arguments for MOS Download
ARG MOS_USER
ARG MOS_PASSWORD
ARG LOCALHOST

# Environment variables required for this build (do NOT change)
# ----------------------------------------------------------------------
ENV DOWNLOAD=/tmp/download \
    DOCKER_SCRIPTS=/opt/docker/bin
    
# copy all scripts to DOCKER_BIN
COPY scripts ${DOCKER_SCRIPTS}
COPY software ${DOWNLOAD}

# image setup via shell script to reduce layers and optimize final disk usage
RUN ${DOCKER_SCRIPTS}/setup_java.sh MOS_USER=${MOS_USER} MOS_PASSWORD=${MOS_PASSWORD} LOCALHOST=${LOCALHOST}

CMD ["bash"]
# --- EOF --------------------------------------------------------------