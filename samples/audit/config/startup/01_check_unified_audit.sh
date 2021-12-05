#!/bin/bash
# -----------------------------------------------------------------------
# Trivadis AG, Business Development & Support (BDS)
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------
# Name.......: 01_check_unified_audit.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2019.02.20
# Revision...: --
# Purpose....: Script to check and enable unified audit.
# Notes......: --
# Reference..: https://github.com/oehrlis/oudbase
# License....: Apache License Version 2.0, January 2004 as shown
#              at http://www.apache.org/licenses/
# -----------------------------------------------------------------------
# Modified...:
# see git revision history with git log for more information on changes
# -----------------------------------------------------------------------

# - configure SQLNet ----------------------------------------------------

# - configure instance --------------------------------------------------
echo "Verify Unified Audit for Database ${ORACLE_SID}:"
echo "  ORACLE_SID          :   ${ORACLE_SID}"
echo "  ORACLE_HOME         :   ${ORACLE_HOME}"

# get the status from the DB
UNIFIED_AUDIT_STATUS=$(${ORACLE_HOME}/bin/sqlplus -S -L /nolog <<EOFSQL 
connect / as sysdba
SET VERIFY OFF FEEDBACK OFF HEADING OFF PAGES 0 LINES 40 TRIMSPOOL on SERVEROUTPUT ON
SELECT value FROM v\$option WHERE parameter = 'Unified Auditing';
EOFSQL
)

if [ "${UNIFIED_AUDIT_STATUS^^}" == "TRUE" ]; then
    echo "unified audit option is enabled"
elif [ "${UNIFIED_AUDIT_STATUS^^}" == "FALSE" ]; then
    echo "unified audit option is not enabled and will no be enabled"
    echo "Stop Database ${ORACLE_SID}:"
    ${ORACLE_HOME}/bin/sqlplus -S -L /nolog <<EOFSQL
    connect / as sysdba
    SELECT value FROM v\$option WHERE parameter = 'Unified Auditing';
    shutdown immediate;
    exit;
EOFSQL

    echo "Relink Database ${ORACLE_SID} to enable unified audit:"
    cd $ORACLE_HOME/rdbms/lib
    make -f ins_rdbms.mk uniaud_on ioracle

    echo "Start Database ${ORACLE_SID}:"
    ${ORACLE_HOME}/bin/sqlplus -S -L /nolog <<EOFSQL
    connect / as sysdba
    startup;
    SELECT value FROM v\$option WHERE parameter = 'Unified Auditing';
    exit;
EOFSQL
else
    echo "Can not determin status of unified audit option is enabled"  
fi
# - EOF -----------------------------------------------------------------