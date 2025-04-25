#!/bin/bash
# ------------------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# ------------------------------------------------------------------------------
# Name.......: 22_duplicate_cdbencs1.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
# Date.......: 2025.01.17
# Version....: v1.0.0
# Purpose....: Script to duplicate Oracle database using RMAN as standby
# Notes......: Ensure Oracle environment variables are set before running
# Reference..: --
# License....: Apache License Version 2.0
# ------------------------------------------------------------------------------
# Modified...:
# see git revision history with git log for more information on changes
# ------------------------------------------------------------------------------
# - Customization --------------------------------------------------------------
# - just add/update any kind of customized environment variable here
ORACLE_SID_SRC="CDBENCS1"
ORACLE_SID_DST=$ORACLE_SID
# - End of Customization -------------------------------------------------------

# - Default Values -------------------------------------------------------------
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
# - EOF Default Values ---------------------------------------------------------

# - configure instance ---------------------------------------------------------
echo "INFO: Clone ${ORACLE_SID_SRC} to ${ORACLE_SID_DST}:"
echo "INFO:   ORACLE_SID          :   ${ORACLE_SID}"
echo "INFO:   ORACLE_SID_SRC      :   ${ORACLE_SID_SRC}"
echo "INFO:   ORACLE_SID_DST      :   ${ORACLE_SID_DST}"
echo "INFO:   ORACLE_BASE         :   ${ORACLE_BASE}" 
echo "INFO:   ORACLE_HOME         :   ${ORACLE_HOME}"
echo "INFO:   LOG_FILE            :   ${LOG_FILE}"

mkdir -pv /u01/oradata/${ORACLE_SID}
mkdir -pv /u01/fast_recovery_area/${ORACLE_SID}

# - remove existing configuration
if [ -f ${ORACLE_HOME}/dbs/init${ORACLE_SID}.ora ]; then
  rm -rf ${ORACLE_HOME}/dbs/init${ORACLE_SID}.ora
fi

if [ -f ${ORACLE_HOME}/dbs/spfile${ORACLE_SID}.ora ]; then
  rm -rf ${ORACLE_HOME}/dbs/spfile${ORACLE_SID}.ora
fi

# Execute RMAN with heredoc
rman <<EOF | tee -a "$LOG_FILE"
# ------------------------------------------------------------------------------
# RMAN duplicate database ${ORACLE_SID_DST} from target ${ORACLE_SID_SRC}
# ------------------------------------------------------------------------------
# Connect to target and auxiliary databases
connect auxiliary sys/${ORACLE_PWD}@${ORACLE_SID_DST,,}:${PORT}/${ORACLE_SID_DST}_DGMGRL.${DOMAIN_NAME}
connect target sys/${ORACLE_PWD}@${ORACLE_SID_SRC,,}:${PORT}/${ORACLE_SID_SRC}_DGMGRL.${DOMAIN_NAME}

# startup clone database
startup clone nomount;

RUN {
allocate channel eugen type disk;
allocate auxiliary channel hanni type disk;

DUPLICATE TARGET DATABASE TO '${ORACLE_SID_DST}' FROM ACTIVE DATABASE
spfile
  parameter_value_convert '${ORACLE_SID_SRC,,}','${ORACLE_SID_DST,,}','${ORACLE_SID_SRC}','${ORACLE_SID_DST}'
  set db_unique_name='${ORACLE_SID_DST}'
  set db_file_name_convert='${ORACLE_SID_SRC,,}','${ORACLE_SID_DST,,}','${ORACLE_SID_SRC}','${ORACLE_SID_DST}'
  set log_file_name_convert='${ORACLE_SID_SRC,,}','${ORACLE_SID_DST,,}','${ORACLE_SID_SRC}','${ORACLE_SID_DST}'
  set control_files='/u01/oradata/${ORACLE_SID_DST}/control01${ORACLE_SID_DST}.dbf','/u01/fast_recovery_area/${ORACLE_SID_DST}/control02${ORACLE_SID_DST}.dbf'
  set log_archive_max_processes='5'
  set log_archive_config='dg_config=(${ORACLE_SID_SRC,,},${ORACLE_SID_DST,,})';
}
EOF

# Check for errors in the log file
if grep -i "RMAN-" "$LOG_FILE" > /dev/null; then
    echo "ERROR: RMAN encountered errors. Check the log: $LOG_FILE"
    exit 2
else
    echo "INFO: RMAN backup completed successfully. Log: $LOG_FILE"
fi
# - EOF ------------------------------------------------------------------------
