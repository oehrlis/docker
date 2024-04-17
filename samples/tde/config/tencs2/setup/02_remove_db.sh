#!/bin/bash
# -----------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# -----------------------------------------------------------------------
# Name.......: 03_eus_config.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
# Editor.....: Stefan Oehrli
# Date.......: 2019.02.20
# Revision...: --
# Purpose....: Script to enable unified audit.
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
echo "Enable Unified Audit for Database ${ORACLE_SID}:"
echo "  ORACLE_SID          :   ${ORACLE_SID}"
echo "  ORACLE_HOME         :   ${ORACLE_HOME}"

echo "Stop Database ${ORACLE_SID}:"
${ORACLE_HOME}/bin/sqlplus -S -L /nolog <<EOFSQL
connect / as sysdba
shutdown abort;
exit;
EOFSQL

rm -rf /u02/fast_recovery_area/${ORACLE_SID}
rm -rf /u0?/oradata/${ORACLE_SID}

# - EOF -----------------------------------------------------------------
