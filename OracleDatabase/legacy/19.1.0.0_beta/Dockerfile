# ----------------------------------------------------------------------
# Trivadis - Part of Accenture, Platform Factory - Transactional Data Platform
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ----------------------------------------------------------------------
# Name.......: Dockerfile
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2018.03.19
# Purpose....: This Dockerfile to build Oracle Database Containers
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
FROM oraclelinux:7-slim AS base

# Maintainer
# ----------------------------------------------------------------------
LABEL maintainer="stefan.oehrli@trivadis.com"

# Arguments for Oracle Installation
ARG ORACLE_ROOT
ARG ORACLE_DATA
ARG ORACLE_ARCH
ARG ORACLE_BASE
ARG ORAREPO

# just my environment variable for the software repository host
ENV ORAREPO=${ORAREPO:-orarepo}

# Environment variables required for this build 
# Change them carefully and wise!
# -------------------------------------------------------------
# Software stage area, repository, binary packages and patchs
ENV DOWNLOAD="/tmp/download" \
    SOFTWARE="/opt/stage" \
    SOFTWARE_REPO="http://$ORAREPO" \
    ORADBA_INIT="/opt/oradba/bin" \
    DB_BASE_PKG="191000_Beta1_Linux-x86-64_db_home.zip" \
    DB_EXAMPLE_PKG="" \
    DB_PATCH_PKG="" \
    DB_OJVM_PKG="" \
    DB_OPATCH_PKG=""

# scripts to build and run this container
ENV SETUP_INIT="00_setup_oradba_init.sh" \
    SETUP_OS="01_setup_os_db.sh" \
    SETUP_DB="10_setup_db_19.1.sh" \
    SETUP_BASENV="20_setup_basenv.sh" \
    START_SCRIPT="50_start_database.sh" \
    CONFIG_SCRIPT="55_config_database.sh" \
    CHECK_SCRIPT="55_check_database.sh" \
    RUN_SCRIPT="50_run_database.sh" \
    CREATE_SCRIPT="52_create_database.sh"

# stuff to run a DB instance
ENV ORACLE_SID=${ORACLE_SID:-"TDB191S"} \
    ORACLE_HOME_NAME="19.1.0.0" \
    ORACLE_ROOT=${ORACLE_ROOT:-"/u00"} \
    ORACLE_DATA=${ORACLE_DATA:-"/u01"} \
    ORACLE_ARCH=${ORACLE_ARCH:-"/u01"} \
    DEFAULT_DOMAIN=${ORACLE_ARCH:-"trivadislabs.com"}  \
    PORT=${PORT:-1521} \
    PORT_CONSOLE=${PORT_CONSOLE:-5500}

# Use second ENV so that variable get substituted
ENV ORACLE_BASE=${ORACLE_BASE:-$ORACLE_ROOT/app/oracle} 

# same same but different ...
# third ENV so that variable get substituted
ENV PATH=${PATH}:"${ORACLE_BASE}/product/${ORACLE_HOME_NAME}/bin:${ORADBA_INIT}:${ORACLE_BASE}/product/${ORACLE_HOME_NAME}/OPatch/:/usr/sbin:$PATH" \
    ORACLE_HOME=${ORACLE_BASE}/product/${ORACLE_HOME_NAME} \
    LD_LIBRARY_PATH="${ORACLE_BASE}/product/${ORACLE_HOME_NAME}/lib:/usr/lib" \
    CLASSPATH="${ORACLE_BASE}/product/${ORACLE_HOME_NAME}/jlib:${ORACLE_BASE}/product/${ORACLE_HOME_NAME}/rdbms/jlib"

# RUN as user root
# ----------------------------------------------------------------------
# get the OraDBA init script to setup the OS and later OUD
RUN mkdir -p ${DOWNLOAD} && \
    GITHUB_URL="https://github.com/oehrlis/oradba_init/raw/master/bin" && \
    curl -Lsf ${GITHUB_URL}/${SETUP_INIT} -o ${DOWNLOAD}/${SETUP_INIT} && \
    chmod 755 ${DOWNLOAD}/${SETUP_INIT} && \
    ${DOWNLOAD}/${SETUP_INIT}

# Setup OS using OraDBA init script
RUN ${ORADBA_INIT}/${SETUP_OS}

# New stage for installing the database binaries
# ----------------------------------------------------------------------
FROM base AS builder

# COPY database software if part of the build context
COPY --chown=oracle:oinstall *zip* "${SOFTWARE}/"

# RUN as oracle
# Switch to user oracle, oracle software has to be installed as regular user
# ----------------------------------------------------------------------
USER oracle
RUN ${ORADBA_INIT}/${SETUP_DB}

# Install BasEnv
RUN ${ORADBA_INIT}/${SETUP_BASENV}

# New layer for database runtime
# ----------------------------------------------------------------------
FROM base

USER oracle
# copy binaries
COPY --chown=oracle:oinstall --from=builder $ORACLE_BASE $ORACLE_BASE

# copy oracle inventory
COPY --chown=oracle:oinstall --from=builder $ORACLE_ROOT/app/oraInventory $ORACLE_ROOT/app/oraInventory

# copy basenv profile stuff
COPY --chown=oracle:oinstall --from=builder /home/oracle/.BE_HOME /home/oracle/.TVDPERL_HOME /home/oracle/.bash_profile /home/oracle/

# RUN as root post install scripts
USER root
RUN $ORACLE_ROOT/app/oraInventory/orainstRoot.sh && \
    $ORACLE_HOME/root.sh

# Finalize image
# ----------------------------------------------------------------------
# get back to user oracle
USER oracle

# expose the listener and em console ports
EXPOSE ${PORT} ${PORT_CONSOLE}

# Oracle data volume for database instance and configuration files
VOLUME ["${ORACLE_DATA}"]

# set workding directory
WORKDIR "${ORACLE_BASE}"

# run container health check
HEALTHCHECK --interval=1m --start-period=5m \
   CMD ${ORADBA_INIT}/${CHECK_SCRIPT} >/dev/null || exit 1

# Define default command to start OUD instance
CMD exec ${ORADBA_INIT}/${RUN_SCRIPT}
# --- EOF --------------------------------------------------------------