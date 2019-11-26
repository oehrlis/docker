#!/bin/bash
# ---------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: 00_prepare_env_tspitr.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2019.11.25
# Revision...: 
# Purpose....: Script to add a tnsname entry for the PDB TSPITR.
# Notes......: ...
# Reference..: --
# License....: Licensed under the Universal Permissive License v 1.0 as 
#              shown at http://oss.oracle.com/licenses/upl.
# ---------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# ---------------------------------------------------------------------------
# - Customization -----------------------------------------------------------
# - just add/update any kind of customized environment variable here
PDB_NAME="tspitr1"
ORACLE_BASE=${ORACLE_BASE:-"/u00/app/oracle"}
TNS_ADMIN=${TNS_ADMIN:-"${ORACLE_BASE}/network/admin"}
PDB_DOMAIN=$(grep -i NAMES.DEFAULT_DOMAIN $TNS_ADMIN/sqlnet.ora|cut -d= -f2)
PDB_TNSNAME="${PDB_NAME}.${PDB_DOMAIN}"
# - End of Customization ----------------------------------------------------

# - Environment Variables ---------------------------------------------------

# - EOF Environment Variables -----------------------------------------------

# - Main --------------------------------------------------------------------
echo "= Prepare PDB Environment ============================================="

# add the tnsnames entry
if [ $( grep -ic $PDB_TNSNAME ${TNS_ADMIN}/tnsnames.ora) -eq 0 ]; then
    echo "Add $PDB_TNSNAME to ${TNS_ADMIN}/tnsnames.ora."
    echo "${PDB_TNSNAME}=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$(hostname))(PORT=1521))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=${PDB_NAME})))">>${TNS_ADMIN}/tnsnames.ora
else
    echo "TNS name entry ${PDB_TNSNAME} does exists."
fi
echo "= Finish PDB Environment =============================================="
# --- EOF --------------------------------------------------------------------