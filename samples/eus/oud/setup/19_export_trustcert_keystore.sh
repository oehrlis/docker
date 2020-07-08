#!/bin/bash
# -----------------------------------------------------------------------
# Trivadis AG, Business Development & Support (BDS)
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------
# Name.......: 10_export_trustcert_keystore.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2020.07.01
# Revision...: --
# Purpose....: Script to export the java keystore to PKCS12
# Notes......: --
# Reference..: https://github.com/oehrlis/oudbase
# License....: Licensed under the Universal Permissive License v 1.0 as 
#              shown at https://oss.oracle.com/licenses/upl.
# -----------------------------------------------------------------------
# Modified...:
# see git revision history with git log for more information on changes
# -----------------------------------------------------------------------

# - load instance environment -------------------------------------------
. "$(dirname $0)/00_init_environment"

# set default values for keystore if not specified
export KEYSTOREFILE=${KEYSTOREFILE:-"${OUD_INSTANCE_HOME}/OUD/config/keystore"} 
export KEYSTOREPIN=${KEYSTOREPIN:-"${OUD_INSTANCE_HOME}/OUD/config/keystore.pin"}
export KEYSTORE_ALIAS=${KEYSTORE_ALIAS:-"server-cert"}
export TRUSTED_CERT_FILE=${TRUSTED_CERT_FILE:-"${OUD_INSTANCE_ADMIN}/etc/oud_trusted_cert.txt"}

# - configure instance --------------------------------------------------
echo "Export the trusted certificate from OUD instance ${OUD_INSTANCE} keystore using:"
echo "  KEYSTOREFILE        : ${KEYSTOREFILE}"
echo "  KEYSTOREPIN         : ${KEYSTOREPIN}"
echo "  KEYSTORE_ALIAS      : ${KEYSTORE_ALIAS}"
echo "  TRUSTED_CERT_FILE   : ${TRUSTED_CERT_FILE}"

echo "- export trusted certificate"
$JAVA_HOME/bin/keytool -export -noprompt -rfc \
    -alias ${KEYSTORE_ALIAS} \
    -keystore ${KEYSTOREFILE} \
    -storepass $(cat ${KEYSTOREPIN}) \
    -file ${TRUSTED_CERT_FILE}
# - EOF -----------------------------------------------------------------
