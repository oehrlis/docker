#!/bin/bash
# -----------------------------------------------------------------------
# Trivadis AG, Business Development & Support (BDS)
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------
# Name.......: 01_create_eus_instance.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2020.06.30
# Revision...: --
# Purpose....: Script to create the OUD instance with EUS context 
#              using oud-setup.
# Notes......: Will skip oud-proxy-setup if config.ldif already exists
# Reference..: https://github.com/oehrlis/oudbase
# License....: Licensed under the Universal Permissive License v 1.0 as 
#              shown at https://oss.oracle.com/licenses/upl.
# -----------------------------------------------------------------------
# Modified...:
# see git revision history with git log for more information on changes
# -----------------------------------------------------------------------

# - load instance environment -------------------------------------------
. "$(dirname $0)/00_init_environment"

# - create instance -----------------------------------------------------
echo "Create OUD instance ${OUD_INSTANCE} using:"
echo "OUD_INSTANCE_HOME : ${OUD_INSTANCE_HOME}"
echo "PWD_FILE          : ${PWD_FILE}"
echo "HOSTNAME          : ${HOST}"
echo "PORT              : ${PORT}"
echo "PORT_SSL          : ${PORT_SSL}"
echo "PORT_ADMIN        : ${PORT_ADMIN}"
echo "PORT_REST_ADMIN   : ${PORT_REST_ADMIN}"
echo "PORT_REST_HTTP    : ${PORT_REST_HTTP}"
echo "PORT_REST_HTTPS   : ${PORT_REST_HTTPS}"
echo "DIRMAN            : ${DIRMAN}"
echo "BASEDN            : ${BASEDN}"

# check if we do have a password file
if [ ! -f "${PWD_FILE}" ]; then
    # check if we do have a default admin password
    if [ -z ${DEFAULT_ADMIN_PASSWORD} ]; then
        # Auto generate a password
        echo "- auto generate new password..."
        while true; do
            s=$(cat /dev/urandom | tr -dc "A-Za-z0-9" | fold -w 10 | head -n 1)
            if [[ ${#s} -ge 8 && "$s" == *[A-Z]* && "$s" == *[a-z]* && "$s" == *[0-9]*  ]]; then
                echo "- passwort does Match the criteria"
                break
            else
                echo "- password does not Match the criteria, re-generating..."
            fi
        done
        echo "- use auto generated password for ${DIRMAN}"
        echo "- save password for ${DIRMAN} in ${PWD_FILE}"
        echo $s>${PWD_FILE}
    else
        echo ${DEFAULT_ADMIN_PASSWORD}>${PWD_FILE}
        echo "- use predefined admin password for user from variable \${DEFAULT_ADMIN_PASSWORD}"
    fi
else
    echo "- use predefined password for user from file ${PWD_FILE}"
fi

# check if OUD instance config does not yet exists
if [ ! -f "${OUD_INSTANCE_HOME}/OUD/config/config.ldif" ]; then
    echo "INFO: Create OUD instance ${OUD_INSTANCE}"
    ${ORACLE_HOME}/oud/oud-setup \
        --cli \
        --instancePath "${OUD_INSTANCE_HOME}/OUD" \
        --rootUserDN "${DIRMAN}" \
        --rootUserPasswordFile "${PWD_FILE}" \
        --adminConnectorPort ${PORT_ADMIN} \
        --httpAdminConnectorPort ${PORT_REST_ADMIN} \
        --hostname ${HOST} \
        --ldapPort ${PORT} \
        --ldapsPort ${PORT_SSL} \
        --httpPort ${PORT_REST_HTTP} \
        --httpsPort ${PORT_REST_HTTPS} \
        --generateSelfSignedCertificate \
        --enableStartTLS \
        --baseDN "${BASEDN}" \
        --integration EUS \
        --serverTuning jvm-default \
        --offlineToolsTuning autotune \
        --no-prompt
else
    echo "WARN: did found an instance configuration file"
    echo "      ${OUD_INSTANCE_HOME}/OUD/config/config.ldif"
    echo "      skip create instance ${OUD_INSTANCE}"
fi

# - EOF -----------------------------------------------------------------