#!/bin/bash
# -----------------------------------------------------------------------
# Trivadis AG, Business Development & Support (BDS)
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------
# Name.......: 15_reset_user_passwords.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2020.06.30
# Usage......: 15_reset_user_passwords.sh
# Purpose....: Script to reset admin user passwords
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

# Get the root users
echo "- get user from directory -----------------------------------------------"
mapfile -t COMMON_USERS < <(${OUD_INSTANCE_HOME}/OUD/bin/ldapsearch --hostname ${HOST} --port $PORT -D "${DIRMAN}"  -j ${PWD_FILE} -b "${BASEDN}" "(objectClass=person)" dn|sed 's/^dn: //'|grep -i 'cn')
DEFAULT_USERS_PWD_FILE=${DEFAULT_USERS_PWD_FILE:-"${OUD_INSTANCE_ADMIN}/etc/${OUD_INSTANCE}_default_user_pwd.txt"}

# - configure instance ------------------------------------------------------
echo "- reset admin user password for OUD instance ${OUD_INSTANCE} using:"
echo "HOSTNAME          : ${HOST}"
echo "PORT_ADMIN        : ${PORT}"
echo "DIRMAN            : ${DIRMAN}"
echo "PWD_FILE          : ${PWD_FILE}"
echo "DEFAULT_PASSWORD  : ${DEFAULT_PASSWORD}"

# generate a password
if [ -z ${DEFAULT_PASSWORD} ]; then
  if [ -f "${DEFAULT_USERS_PWD_FILE}" ]; then
    echo "- user password from default user password file (${DEFAULT_USERS_PWD_FILE})..."
    DEFAULT_PASSWORD=$(cat ${DEFAULT_USERS_PWD_FILE})
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
    echo "- use auto generated password (${DEFAULT_PASSWORD}) for users"
    DEFAULT_PASSWORD=$s
    echo "- save generated password for users to ${DEFAULT_USERS_PWD_FILE}"
    echo ${DEFAULT_PASSWORD}>$DEFAULT_USERS_PWD_FILE
  fi
else
  echo "- use predefined password (\${DEFAULT_PASSWORD}=${DEFAULT_PASSWORD}) for users"
  echo ${DEFAULT_PASSWORD}>$DEFAULT_USERS_PWD_FILE
fi

for user in "${COMMON_USERS[@]}"; do
  echo -n "- reset Password for ${user} "
  ${OUD_INSTANCE_HOME}/OUD/bin/ldappasswordmodify \
    --hostname ${HOST} \
    --port $PORT_ADMIN --trustAll --useSSL \
    -D "${DIRMAN}" -j $PWD_FILE \
    --authzID "${user}" --newPassword ${DEFAULT_PASSWORD} 2>&1 >/dev/null
  if [ $? -eq 0 ]; then
    echo "OK"
  else
    echo "NOK"
  fi
done
# - EOF ---------------------------------------------------------------------
