#!/bin/bash
# ------------------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# ------------------------------------------------------------------------------
# Name.......: 02_enable_unified_audit.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
# Editor.....: Stefan Oehrli
# Date.......: 2025.01.17
# Version....: v1.0.0
# Purpose....: Script to check and enable unified audit for an Oracle database.
# Notes......: This script will check the current status of unified auditing and
#              enable it if it is not already enabled.
# Reference..: --
# License....: Apache License Version 2.0
# ------------------------------------------------------------------------------
# Modified...:
# see git revision history with git log for more information on changes
# ------------------------------------------------------------------------------

# - check unified audit status
echo "INFO: Check Unified Audit status for Database ${ORACLE_SID}:"
UNIFIED_AUDIT_STATUS=$(${ORACLE_HOME}/bin/sqlplus -s / as sysdba <<EOFSQL
    set heading off feedback off verify off echo off
    SELECT value FROM v\$option WHERE parameter = 'Unified Auditing';
    exit;
EOFSQL
)
# - remove trailing line break
UNIFIED_AUDIT_STATUS=$(echo $UNIFIED_AUDIT_STATUS | tr -d '\n')

# - Stop database if unified audit is not enabled
if [[ "$UNIFIED_AUDIT_STATUS" == "TRUE" ]]; then
    echo "INFO: Unified Audit is already enabled for Database ${ORACLE_SID}."
else
    echo "INFO: Unified Audit is not enabled for Database ${ORACLE_SID}. Enabling now..."
    echo "INFO: Stop Database ${ORACLE_SID}:"
    ${ORACLE_HOME}/bin/sqlplus -S -L /nolog <<EOFSQL
        connect / as sysdba
        shutdown immediate;
        exit;
EOFSQL

    # - Relink database binaries to enable unified audit
    echo "INFO: Relink Database ${ORACLE_SID} to enable unified audit:"
    cd $ORACLE_HOME/rdbms/lib
    make -f ins_rdbms.mk uniaud_on ioracle

    # - start database
    echo "INFO: Start Database ${ORACLE_SID}:"
    ${ORACLE_HOME}/bin/sqlplus -S -L /nolog <<EOFSQL
        connect / as sysdba
        startup;
        SELECT value FROM v\$option WHERE parameter = 'Unified Auditing';
        exit;
EOFSQL
fi
# - EOF ------------------------------------------------------------------------
