# ----------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ----------------------------------------------------------------------
# Name.......: Dockerfile
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2020.03.11
# Purpose....: Dockerfile to build Oracle Database image 19.3.0.0
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
# just my environment variable for the software repository host
ARG   ORAREPO=orarepo

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
      SETUP_OS="01_setup_os_db.sh" \
      SETUP_BASENV="20_setup_basenv.sh" \
      RUN_SCRIPT="50_run_database.sh" \
      START_SCRIPT="51_start_database.sh" \
      CREATE_SCRIPT="52_create_database.sh" \
      CONFIG_SCRIPT="53_config_database.sh" \
      CHECK_SCRIPT="54_check_database.sh" \
      ORACLE_ROOT=${ORACLE_ROOT:-"/u00"} \
      ORACLE_DATA=${ORACLE_DATA:-"/u01"} \
      ORACLE_ARCH=${ORACLE_ARCH:-"/u01"}

# Use second ENV so that variable get substituted
ENV   ORACLE_BASE=${ORACLE_BASE:-$ORACLE_ROOT/app/oracle}

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

# Set Version specific stuff
# ----------------------------------------------------------------------
# scripts to build and run this container
# set DB specific package variables
ENV   SETUP_DB="10_setup_db.sh" \
      DB_BASE_PKG="LINUX.X64_193000_db_home.zip" \
      DB_EXAMPLE_PKG="" \
      DB_PATCH_PKG="" \
      DB_OJVM_PKG="" \
      DB_OPATCH_PKG="p6880880_190000_Linux-x86-64.zip"

# stuff to run a DB instance
ENV   ORACLE_SID=${ORACLE_SID:-"TDB190S"} \
      ORACLE_HOME_NAME="19.0.0.0" \
      DEFAULT_DOMAIN=${DEFAULT_DOMAIN:-"postgasse.org"}  \
      PORT=${PORT:-1521} \
      PORT_CONSOLE=${PORT_CONSOLE:-5500}

# same same but different ...
# third ENV so that variable get substituted
ENV   PATH=${PATH}:"${ORACLE_BASE}/product/${ORACLE_HOME_NAME}/bin:${ORADBA_INIT}:${ORACLE_BASE}/product/${ORACLE_HOME_NAME}/OPatch/:/usr/sbin:$PATH" \
      ORACLE_HOME=${ORACLE_BASE}/product/${ORACLE_HOME_NAME} \
      LD_LIBRARY_PATH="${ORACLE_BASE}/product/${ORACLE_HOME_NAME}/lib:/usr/lib" \
      CLASSPATH="${ORACLE_BASE}/product/${ORACLE_HOME_NAME}/jlib:${ORACLE_BASE}/product/${ORACLE_HOME_NAME}/rdbms/jlib"

# New stage for installing the database binaries
# ----------------------------------------------------------------------
FROM  base AS builder

# COPY base database software if part of the build context
COPY  --chown=oracle:oinstall software/*zip* "${SOFTWARE}/"
# COPY RU patch if part of the build context
COPY  --chown=oracle:oinstall software/RU*/${DB_PATCH_PKG}* "${SOFTWARE}/"
COPY  --chown=oracle:oinstall software/RU*/${DB_OJVM_PKG}* "${SOFTWARE}/"

# RUN as oracle
# Switch to user oracle, oracle software has to be installed as regular user
# ----------------------------------------------------------------------
USER  oracle
RUN   ${ORADBA_INIT}/${SETUP_DB}

# Install BasEnv
RUN   ${ORADBA_INIT}/${SETUP_BASENV}

# New layer for database runtime
# ----------------------------------------------------------------------
FROM  base

USER  oracle
# copy binaries
COPY  --chown=oracle:oinstall --from=builder $ORACLE_BASE $ORACLE_BASE

# copy oracle inventory
COPY  --chown=oracle:oinstall --from=builder $ORACLE_ROOT/app/oraInventory $ORACLE_ROOT/app/oraInventory

# copy basenv profile stuff
COPY  --chown=oracle:oinstall --from=builder /home/oracle/.BE_HOME /home/oracle/.TVDPERL_HOME /home/oracle/.bash_profile /home/oracle/

# RUN as root post install scripts
USER  root
RUN   $ORACLE_ROOT/app/oraInventory/orainstRoot.sh && \
      $ORACLE_HOME/root.sh

# Finalize image
# ----------------------------------------------------------------------
# get back to user oracle
USER  oracle

# expose the listener and em console ports
EXPOSE   ${PORT} ${PORT_CONSOLE}

# Oracle data volume for database instance and configuration files
VOLUME   ["${ORACLE_DATA}"]

# set workding directory
WORKDIR  "${ORACLE_BASE}"

# run container health check
HEALTHCHECK --interval=1m --start-period=5m \
   CMD ${ORADBA_INIT}/${CHECK_SCRIPT} >/dev/null || exit 1

# Define default command to start OUD instance
CMD   exec ${ORADBA_INIT}/${RUN_SCRIPT}
# --- EOF --------------------------------------------------------------