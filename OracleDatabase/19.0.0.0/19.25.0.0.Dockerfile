# ------------------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# ------------------------------------------------------------------------------
# Name.......: Dockerfile
# Author.....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
# Editor.....: Stefan Oehrli
# Date.......: 2024.10.10
# Purpose....: Dockerfile to build Oracle Database image 19.0.0.0 plus available RU
# Notes......: --
# Reference..: --
# License....: Apache License Version 2.0, January 2004 as shown
#              at http://www.apache.org/licenses/
# ------------------------------------------------------------------------------

# Pull base image
# ------------------------------------------------------------------------------
# Use oraclelinux:8 as the base image for both build and runtime stages
ARG BASE_IMAGE=oraclelinux:8
FROM ${BASE_IMAGE} AS base

# Global ARGs available in all stages
# ------------------------------------------------------------------------------
# Platform variable used in buildx
ARG TARGETPLATFORM
ARG TARGETARCH
# Arguments for Oracle Installation
ARG SLIMMING=true
ARG ORACLE_ROOT=/u00
ARG ORACLE_DATA=/u01
ARG ORACLE_ARCH=/u01
ARG ORACLE_BASE=/u00/app/oracle
ARG ORAREPO=orarepo
ARG ORACLE_RELEASE="19.0.0.0"
ARG ORACLE_RELEASE_UPDATE="19.25.0.0"
ARG DEFAULT_DOMAIN="postgasse.org"
ARG PORT=1521
ARG PORT_CONSOLE=5500

# Maintainer
# ------------------------------------------------------------------------------
LABEL provider="stefan.oehrli@oradba.ch" \
      description="Docker image for Oracle Database $ORACLE_RELEASE with RU $ORACLE_RELEASE_UPDATE" \
      issues="https://github.com/oehrlis/docker/issues"           \
      volume.data="${ORACLE_DATA}"                                \
      volume.setup.location1="${ORACLE_DATA}/config/setup"        \
      volume.startup.location1="${ORACLE_DATA}/config/startup"    \
      port.listener="1521"                                        \
      port.oemexpress="5500"

# Environment variables required for this build 
# Change them carefully and wise!
# ------------------------------------------------------------------------------
# Software stage area, repository, binary packages and patchs
ENV   DOWNLOAD="/tmp/download" \
      SOFTWARE="/opt/stage" \
      SOFTWARE_REPO="$ORAREPO" \
      ORADBA_INIT="/opt/oradba/bin" \
      ORACLE_ROOT=${ORACLE_ROOT} \
      ORACLE_DATA=${ORACLE_DATA} \
      ORACLE_ARCH=${ORACLE_ARCH} \
      DEFAULT_DOMAIN=${DEFAULT_DOMAIN}  \
      PORT=${PORT} \
      PORT_CONSOLE=${PORT_CONSOLE} \
      PATCH_LATER=TRUE \
      SLIMMING=$SLIMMING

# RUN as user root
# ------------------------------------------------------------------------------
# get the OraDBA init scripts to setup the OS, binaries and later the database
RUN   mkdir -p ${DOWNLOAD} && \
      GITHUB_URL="https://github.com/oehrlis/oradba_init/raw/master/bin" && \
      curl -Lsf ${GITHUB_URL}/00_setup_oradba_init.sh -o ${DOWNLOAD}/00_setup_oradba_init.sh && \
      chmod 755 "${DOWNLOAD}"/00_setup_oradba_init.sh && \
      if [ -z $(command -v yum) ]; then microdnf install --nodocs -y yum; fi && \
      yum install -y --nodocs zip unzip findutils oracle-epel-release* && \
      "${DOWNLOAD}"/00_setup_oradba_init.sh && \
      ${ORADBA_INIT}/01_setup_os_db.sh && \
      yum clean all && \
      rm -rf /var/cache/yum

# Set Version specific Oracle environment variables
# ------------------------------------------------------------------------------
ENV   PATH=${PATH}:"${ORACLE_BASE}/product/${ORACLE_RELEASE}/bin:${ORADBA_INIT}:${ORACLE_BASE}/product/${ORACLE_RELEASE}/OPatch/:/usr/sbin:$PATH" \
      ORACLE_HOME="${ORACLE_BASE}/product/${ORACLE_RELEASE}" \
      LD_LIBRARY_PATH="${ORACLE_BASE}/product/${ORACLE_RELEASE}/lib:/usr/lib" \
      CLASSPATH="${ORACLE_BASE}/product/${ORACLE_RELEASE}/jlib:${ORACLE_BASE}/product/${ORACLE_RELEASE}/rdbms/jlib"

# New stage for installing the database binaries
# ------------------------------------------------------------------------------
FROM  base AS builder
# COPY base database software if part of the build context
COPY  --chown=oracle:oinstall software/"${TARGETARCH}"/*zip* "${SOFTWARE}/"
# COPY RU patch if part of the build context
COPY  --chown=oracle:oinstall software/"${TARGETARCH}"/RU_"${ORACLE_RELEASE_UPDATE}"/* "${SOFTWARE}/"

# RUN as oracle
# Switch to user oracle, oracle software has to be installed as regular user
# ------------------------------------------------------------------------------
USER  oracle
# Install Oracle Binaries
# set package name variables based on oracle_package_names_${TARGETARCH}
RUN   . "${SOFTWARE}"/oracle_package_names_"${TARGETARCH}" && \
      export $(cut -d= -f1 "${SOFTWARE}"/oracle_package_names_"${TARGETARCH}") && \
      "${ORADBA_INIT}"/10_setup_db.sh

# Install BasEnv
RUN   export PROCESSOR=$(uname -m) && \
      "${ORADBA_INIT}"/20_setup_basenv.sh

# Install Oracle Patch's
# set package name variables based on oracle_package_names_${TARGETARCH}
RUN   . "${SOFTWARE}"/oracle_package_names_"${TARGETARCH}" && \
      export $(cut -d= -f1 "${SOFTWARE}"/oracle_package_names_"${TARGETARCH}") && \
      "${ORADBA_INIT}"/11_setup_db_patch.sh

# New stage to build database runtime image
# ------------------------------------------------------------------------------
FROM  base

USER  oracle
# copy binaries
COPY  --chown=oracle:oinstall --from=builder "${ORACLE_BASE}" "${ORACLE_BASE}"
# copy oracle inventory
COPY  --chown=oracle:oinstall --from=builder "${ORACLE_ROOT}/app/oraInventory" "${ORACLE_ROOT}/app/oraInventory"
# copy basenv profile stuff
COPY  --chown=oracle:oinstall --from=builder /home/oracle/.BE_HOME /home/oracle/.TVDPERL_HOME /home/oracle/.bash_profile /home/oracle/

# RUN as root post install scripts
USER  root
RUN   "${ORACLE_ROOT}/app/oraInventory/orainstRoot.sh" && \
      "${ORACLE_HOME}/root.sh"

# Finalize target image
# ------------------------------------------------------------------------------
# get back to user oracle
USER  oracle

# expose the listener and em console ports
EXPOSE   ${PORT} ${PORT_CONSOLE}

# Oracle data volume for database instance and configuration files
VOLUME   ["${ORACLE_DATA}"]

# set workding directory
WORKDIR  "${ORACLE_BASE}"

# run container health check
HEALTHCHECK --interval=1m --start-period=5m --timeout=30s \
   CMD ${ORADBA_INIT}/54_check_database.sh >/dev/null || exit 1

# Define default command to start Oracle Database. 
CMD [ "/bin/bash", "-c", "exec ${ORADBA_INIT}/50_run_database.sh" ]
# --- EOF ----------------------------------------------------------------------