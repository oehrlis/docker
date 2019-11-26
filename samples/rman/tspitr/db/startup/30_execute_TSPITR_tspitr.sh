#!/bin/bash
# -----------------------------------------------------------------------
# Trivadis AG, Business Development & Support (BDS)
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------
# Name.......: 30_execute_TSPITR_tspitr.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2019.11.25
# Revision...: --
# Purpose....: RMAN TSPITR for tablespace users.
# Notes......: --
# Reference..: https://github.com/oehrlis/oudbase
# License....: GPL-3.0+
# -----------------------------------------------------------------------
# Modified...:
# see git revision history with git log for more information on changes
# -----------------------------------------------------------------------
export ORACLE_PDB="TSPITR"
# - get the path for before_issue.txt -----------------------------------
PDB_CREATE_FILE_DEST=$(${ORACLE_HOME}/bin/sqlplus -S -L /nolog <<EOFSQL 
connect / as sysdba
SET VERIFY OFF FEEDBACK OFF HEADING OFF PAGES 0 LINES 40 TRIMSPOOL on SERVEROUTPUT ON
ALTER SESSION SET CONTAINER=${ORACLE_PDB};
SELECT value FROM v\$parameter WHERE name='db_create_file_dest';
EOFSQL
)

if [ -f "${PDB_CREATE_FILE_DEST}/before_issue.txt" ]; then
    export UNTIL=$(grep -i TSPITR ${PDB_CREATE_FILE_DEST}/before_issue.txt|cut -d, -f2| sed 's/ *$//g')
else
    export UNTIL=""
fi

# check if UNTIL is defined
if [ -n "${UNTIL}" ]; then
    echo "RMAN TSPITR on database ${ORACLE_SID}:"
    echo "  ORACLE_SID              :   ${ORACLE_SID}"
    echo "  ORACLE_PDB              :   ${ORACLE_PDB}"
    echo "  ORACLE_HOME             :   ${ORACLE_HOME}"
    echo "  PDB_CREATE_FILE_DEST    :   ${PDB_CREATE_FILE_DEST}"
    echo "  Until time              :   ${UNTIL}"

# run TSPITR
    ${ORACLE_HOME}/bin/rman <<EOFRMAN
connect target /
RECOVER TABLESPACE "${ORACLE_PDB}":users
UNTIL time "to_date('${UNTIL}','DD.MM.YYYY HH24:MI:SS')"
AUXILIARY DESTINATION '/u01/oradata/';
ALTER TABLESPACE users ONLINE;
exit;
EOFRMAN
else
    echo "No TSPITR on database ${ORACLE_SID}:"
fi
# - EOF -----------------------------------------------------------------