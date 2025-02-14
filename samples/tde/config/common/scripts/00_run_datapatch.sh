#!/bin/bash
# ------------------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# ------------------------------------------------------------------------------
# Name.......: 00_run_datapatch.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2024.12.12
# Revision...: --
# Purpose....: run datapatch for regular DB, CDB and JVM
# Notes......: --
# Reference..: https://github.com/oehrlis/oudbase
# License....: Apache License Version 2.0
# ------------------------------------------------------------------------------
# Modified...:
# see git revision history with git log for more information on changes
# ------------------------------------------------------------------------------

# - Get DB configuration info -------------------------------------------
# Check if DB is a container database
CDB_STATUS=$(${ORACLE_HOME}/bin/sqlplus -S -L /nolog <<EOFSQL 
connect / as sysdba
SET VERIFY OFF FEEDBACK OFF HEADING OFF PAGES 0 LINES 40 TRIMSPOOL on SERVEROUTPUT ON
SELECT decode(count(name),0,'FALSE','TRUE') from v\$pdbs;
EOFSQL
)

# - configure instance --------------------------------------------------
echo "Run script for Database ${ORACLE_SID}:"
echo "  ORACLE_SID          :   ${ORACLE_SID}"
echo "  ORACLE_HOME         :   ${ORACLE_HOME}"
echo "  CDB_STATUS          :   ${CDB_STATUS}"

# - configure instance --------------------------------------------------
# - check if PDB is installed -------------------------------------------
if [ "${CDB_STATUS^^}" == "TRUE" ]; then
    echo "Database is a CDB, open all PDBs..."
    ${ORACLE_HOME}/bin/sqlplus -S -L /nolog <<EOFSQL 
    CONNECT / AS SYSDBA
    ALTER PLUGGABLE DATABASE ALL OPEN;
EOFSQL
fi

# - run datapatch -------------------------------------------------------
echo "run datapatch -verbose"
$ORACLE_HOME/OPatch/datapatch -verbose
# - EOF -----------------------------------------------------------------