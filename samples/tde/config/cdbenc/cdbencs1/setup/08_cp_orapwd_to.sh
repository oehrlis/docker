#!/bin/bash
# ------------------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# ------------------------------------------------------------------------------
# Name.......: 08_cp_orapwd_to.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
# Date.......: 2025.01.17
# Version....: v1.0.0
# Purpose....: Script to copy the orapwd file to the common folder
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

# - configure instance ---------------------------------------------------------
echo "INFO: Copy orapw file of ${ORACLE_SID} to common folder:"
echo "INFO:   ORACLE_SID          :   ${ORACLE_SID}"
echo "INFO:   ORACLE_BASE         :   ${ORACLE_BASE}" 
echo "INFO:   ORACLE_HOME         :   ${ORACLE_HOME}"
echo "INFO:   COMMON_DIR          :   ${COMMON_DIR}"

if [ -f ${ORACLE_HOME}/dbs/orapw${ORACLE_SID} ]; then
    cp -v ${ORACLE_HOME}/dbs/orapw${ORACLE_SID} ${COMMON_DIR}/orapw_file_src
fi

if [ -f ${ORACLE_BASE}/admin/${ORACLE_SID}/etc/${ORACLE_SID}_password.txt ]; then
    cp -v ${ORACLE_BASE}/admin/${ORACLE_SID}/etc/${ORACLE_SID}_password.txt ${COMMON_DIR}/SYS_password_src.txt
fi

# - EOF ------------------------------------------------------------------------
