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
ARG ORACLE_DATA
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
   ORACLE_BASE="/opt/oracle" \
   ORACLE_HOME="/opt/oracle/product/18c/dbhomeXE" \
   DB_BASE_PKG="oracle-database-xe-18c-1.0-1.x86_64.rpm" \
   ORACLE_DOCKER_INSTALL="true"

# scripts to build and run this container
ENV SETUP_INIT="00_setup_oradba_init.sh" \
   SETUP_OS="01_setup_os_db.sh" \
   SETUP_DB="10_setup_db_18.3.sh" \
   SETUP_BASENV="20_setup_basenv.sh" \
   START_SCRIPT="50_start_database.sh" \
   CONFIG_SCRIPT="55_config_database.sh" \
   CHECK_SCRIPT="55_check_database.sh" \
   RUN_SCRIPT="50_run_database.sh" \
   CREATE_SCRIPT="52_create_database.sh"

# stuff to run a DB instance
ENV ORACLE_SID=${ORACLE_SID:-"TDB183S"} \
   ORACLE_DATA=${ORACLE_DATA:-"/u01"} \
   DEFAULT_DOMAIN=${DEFAULT_DOMAIN:-"postgasse.org"}  \
   PORT=${PORT:-1521} \
   PORT_CONSOLE=${PORT_CONSOLE:-5500}

# same same but different ...
# third ENV so that variable get substituted
ENV PATH=${PATH}:"${ORACLE_HOME}/bin:${ORADBA_INIT}:${ORACLE_HOME}/OPatch/:/usr/sbin:$PATH" \
    LD_LIBRARY_PATH="${ORACLE_HOME}/lib:/usr/lib" \
    CLASSPATH="${ORACLE_HOME}/jlib:${ORACLE_HOME}/rdbms/jlib"

# RUN as user root
# ----------------------------------------------------------------------
# get the OraDBA init script to setup the OS and later OUD
RUN mkdir -p ${DOWNLOAD} && \
   GITHUB_URL="https://github.com/oehrlis/oradba_init/raw/master/bin" && \
   curl -Lsf ${GITHUB_URL}/${SETUP_INIT} -o ${DOWNLOAD}/${SETUP_INIT} && \
   chmod 755 ${DOWNLOAD}/${SETUP_INIT} && \
   ${DOWNLOAD}/${SETUP_INIT} && \
   yum -y install which oracle-database-preinstall-18c file openssl && \
   rm -rf /var/cache/yum

# New stage for installing the database binaries
# ----------------------------------------------------------------------
FROM base AS builder

# COPY database software if part of the build context
COPY *zip* "${SOFTWARE}/"
COPY *rpm* "${SOFTWARE}/"

# RUN as user root
# ----------------------------------------------------------------------
RUN cd ${SOFTWARE} && \
   yum -y install ${SOFTWARE}/$DB_BASE_PKG && \
   rm -rf /var/cache/yum && \
   mkdir -p /home/oracle && \
   chown -R oracle:oinstall /home/oracle

# RUN as oracle
# Switch to user oracle, oracle software has to be installed as regular user
# ----------------------------------------------------------------------
USER oracle
# Install BasEnv
RUN ${ORADBA_INIT}/${SETUP_BASENV}

# New layer for database runtime
# ----------------------------------------------------------------------
FROM base

USER oracle
# copy binaries
COPY --chown=oracle:oinstall --from=builder $ORACLE_BASE $ORACLE_BASE

# copy basenv profile stuff
COPY --chown=oracle:oinstall --from=builder /home/oracle/.BE_HOME /home/oracle/.TVDPERL_HOME /home/oracle/.bash_profile /home/oracle/

# RUN as root post install scripts
USER root
RUN mkdir -p $ORACLE_BASE/scripts/setup && \
   mkdir $ORACLE_BASE/scripts/startup && \
   ln -s $ORACLE_BASE/scripts /docker-entrypoint-initdb.d && \
   mkdir -p ${ORACLE_DATA}/oradata && \
   chown -R oracle:oinstall ${ORACLE_DATA}/oradata && \
   cd $HOME && \
   target_txt=$(cat /etc/security/limits.d/oracle-database-preinstall-18c.conf | grep -e 'oracle *hard *memlock*') && \
   sed -i "/^$target_txt/ c#$target_txt" /etc/security/limits.d/oracle-database-preinstall-18c.conf

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