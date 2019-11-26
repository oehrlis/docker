#!/bin/bash
# -----------------------------------------------------------------------
# Trivadis AG, Business Development & Support (BDS)
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------
# Name.......: 10_cleanup_backups.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2019.11.26
# Revision...: --
# Purpose....: RMAN remove backups from flash recovery area.
# Notes......: --
# Reference..: https://github.com/oehrlis/oudbase
# License....: GPL-3.0+
# -----------------------------------------------------------------------
# Modified...:
# see git revision history with git log for more information on changes
# -----------------------------------------------------------------------

# - configure SQLNet ----------------------------------------------------

# - configure instance --------------------------------------------------
echo "Example startup script for Database ${ORACLE_SID}:"
echo "  ORACLE_SID          :   ${ORACLE_SID}"
echo "  ORACLE_HOME         :   ${ORACLE_HOME}"

echo "RMAN backup of Database ${ORACLE_SID}:"
${ORACLE_HOME}/bin/rman <<EOFRMAN
connect target /
DELETE NOPROMPT ARCHIVELOG ALL;
DELETE NOPROMPT BACKUP;
exit;
EOFRMAN
# - EOF -----------------------------------------------------------------