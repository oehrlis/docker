#!/bin/bash
# ------------------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# ------------------------------------------------------------------------------
# Name.......: 15_recover_standby.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
# Date.......: 2025.01.17
# Version....: v1.0.0
# Usage......: 15_recover_standby.sh
# Purpose....: Template for RMAN script execution with automatic log file
# Notes......: Ensure Oracle environment variables are set before running
# Reference..: 
# License....: Apache License Version 2.0
# ------------------------------------------------------------------------------
# Modified...:
# see git revision history with git log for more information on changes
# ------------------------------------------------------------------------------

# Variables
ORACLE_SID_SRC="TENCS1"

# Get script directory and name
SCRIPT_DIR=$(dirname "$(realpath "$0")")
SCRIPT_NAME=$(basename "$0" .sh)

# Generate timestamp and log file name
TIMESTAMP=$(date "+%Y%m%d_%H%M%S")
LOG_FILE="/tmp/${SCRIPT_NAME}_${TIMESTAMP}.log"

# - configure instance ---------------------------------------------------------
echo "recover standby database from service ${ORACLE_SID_SRC}:"
echo "  ORACLE_SID          :   ${ORACLE_SID}"
echo "  ORACLE_SID_SRC      :   ${ORACLE_SID_SRC}"
echo "  ORACLE_SID_DST      :   ${ORACLE_SID_DST}"
echo "  ORACLE_BASE         :   ${ORACLE_BASE}" 
echo "  ORACLE_HOME         :   ${ORACLE_HOME}"
echo "  LOG_FILE            :   ${LOG_FILE}"

# Execute RMAN with heredoc
rman target / <<EOF | tee -a "$LOG_FILE"
# ------------------------------------------------------------------------------
# RMAN recover standby database from service ${ORACLE_SID_SRC}
# ------------------------------------------------------------------------------
recover standby database from service ${ORACLE_SID_SRC};
EOF

# Check for errors in the log file
if grep -i "RMAN-" "$LOG_FILE" > /dev/null; then
    echo "RMAN encountered errors. Check the log: $LOG_FILE"
    exit 2
else
    echo "RMAN backup completed successfully. Log: $LOG_FILE"
fi

# - EOF ------------------------------------------------------------------------
