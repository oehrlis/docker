# ----------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ----------------------------------------------------------------------
# Name.......: Dockerfile
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2019.10.17
# Purpose....: Dockerfile to build Oracle Database image 19.5.0.0
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
FROM  oracle/database:19.5.0.0

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
ENV   ORADBA_INIT="/opt/oradba/bin" 

# scripts to build and run this container
ENV   RUN_SCRIPT="50_run_database.sh" \
      CHECK_SCRIPT="54_check_database.sh" \
      ORACLE_ROOT=${ORACLE_ROOT:-"/u00"} \
      ORACLE_DATA=${ORACLE_DATA:-"/u01"}

# Use second ENV so that variable get substituted
ENV   ORACLE_BASE=${ORACLE_BASE:-$ORACLE_ROOT/app/oracle}

# same same but different ...
# third ENV so that variable get substituted
ENV   PATH=${PATH}:"${ORACLE_BASE}/product/${ORACLE_HOME_NAME}/bin:${ORADBA_INIT}:${ORACLE_BASE}/product/${ORACLE_HOME_NAME}/OPatch/:/usr/sbin:$PATH" \
      ORACLE_HOME=${ORACLE_BASE}/product/${ORACLE_HOME_NAME}

# RUN as oracle
# Switch to user oracle, oracle software has to be installed as regular user
# ----------------------------------------------------------------------
USER  oracle
RUN   cd $ORACLE_HOME/rdbms/lib && \
      make -f ins_rdbms.mk uniaud_on ioracle && \
      ${ORACLE_HOME}/bin/roohctl -enable

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