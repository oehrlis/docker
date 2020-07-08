#!/bin/bash
# -----------------------------------------------------------------------
# Trivadis AG, Business Development & Support (BDS)
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------
# Name.......: 18_reset_eusadmin_password.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2020.06.30
# Usage......: 18_reset_eusadmin_password.sh
# Purpose....: Script to reset eusadmin user password
# Notes......: 
# Reference..: 
# License...: Licensed under the Universal Permissive License v 1.0 as 
#             shown at http://oss.oracle.com/licenses/upl.
# -----------------------------------------------------------------------
# Modified...:
# see git revision history with git log for more information on changes
# -----------------------------------------------------------------------

# - load instance environment -----------------------------------------------
. "$(dirname $0)/00_init_environment"
export EUSADMIN_USERS_PWD_FILE=${EUSADMIN_USERS_PWD_FILE:-"${INSTANCE_INIT}/etc/${EUS_USER_NAME}_pwd.txt"}
export EUSADMIN_USERS_DN_FILE=${EUSADMIN_USERS_DN_FILE:-"${INSTANCE_INIT}/etc/${EUS_USER_NAME}_dn.txt"}

# - configure instance --------------------------------------------------
echo "Reset eusadmin user password for OUD instance ${OUD_INSTANCE} using:"
echo "  BASEDN                  : ${BASEDN}"
echo "  EUS_USER_NAME           : ${EUS_USER_NAME}"
echo "  EUS_USER_DN             : ${EUS_USER_DN}"
echo "  EUSADMIN_USERS_PWD_FILE : ${EUSADMIN_USERS_PWD_FILE}"
echo "  EUSADMIN_USERS_DN_FILE  : ${EUSADMIN_USERS_DN_FILE}"

# reuse existing password file
if [ -f "$EUSADMIN_USERS_PWD_FILE" ]; then
    echo "    found password file $EUSADMIN_USERS_PWD_FILE"
    export ADMIN_PASSWORD=$(cat $EUSADMIN_USERS_PWD_FILE)
fi

# reuse existing password file
if [ -f "$EUSADMIN_USERS_PWD_FILE" ]; then
    echo "- found eus admin password file ${EUSADMIN_USERS_PWD_FILE}"
    export ADMIN_PASSWORD=$(cat ${EUSADMIN_USERS_PWD_FILE})
# use default password from variable
elif [ -n "${DEFAULT_PASSWORD}" ]; then
    echo "- use default user password from \${DEFAULT_PASSWORD} for user ${EUS_USER_NAME}"
    echo ${DEFAULT_PASSWORD}> ${EUSADMIN_USERS_PWD_FILE}
    export ADMIN_PASSWORD=$(cat $EUSADMIN_USERS_PWD_FILE)
# still here, then lets create a password
else 
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
    echo "- use auto generated password for user ${EUS_USER_NAME}"
    ADMIN_PASSWORD=$s
    echo "- save password for ${EUS_USER_NAME} in ${EUSADMIN_USERS_PWD_FILE}"
    echo ${ADMIN_PASSWORD}>$EUSADMIN_USERS_PWD_FILE
fi

echo -n "- reset Password for $(cat ${EUSADMIN_USERS_DN_FILE}) "
${OUD_INSTANCE_HOME}/OUD/bin/ldappasswordmodify \
  --hostname ${HOST} \
  --port $PORT_ADMIN --trustAll --useSSL \
  -D "${DIRMAN}" -j $PWD_FILE \
  --authzID "$(cat ${EUSADMIN_USERS_DN_FILE})" --newPassword ${ADMIN_PASSWORD} 2>&1 >/dev/null
if [ $? -eq 0 ]; then
  echo "OK"
else
  echo "NOK"
fi
# - EOF ---------------------------------------------------------------------
