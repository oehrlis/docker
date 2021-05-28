# ----------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ----------------------------------------------------------------------
# Name.......: Dockerfile
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2018.03.19
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
FROM  oraclelinux:7-slim AS base

# Maintainer
# ----------------------------------------------------------------------
LABEL maintainer="stefan.oehrli@trivadis.com"

# Arguments for Oracle Installation
ARG   ORACLE_ROOT
ARG   ORACLE_DATA
ARG   ORACLE_BASE
ARG   ORAREPO

# just my environment variable for the software repository host
ENV   ORAREPO=${ORAREPO:-orarepo}

# Environment variables required for this build 
# Change them carefully and wise!
# -------------------------------------------------------------
# Software stage area, repository, binary packages and patchs
ENV   DOWNLOAD="/tmp/download" \
      SOFTWARE="/opt/stage" \
      SOFTWARE_REPO="http://$ORAREPO" \
      DOCKER_SCRIPTS="/opt/docker/bin" \
      ORADBA_INIT="/opt/oradba/bin" 

# scripts to build and run this container
ENV   SETUP_INIT="00_setup_oradba_init.sh" \
      SETUP_OS="01_setup_os_oud.sh" \
      SETUP_JAVA="01_setup_os_java.sh" \
      ORACLE_ROOT=${ORACLE_ROOT:-/u00} \
      ORACLE_DATA=${ORACLE_DATA:-/u01} \
      JAVA_BASE="/usr/java/"

# Use second ENV so that variable get substituted
ENV   ORACLE_BASE=${ORACLE_BASE:-$ORACLE_ROOT/app/oracle} \
      JAVA_HOME="${JAVA_BASE}/default"

# RUN as user root
# ----------------------------------------------------------------------
# get the OraDBA init script to setup the OS and later OUD
RUN   mkdir -p ${DOWNLOAD} && \
      GITHUB_URL="https://github.com/oehrlis/oradba_init/raw/master/bin" && \
      curl -Lsf ${GITHUB_URL}/${SETUP_INIT} -o ${DOWNLOAD}/${SETUP_INIT} && \
      chmod 755 ${DOWNLOAD}/${SETUP_INIT} && \
      ${DOWNLOAD}/${SETUP_INIT}

# Setup OS using OraDBA init script
RUN   ${ORADBA_INIT}/${SETUP_OS}

# Install Java
# ----------------------------------------------------------------------
# Setup JAVA using OraDBA init script
ENV JAVA_PKG="p32464056_180291_Linux-x86-64.zip"
RUN ${ORADBA_INIT}/${SETUP_JAVA}
COPY java.security /usr/java/latest/jre/lib/security/java.security

# Set Version specific stuff
# ----------------------------------------------------------------------
# scripts to build and run this container
ENV SETUP_OUD="10_setup_oud.sh" \
    SETUP_OUDBASE="20_setup_oudbase.sh" \
    START_SCRIPT="60_start_oud_instance.sh" \
    CHECK_SCRIPT="64_check_oud_instance.sh" 

# set OUD specific parameters
ENV OUD_BASE_PKG="p30188352_122140_Generic.zip" \
    OUD_PATCH_PKG="p30851280_122140_Generic.zip" \
    OUD_OPATCH_PKG="p28186730_139424_Generic.zip"

# stuff to setup and run an OUD instance
ENV OUD_INSTANCE_BASE=${OUD_INSTANCE_BASE:-$ORACLE_DATA/instances} \
    OUD_INSTANCE=${OUD_INSTANCE:-oud_docker} \
    USER_MEM_ARGS="-Djava.security.egd=file:/dev/./urandom" \
    OPENDS_JAVA_ARGS="-Dcom.sun.jndi.ldap.object.disableEndpointIdentification=true" \
    ORACLE_HOME_NAME="fmw12.2.1.4.0" \
    OUD_VERSION="12" \
    PORT="${PORT:-1389}" \
    PORT_SSL="${PORT_SSL:-1636}" \
    PORT_HTTP="${PORT_HTTP:-8080}" \
    PORT_HTTPS="${PORT_HTTPS:-10443}" \
    PORT_REP="${PORT_REP:-8989}" \
    PORT_ADMIN="${PORT_ADMIN:-4444}" \
    PORT_REST_ADMIN="${PORT_REST_ADMIN:-8444}" \
    PORT_REST_HTTP="${PORT_REST_HTTP:-1080}" \
    PORT_REST_HTTPS="${PORT_REST_HTTPS:-1081}"

# same same but different...
# third ENV so that variable get substituted
ENV PATH=${PATH}:"${OUD_INSTANCE_HOME}/OUD/bin:${ORACLE_BASE}/product/${ORACLE_HOME_NAME}/oud/bin:${ORADBA_INIT}:${DOCKER_SCRIPTS}" \
    ORACLE_HOME=${ORACLE_BASE}/product/${ORACLE_HOME_NAME}

# New stage for installing the oud binaries
# ----------------------------------------------------------------------
FROM  base AS builder

# COPY base software if part of the build context
COPY  --chown=oracle:oinstall software/*zip* "${SOFTWARE}/"
# COPY RU patch if part of the build context
COPY  --chown=oracle:oinstall software/BP_12.2.1.4.200204/*zip* "${SOFTWARE}/"

# RUN as oracle
# Switch to user oracle, oracle software as to be installed with regular user
# ----------------------------------------------------------------------
USER  oracle
RUN   ${ORADBA_INIT}/${SETUP_OUD}

# get the latest OUD base from GitHub and install it
RUN   ${ORADBA_INIT}/${SETUP_OUDBASE}

# New layer for database runtime
# ----------------------------------------------------------------------
FROM  base

USER  oracle
# copy binaries
COPY  --chown=oracle:oinstall --from=builder $ORACLE_BASE $ORACLE_BASE

# copy oracle inventory
COPY  --chown=oracle:oinstall --from=builder $ORACLE_ROOT/app/oraInventory $ORACLE_ROOT/app/oraInventory

# copy basenv profile stuff
COPY  --chown=oracle:oinstall --from=builder /home/oracle/.OUD_BASE /home/oracle/.bash_profile /home/oracle/

# Finalize image
# ----------------------------------------------------------------------
# expose the OUD ports for ldap, ldaps, http, https, replication, 
# administration and http administration
EXPOSE   ${PORT} ${PORT_SSL} \
         ${PORT_HTTP} ${PORT_HTTPS} \
         ${PORT_ADMIN} ${PORT_REST_ADMIN} \
         ${PORT_REP} ${PORT_REST_HTTP} ${PORT_REST_HTTPS} 

# run container health check
HEALTHCHECK    --interval=1m --start-period=5m \
   CMD "${ORADBA_INIT}/${CHECK_SCRIPT}" >/dev/null || exit 1

# Oracle data volume for OUD instance and configuration files
VOLUME   ["${ORACLE_DATA}"]

# set workding directory
WORKDIR  "${ORACLE_BASE}"

# Define default command to start OUD instance
CMD   exec "${ORADBA_INIT}/${START_SCRIPT}"
# --- EOF --------------------------------------------------------------