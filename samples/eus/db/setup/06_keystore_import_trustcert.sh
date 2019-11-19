#!/bin/bash
# -----------------------------------------------------------------------
# Trivadis AG, Business Development & Support (BDS)
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------
# Name.......: 06_keystore_import_trustcert.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2018.12.07
# Revision...: --
# Purpose....: Script to import the trust certificate into java keystore
# Notes......: --
# Reference..: https://github.com/oehrlis/oudbase
# License....: GPL-3.0+
# -----------------------------------------------------------------------
# Modified...:
# see git revision history with git log for more information on changes
# -----------------------------------------------------------------------

# set default values for keystore if not specified
export KEYSTOREFILE=${KEYSTOREFILE:-"$ORACLE_BASE/network/admin/keystore.jks"} 
export KEYSTOREPIN=${KEYSTOREPIN:-"$ORACLE_BASE/network/admin/keystore.pin"}
export KEYSTORE_ALIAS=${KEYSTORE_ALIAS:-"oud_root_certificate"}
export TRUSTED_CERT_FILE=${TRUSTED_CERT_FILE:-"/u01/oud/oud_trusted_cert.txt"}

if [ -f "$KEYSTOREPIN" ]; then
    echo "  found keystore pin file $KEYSTOREPIN"
else
    echo "  generate password for keystore pin file $KEYSTOREPIN"
    # Auto generate a password
    while true; do
        s=$(cat /dev/urandom | tr -dc "A-Za-z0-9" | fold -w 20 | head -n 1)
        if [[ ${#s} -ge 8 && "$s" == *[A-Z]* && "$s" == *[a-z]* && "$s" == *[0-9]*  ]]; then
            echo "  Passwort does Match the criteria => $s"
            break
        else
            echo "  Password does not Match the criteria, re-generating..."
        fi
    done
    echo "$s" > ${KEYSTOREPIN}
fi

# - configure instance --------------------------------------------------
echo "Import the trusted certificate from OUD instance keystore using:"
echo "  KEYSTOREFILE      : ${KEYSTOREFILE}"
echo "  KEYSTOREPIN       : ${KEYSTOREPIN}"
echo "  KEYSTORE_ALIAS    : ${KEYSTORE_ALIAS}"

echo "  import trusted certificate"
$ORACLE_HOME/jdk/bin/keytool -import \
    -trustcacerts -noprompt \
    -alias ${KEYSTORE_ALIAS} \
    -storetype pkcs12 \
    -keystore ${KEYSTOREFILE} \
    -storepass $(cat ${KEYSTOREPIN}) \
    -file ${TRUSTED_CERT_FILE}

# - EOF -----------------------------------------------------------------
