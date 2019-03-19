#!/bin/bash
# -----------------------------------------------------------------------
# Trivadis AG, Business Development & Support (BDS)
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------
# Name.......: 03_eus_registration.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2018.06.27
# Revision...: --
# Purpose....: Script to configure the EUS for Database.
# Notes......: --
# Reference..: https://github.com/oehrlis/oudbase
# License....: GPL-3.0+
# -----------------------------------------------------------------------
# Modified...:
# see git revision history with git log for more information on changes
# -----------------------------------------------------------------------

export BASEDN=${BASEDN:-"dc=trivadislabs,dc=com"}
#export OUD_HOST=${OUD_HOST:-"oud.trivadislabs.com"}
export OUD_HOST=${OUD_HOST:-"oud"}
export ORACLE_SID=${ORACLE_SID:-"TEUS01"}
export EUS_ADMIN=${EUS_ADMIN:-"cn=eusadmin,cn=oraclecontext"}
export SYS_PWD_FILE=${SYS_PWD_FILE:-"${ORACLE_BASE}/admin/${ORACLE_SID}/etc/${ORACLE_SID}_password.txt"}
export WALLET_PWD_FILE=${WALLET_PWD_FILE:-"${ORACLE_BASE}/admin/${ORACLE_SID}/etc/${ORACLE_SID}_password.txt"}
export EUS_PWD_FILE=${EUS_PWD_FILE:-"/u01/oud/oud_eus_eusadmin_pwd.txt"}

# - configure SQLNet ----------------------------------------------------
echo "Configure SQLNet ldap.ora:"
echo "  BASEDN              :   ${BASEDN}"
echo "  OUD_HOST            :   ${OUD_HOST}"

echo "DIRECTORY_SERVERS=(${OUD_HOST}:1389:1636)"    > ${ORACLE_BASE}/network/admin/ldap.ora
echo "DEFAULT_ADMIN_CONTEXT = \"${BASEDN}\""        >>${ORACLE_BASE}/network/admin/ldap.ora    
echo "DIRECTORY_SERVER_TYPE = OID"                  >>${ORACLE_BASE}/network/admin/ldap.ora

# - configure instance --------------------------------------------------
echo "Register Database ${ORACLE_SID} in OUD using:"
echo "  ORACLE_SID          :   ${ORACLE_SID}"
echo "  EUS_ADMIN           :   ${EUS_ADMIN}"
echo "  SYS_PWD_FILE        :   ${SYS_PWD_FILE}"
echo "  WALLET_PWD_FILE     :   ${WALLET_PWD_FILE}"
echo "  EUS_PWD_FILE        :   ${EUS_PWD_FILE}"
$ORACLE_HOME/bin/dbca -silent -configureDatabase \
-sourceDB ${ORACLE_SID} -sysDBAUserName sys -sysDBAPassword $(cat ${SYS_PWD_FILE}) \
-registerWithDirService true -dirServiceUserName ${EUS_ADMIN} \
-dirServicePassword $(cat ${EUS_PWD_FILE}) -walletPassword $(cat ${WALLET_PWD_FILE}) 

# - unlock system -------------------------------------------------------
$ORACLE_HOME/bin/sqlplus -S -L /NOLOG <<EOFSQL
CONNECT / AS SYSDBA
ALTER USER system IDENTIFIED BY $(cat ${SYS_PWD_FILE}) ACCOUNT UNLOCK;
EOFSQL
# - EOF -----------------------------------------------------------------