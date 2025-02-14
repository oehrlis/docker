#!/bin/bash
# ------------------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# ------------------------------------------------------------------------------
# Name.......: 31_config_dg.sh
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
# - End of Customization -------------------------------------------------------

# - Default Values -------------------------------------------------------------
# Get script directory and name
# - EOF Default Values ---------------------------------------------------------

# - configure instance ---------------------------------------------------------
echo "INFO: Restart standby database ${ORACLE_SID}:"

dgmgrl -echo / as sysdba "startup force mount"
dgmgrl -echo / as sysdba "show configuration"
# - EOF ------------------------------------------------------------------------
