#!/bin/bash
# ------------------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# ------------------------------------------------------------------------------
# Name.......: 24_config_dg.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
# Date.......: 2025.01.17
# Version....: v1.0.0
# Purpose....: Configure Data Guard for primary and standby database
# Notes......: Ensure Oracle environment variables are set before running
# Reference..: --
# License....: Apache License Version 2.0
# ------------------------------------------------------------------------------
# Modified...:
# see git revision history with git log for more information on changes
# ------------------------------------------------------------------------------

# - Customization --------------------------------------------------------------
# - just add/update any kind of customized environment variable here
ORACLE_SID_STANDBY="TENCS2" 
# - End of Customization -------------------------------------------------------

# - Default Values -------------------------------------------------------------
# Get script directory and name
# - EOF Default Values ---------------------------------------------------------

# - configure instance ---------------------------------------------------------
echo "INFO: Configure primary database ${ORACLE_SID}:"
echo "INFO:   ORACLE_SID          :   ${ORACLE_SID}"
echo "INFO:   ORACLE_BASE         :   ${ORACLE_BASE}" 
echo "INFO:   ORACLE_HOME         :   ${ORACLE_HOME}"
echo "INFO:   LOG_FILE            :   ${LOG_FILE}"

sleep 30
dgmgrl -echo / as sysdba "create configuration 'dg_tenc' as  primary database is '${ORACLE_SID}' connect identifier is ${ORACLE_SID}"
dgmgrl -echo / as sysdba "add database '${ORACLE_SID_STANDBY}' as connect identifier is ${ORACLE_SID_STANDBY}"
dgmgrl -echo / as sysdba "enable configuration"
dgmgrl -echo / as sysdba "show configuration"
dgmgrl -echo / as sysdba "startup force"
dgmgrl -echo / as sysdba "show configuration"

# - EOF ------------------------------------------------------------------------
