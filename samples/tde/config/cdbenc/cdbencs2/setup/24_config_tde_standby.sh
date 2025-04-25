#!/bin/bash
# ------------------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# ------------------------------------------------------------------------------
# Name.......: 24_config_tde_standby.sh
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

mkdir -pv ${ORACLE_BASE}/admin/${ORACLE_SID}/wallet/backups
mkdir -pv ${ORACLE_BASE}/admin/${ORACLE_SID}/wallet/tde
mkdir -pv ${ORACLE_BASE}/admin/${ORACLE_SID}/wallet/tde_seps

echo "INFO: Copy wallet files from common folder"
if [ -f ${COMMON_DIR}/ewallet.p12 ]; then
    cp -v ${COMMON_DIR}/ewallet.p12 ${ORACLE_BASE}/admin/${ORACLE_SID}/wallet/tde/ewallet.p12 
fi

echo "INFO: Copy wallet password files to common folder"
if [ -f ${COMMON_DIR}/wallet_pwd.txt ]; then
    cp -v ${COMMON_DIR}/wallet_pwd.txt ${ORACLE_BASE}/admin/${ORACLE_SID}/wallet/wallet_pwd.txt 
fi

echo "INFO: Remove SSO files"
if [ -f ${ORACLE_BASE}/admin/${ORACLE_SID}/wallet/tde_seps/cwallet.sso ]; then
    rm -v ${ORACLE_BASE}/admin/${ORACLE_SID}/wallet/tde_seps/cwallet.sso 
fi

if [ -f ${ORACLE_BASE}/admin/${ORACLE_SID}/wallet/tde/cwallet.sso ]; then
    rm -v ${ORACLE_BASE}/admin/${ORACLE_SID}/wallet/tde/cwallet.sso 
fi

WALLET_PWD=$(cat ${ORACLE_BASE}/admin/${ORACLE_SID}/wallet/wallet_pwd.txt)

cd ${ORACLE_BASE}/local/oradba/sql

echo "INFO: run tde scripts"
${ORACLE_HOME}/bin/sqlplus -S -L /nolog <<EOFSQL
    connect / as sysdba
    @idenc_wroot
    STARTUP FORCE MOUNT;
    ALTER SYSTEM SET TDE_CONFIGURATION='KEYSTORE_CONFIGURATION=FILE' scope=both;
    ADMINISTER KEY MANAGEMENT ADD SECRET '${WALLET_PWD}' FOR CLIENT 'TDE_WALLET' TO LOCAL AUTO_LOGIN KEYSTORE '${ORACLE_BASE}/admin/${ORACLE_SID}/wallet/tde_seps';
    ADMINISTER KEY MANAGEMENT SET KEYSTORE OPEN FORCE KEYSTORE IDENTIFIED BY EXTERNAL STORE;
    ADMINISTER KEY MANAGEMENT CREATE LOCAL AUTO_LOGIN KEYSTORE FROM KEYSTORE '${ORACLE_BASE}/admin/${ORACLE_SID}/wallet/tde' IDENTIFIED BY "${WALLET_PWD}";
    STARTUP FORCE MOUNT;
    @ssenc_info.sql
    exit;
EOFSQL

# - EOF ------------------------------------------------------------------------
