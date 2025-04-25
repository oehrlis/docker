#!/bin/bash
# ------------------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# ------------------------------------------------------------------------------
# Name.......: 24_config_tde.sh
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
echo "INFO: Configure TDE for ${ORACLE_SID}:"
echo "INFO:   ORACLE_SID          :   ${ORACLE_SID}"
echo "INFO:   ORACLE_BASE         :   ${ORACLE_BASE}" 
echo "INFO:   ORACLE_HOME         :   ${ORACLE_HOME}"
echo "INFO:   COMMON_DIR          :   ${COMMON_DIR}"

cd ${ORACLE_BASE}/local/oradba/sql

echo "INFO: run isenc_tde.sql script"
${ORACLE_HOME}/bin/sqlplus -S -L /nolog <<EOFSQL
    connect / as sysdba
    @isenc_tde.sql
    exit;
EOFSQL

echo "INFO: Copy wallet files to common folder"
if [ -f ${ORACLE_BASE}/admin/${ORACLE_SID}/wallet/tde/ewallet.p12 ]; then
    cp -v ${ORACLE_BASE}/admin/${ORACLE_SID}/wallet/tde/ewallet.p12 ${COMMON_DIR}/ewallet.p12
fi

echo "INFO: Copy wallet password files to common folder"
if [ -f ${ORACLE_BASE}/admin/${ORACLE_SID}/wallet/wallet_pwd.txt ]; then
    cp -v ${ORACLE_BASE}/admin/${ORACLE_SID}/wallet/wallet_pwd.txt ${COMMON_DIR}/wallet_pwd.txt
fi

echo "INFO: Generate Master Encryption Key export password"
KEY_PWD=$(pwgen -1 20)
echo "${KEY_PWD}" > ${COMMON_DIR}/${ORACLE_SID}_masterkey_pwd.txt

echo "INFO: Export Master Encryption Key to common folder"
${ORACLE_HOME}/bin/sqlplus -S -L /nolog <<EOFSQL
    connect / as sysdba
    COLUMN key_id NEW_VALUE key_id  NOPRINT
    SELECT replace(utl_raw.cast_to_varchar2(utl_encode.base64_encode('01' || masterkeyid )),'=','AAAAAAAAAAAAAAAAAAAAAAAAAAAAA') key_id FROM v\$database_key_info;
    ADMINISTER KEY MANAGEMENT EXPORT KEYS WITH SECRET "${KEY_PWD}" TO '${COMMON_DIR}/${ORACLE_SID}_masterkey' FORCE KEYSTORE IDENTIFIED BY EXTERNAL STORE WITH IDENTIFIER IN '&key_id';
    exit;
EOFSQL
# - EOF ------------------------------------------------------------------------