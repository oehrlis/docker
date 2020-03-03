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
FILENAME="$(dirname $0)/$(basename $0 .sh)"      # LDIF file based on script name

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

if [ -z "${UNTIL}" ]; then
    echo "No TSPITR on database ${ORACLE_SID}:"
fi

echo "RMAN TSPITR on database ${ORACLE_SID}:"
echo "  ORACLE_SID              :   ${ORACLE_SID}"
echo "  ORACLE_PDB              :   ${ORACLE_PDB}"
echo "  ORACLE_HOME             :   ${ORACLE_HOME}"
echo "  PDB_CREATE_FILE_DEST    :   ${PDB_CREATE_FILE_DEST}"
echo "  Until time              :   ${UNTIL}"

NLS_DATE_FORMAT="DD-MON-RRRR HH24:MI:SS"
export NLS_DATE_FORMAT

# run TSPITR
${ORACLE_HOME}/bin/rman debug trace=/u01/config/startup/${FILENAME}.trc msglog=/u01/config/startup/${FILENAME}.log <<EOFRMAN
connect target /
RECOVER TABLESPACE "${ORACLE_PDB}":users
UNTIL time "to_date('${UNTIL}','DD.MM.YYYY HH24:MI:SS')"
AUXILIARY DESTINATION '/u01/oradata/TRMAN01/TSPITR/directories';
exit;
EOFRMAN

## 
# auxiliary_destination
# - EOF -----------------------------------------------------------------