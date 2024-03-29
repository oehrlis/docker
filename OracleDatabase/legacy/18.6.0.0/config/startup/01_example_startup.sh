#!/bin/bash
# -----------------------------------------------------------------------
# Trivadis AG, Business Development & Support (BDS)
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------
# Name.......: 01_example_startup.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2019.03.16
# Revision...: --
# Purpose....: Example startup script.
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
echo "Example startup script for Oracle SID ${ORACLE_SID}:"
echo "  ORACLE_SID          :   ${ORACLE_SID}"
echo "  ORACLE_HOME         :   ${ORACLE_HOME}"

echo "Instance status for Oracle SID ${ORACLE_SID}:"
${ORACLE_HOME}/bin/sqlplus -S -L /nolog <<EOFSQL
connect / as sysdba
set linesize 160
col host_name for a20
SELECT instance_number,instance_name,host_name,version,status FROM v\$instance;
EOFSQL
# - EOF -----------------------------------------------------------------
