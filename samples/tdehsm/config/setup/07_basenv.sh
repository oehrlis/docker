#!/bin/bash
# ------------------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# ------------------------------------------------------------------------------
# Name.......: 07_basenv.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
# Date.......: 2025.01.17
# Version....: v1.0.0
# Purpose....: Script to fix some basenv configuration
# Notes......: --
# Reference..: --
# License....: Apache License Version 2.0
# ------------------------------------------------------------------------------
# Modified...:
# see git revision history with git log for more information on changes
# ------------------------------------------------------------------------------
echo "INFO: Fix basenv config for ${ORACLE_SID}"
sed -i 's/30/10/' /u00/app/oracle/local/dba/etc/sidtab
sed -i '/if \[ "`id -un`" = "grid" \]; then/,/export BE_INITIALSID/d' /home/oracle/.bash_profile
# - EOF ------------------------------------------------------------------------
