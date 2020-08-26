#!/bin/bash
# ---------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: 01_setup_os_db.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2019.04.04
# Revision...: 
# Purpose....: Script to configure OEL for Oracle Database installations.
# Notes......: Script would like to be executed as root :-).
# Reference..: --
# License....: Licensed under the Universal Permissive License v 1.0 as 
#              shown at http://oss.oracle.com/licenses/upl.
# ---------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# ---------------------------------------------------------------------------

# - Environment Variables ---------------------------------------------------
# source genric environment variables and functions
source "$(dirname ${BASH_SOURCE[0]})/00_setup_init.sh"
# - EOF Environment Variables -----------------------------------------------

# - Main --------------------------------------------------------------------
# reuse existing wallet password file
WALLET_PWD_FILE="${ORACLE_BASE}/admin/${ORACLE_SID}/etc/${ORACLE_SID}_wallet_password.txt"
if [ -f "${WALLET_PWD_FILE}" ]; then
    echo "    found password file ${WALLET_PWD_FILE}"
    export WALLET_PASSWORD=$(cat ${WALLET_PWD_FILE})
fi

# generate a wallet password
if [ -z ${WALLET_PASSWORD} ]; then
    # Auto generate a password
    while true; do
        s=$(cat /dev/urandom | tr -dc "A-Za-z0-9" | fold -w 10 | head -n 1)
        if [[ ${#s} -ge 8 && "$s" == *[A-Z]* && "$s" == *[a-z]* && "$s" == *[0-9]*  ]]; then
            echo "Passwort does Match the criteria => $s"
            break
        else
            echo "Password does not Match the criteria, re-generating..."
        fi
    done
    echo "---------------------------------------------------------------"
    echo "    Oracle Database Server auto generated "
    echo "    wallet password :"
    echo "    ----> wallet password  : $s"
    echo "---------------------------------------------------------------"
else
    s=${WALLET_PASSWORD}
    echo "---------------------------------------------------------------"
    echo "    Oracle Database Server use pre defined"
    echo "    wallet password :"
    echo "    ----> wallet password  : $s"
    echo "---------------------------------------------------------------"
fi

# update EUS admin password file
echo "$s" > ${WALLET_PWD_FILE}

# - upgrade oracle password file ---------------------------------------
echo " - Upgrade oracle password file:"
echo "      ORACLE_HOME :   ${ORACLE_HOME}"
echo "      ORACLE_SID  :   ${ORACLE_SID}"
mv $ORACLE_HOME/dbs/orapw${ORACLE_SID} $ORACLE_HOME/dbs/orapw${ORACLE_SID}_format12
orapwd format=12.2 input_file=$ORACLE_HOME/dbs/orapw${ORACLE_SID}_format12 file=$ORACLE_HOME/dbs/orapw${ORACLE_SID}
orapwd describe file=$ORACLE_HOME/dbs/orapw${ORACLE_SID}

# - create dsi config file ---------------------------------------------
if [ ! -f "${TNS_ADMIN}/${DSI_FILE}" ]; then
    echo " - Create dsi config file ${DSI_FILE} using:"
    echo "      TNS_ADMIN   :   ${TNS_ADMIN}"
    echo "      DSI_FILE    :   ${DSI_FILE}"
    echo "      KDC_FQDN    :   ${KDC_FQDN}"
    echo "      AD_BASEDN   :   ${AD_BASEDN}"

cat << DSI > ${TNS_ADMIN}/${DSI_FILE}
# --------------------------------------------------------------------------- 
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# --------------------------------------------------------------------------- 
# Name.......: dsi.ora
# Purpose....: Automatic generated dsi.ora config file.
# --------------------------------------------------------------------------- 
DSI_DIRECTORY_SERVERS = (${KDC_FQDN}:389:636)
DSI_DEFAULT_ADMIN_CONTEXT = "${AD_BASEDN}"
DSI_DIRECTORY_SERVER_TYPE = AD
DSI
else
    echo " - dsi config file ${DSI_FILE} already exists"
fi

# - create oracle wallet file ------------------------------------------
mkdir -p $ORACLE_BASE/admin/$ORACLE_SID/wallet
orapki wallet create -wallet $ORACLE_BASE/admin/$ORACLE_SID/wallet \
    -auto_login -pwd $(cat ${WALLET_PWD_FILE})

# - add AD credentials to the wallet ---------------------------------------------
cat ${WALLET_PWD_FILE}| mkstore -wrl $ORACLE_BASE/admin/$ORACLE_SID/wallet -createEntry ORACLE.SECURITY.USERNAME ${AD_USER_NAME}
cat ${WALLET_PWD_FILE}| mkstore -wrl $ORACLE_BASE/admin/$ORACLE_SID/wallet -createEntry ORACLE.SECURITY.DN ${AD_DISTINGUISH_NAME}
cat ${WALLET_PWD_FILE}| mkstore -wrl $ORACLE_BASE/admin/$ORACLE_SID/wallet -createEntry ORACLE.SECURITY.PASSWORD ${AD_PASSWORD}
cat ${WALLET_PWD_FILE}| mkstore -wrl $ORACLE_BASE/admin/$ORACLE_SID/wallet -list
 
# copy the root certificat and load it into the wallet
cp ${CONFIG_AD_ROOT_CERT} ${TNS_ADMIN}/${AD_ROOT_CERT}

orapki wallet add -wallet ${ORACLE_BASE}/admin/${ORACLE_SID}/wallet \
    -cert ${TNS_ADMIN}/${AD_ROOT_CERT} -trusted_cert \
    -pwd $(cat ${WALLET_PWD_FILE})
orapki wallet display -wallet ${ORACLE_BASE}/admin/${ORACLE_SID}/wallet
# --- EOF --------------------------------------------------------------------