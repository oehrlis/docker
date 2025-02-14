#!/bin/bash
# ------------------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# ------------------------------------------------------------------------------
# Name.......: 31_config_tde.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
# Date.......: 2025.01.23
# Version....: v1.0.0
# Purpose....: Script to create SPFILE
# Notes......: --
# Reference..: --
# License....: Apache License Version 2.0
# ------------------------------------------------------------------------------
# Modified...:
# see git revision history with git log for more information on changes
# ------------------------------------------------------------------------------

# - Customization --------------------------------------------------------------
# - just add/update any kind of customized environment variable here
ORACLE_SID_SRC="TENCS1"
ORACLE_SID_DST=$ORACLE_SID
COMMON_DIR="/u01/shared"
# - End of Customization -------------------------------------------------------

# - Default Values -------------------------------------------------------------
# - EOF Default Values ---------------------------------------------------------

# - configure instance ---------------------------------------------------------
echo "INFO: Copy orapw file of ${ORACLE_SID} from common folder:"
echo "INFO:   ORACLE_SID          :   ${ORACLE_SID}"
echo "INFO:   ORACLE_BASE         :   ${ORACLE_BASE}" 
echo "INFO:   ORACLE_HOME         :   ${ORACLE_HOME}"
echo "INFO:   ORACLE_SID_SRC      :   ${ORACLE_SID_SRC}"
echo "INFO:   ORACLE_SID_DST      :   ${ORACLE_SID_DST}"
echo "INFO:   COMMON_DIR          :   ${COMMON_DIR}"

mkdir -pv ${ORACLE_BASE}/admin/${ORACLE_SID}/wallet/backups
mkdir -pv ${ORACLE_BASE}/admin/${ORACLE_SID}/wallet/tde
mkdir -pv ${ORACLE_BASE}/admin/${ORACLE_SID}/wallet/tde_seps

echo "INFO: generate wallet password"
ORACLE_WALLET_PWD=$(pwgen -1 20)
echo "${ORACLE_WALLET_PWD}" > ${ORACLE_BASE}/admin/${ORACLE_SID}/wallet/wallet_pwd.txt

echo "INFO: Create keystore script"
${ORACLE_HOME}/bin/sqlplus -S -L /nolog <<EOFSQL
    connect / as sysdba
    ALTER SYSTEM SET TDE_CONFIGURATION='KEYSTORE_CONFIGURATION=FILE' scope=both;
    ADMINISTER KEY MANAGEMENT CREATE KEYSTORE IDENTIFIED BY "${ORACLE_WALLET_PWD}";
    ADMINISTER KEY MANAGEMENT ADD SECRET '${ORACLE_WALLET_PWD}' FOR CLIENT 'TDE_WALLET' TO LOCAL AUTO_LOGIN KEYSTORE '${ORACLE_BASE}/admin/${ORACLE_SID}/wallet/tde_seps';
    ADMINISTER KEY MANAGEMENT SET KEYSTORE OPEN FORCE KEYSTORE IDENTIFIED BY EXTERNAL STORE;
    ADMINISTER KEY MANAGEMENT CREATE LOCAL AUTO_LOGIN KEYSTORE FROM KEYSTORE '${ORACLE_BASE}/admin/${ORACLE_SID}/wallet/tde' IDENTIFIED BY "${ORACLE_WALLET_PWD}";
    @/u00/app/oracle/local/oradba/sql/ssenc_info.sql
    exit;
EOFSQL

KEY_PWD=$(cat ${COMMON_DIR}/${ORACLE_SID_SRC}_masterkey_pwd.txt)
echo "INFO: Import encryption key from common folder"
${ORACLE_HOME}/bin/sqlplus -S -L /nolog <<EOFSQL
    connect / as sysdba
    ADMINISTER KEY MANAGEMENT IMPORT KEYS WITH SECRET "${KEY_PWD}" FROM '${COMMON_DIR}/${ORACLE_SID_SRC}_masterkey' FORCE KEYSTORE IDENTIFIED BY EXTERNAL STORE WITH BACKUP;
    STARTUP FORCE NOMOUNT;
    @/u00/app/oracle/local/oradba/sql/ssenc_info.sql
    exit;
EOFSQL
# - EOF ------------------------------------------------------------------------
