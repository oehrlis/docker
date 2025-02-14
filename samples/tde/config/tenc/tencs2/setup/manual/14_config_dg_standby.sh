#!/bin/bash
# ------------------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# ------------------------------------------------------------------------------
# Name.......: 14_config_dg_standby.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
# Date.......: 2025.01.17
# Version....: v1.0.0
# Usage......: 14_config_dg_standby.sh
# Purpose....: Template for RMAN script execution with automatic log file
# Notes......: Ensure Oracle environment variables are set before running
# Reference..: 
# License....: Apache License Version 2.0
# ------------------------------------------------------------------------------
# Modified...:
# see git revision history with git log for more information on changes
# ------------------------------------------------------------------------------

# Variables
HOSTNAME=$(hostname)
PORT=1521
DOMAIN_NAME="trivadislabs.com"
ORACLE_PWD=$(cat ${ORACLE_BASE}/admin/${ORACLE_SID}/etc/${ORACLE_SID}_password.txt)  

# Get script directory and name
SCRIPT_DIR=$(dirname "$(realpath "$0")")
SCRIPT_NAME=$(basename "$0" .sh)

# Generate timestamp and log file name
TIMESTAMP=$(date "+%Y%m%d_%H%M%S")
LOG_FILE="/tmp/${SCRIPT_NAME}_${TIMESTAMP}.log"

# - configure instance ---------------------------------------------------------
echo "Configure primary database ${ORACLE_SID}:"
echo "  ORACLE_SID          :   ${ORACLE_SID}"
echo "  ORACLE_BASE         :   ${ORACLE_BASE}" 
echo "  ORACLE_HOME         :   ${ORACLE_HOME}"
echo "  LOG_FILE            :   ${LOG_FILE}"

dgmgrl -echo / as sysdba "add database '${ORACLE_SID}' as connect identifier is ${ORACLE_SID,,}"
dgmgrl -echo / as sysdba "enable configuration"
dgmgrl -echo / as sysdba "show configuration"
# - EOF ------------------------------------------------------------------------
