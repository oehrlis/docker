#!/bin/bash
# ------------------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# ------------------------------------------------------------------------------
# Name.......: 21_cp_orapwd_from.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
# Date.......: 2025.01.17
# Version....: v1.0.0
# Purpose....: Script to copy the orapwd file from the common folder
# Notes......: --
# Reference..: --
# License....: Apache License Version 2.0
# ------------------------------------------------------------------------------
# Modified...:
# see git revision history with git log for more information on changes
# ------------------------------------------------------------------------------

# - Customization --------------------------------------------------------------
# - just add/update any kind of customized environment variable here
COMMON_DIR="/u01/shared"
# - End of Customization -------------------------------------------------------

# - Default Values -------------------------------------------------------------
# - EOF Default Values ---------------------------------------------------------

# - configure instance ---------------------------------------------------------
echo "INFO: Copy orapw file of ${ORACLE_SID} from common folder:"
echo "INFO:   ORACLE_SID          :   ${ORACLE_SID}"
echo "INFO:   ORACLE_BASE         :   ${ORACLE_BASE}" 
echo "INFO:   ORACLE_HOME         :   ${ORACLE_HOME}"
echo "INFO:   COMMON_DIR          :   ${COMMON_DIR}"

if [ -f ${COMMON_DIR}/orapw_file_src ]; then
    cp -v ${COMMON_DIR}/orapw_file_src ${ORACLE_HOME}/dbs/orapw${ORACLE_SID}
fi

if [ -f ${COMMON_DIR}/SYS_password_src.txt ]; then
    cp -v ${COMMON_DIR}/SYS_password_src.txt ${ORACLE_BASE}/admin/${ORACLE_SID}/etc/${ORACLE_SID}_password.txt
fi
# - EOF ------------------------------------------------------------------------
