#!/bin/bash
# -----------------------------------------------------------------------
# Trivadis AG, Business Development & Support (BDS)
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------
# Name.......: 99_example_setup.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2019.03.16
# Revision...: --
# Purpose....: Example setup script.
# Notes......: --
# Reference..: https://github.com/oehrlis/oudbase
# License....: GPL-3.0+
# -----------------------------------------------------------------------
# Modified...:
# see git revision history with git log for more information on changes
# -----------------------------------------------------------------------

# - configure SQLNet ----------------------------------------------------

# - configure instance --------------------------------------------------
echo "Example setup script for Oracle SID ${ORACLE_SID}:"
echo "  ORACLE_SID          :   ${ORACLE_SID}"
echo "  ORACLE_HOME         :   ${ORACLE_HOME}"

echo "Instance status for Oracle SID ${ORACLE_SID}:"
${ORACLE_HOME}/bin/sqlplus -S -L /nolog <<EOFSQL
connect / as sysdba
set linesize 160
col host_name for a20
SELECT instance_number,instance_name,host_name,version,status FROM v$instance;
EOFSQL
# - EOF -----------------------------------------------------------------