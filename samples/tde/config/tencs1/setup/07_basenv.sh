#!/bin/bash
# -----------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# -----------------------------------------------------------------------
# Name.......: 07_basenv.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
# Editor.....: Stefan Oehrli
# Date.......: 2019.02.20
# Revision...: --
# Purpose....: Script to configure SQLNet
# Notes......: --
# Reference..: https://github.com/oehrlis/oudbase
# License....: Apache License Version 2.0, January 2004 as shown
#              at http://www.apache.org/licenses/
# -----------------------------------------------------------------------
# Modified...:
# see git revision history with git log for more information on changes
# -----------------------------------------------------------------------

sed -i 's/30/10/' /u00/app/oracle/local/dba/etc/sidtab
sed -i '/if \[ "`id -un`" = "grid" \]; then/,/export BE_INITIALSID/d' /home/oracle/.bash_profile
# - EOF -----------------------------------------------------------------
