#!/bin/bash
# -----------------------------------------------------------------------
# Trivadis AG, Business Development & Support (BDS)
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------
# Name.......: 18_migrate_keystore.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2020.07.01
# Revision...: --
# Purpose....: Script to migrate the java keystore to PKCS12
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

# - configure instance --------------------------------------------------
echo "Migrate java keystore for OUD instance ${OUD_INSTANCE} using:"
echo "  KEYSTOREFILE      : ${KEYSTOREFILE}"
echo "  KEYSTOREPIN       : ${KEYSTOREPIN}"

echo "- migrate keystore to PKCS12"
$JAVA_HOME/bin/keytool -importkeystore \
    -srckeystore ${KEYSTOREFILE} \
    -srcstorepass $(cat ${KEYSTOREPIN}) \
    -destkeystore ${KEYSTOREFILE} \
    -deststorepass $(cat ${KEYSTOREPIN}) \
    -deststoretype pkcs12

# - EOF -----------------------------------------------------------------
