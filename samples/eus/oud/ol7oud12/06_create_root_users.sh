#!/bin/bash
# -----------------------------------------------------------------------
# Trivadis AG, Business Development & Support (BDS)
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------
# Name.......: 05_create_root_users.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2018.06.27
# Revision...: --
# Purpose....: Script to create additional root user.
# Notes......: The users are created by loading 05_create_root_users.ldif.
# Reference..: https://github.com/oehrlis/oudbase
# License....: Apache License Version 2.0, January 2004 as shown
#              at http://www.apache.org/licenses/
# -----------------------------------------------------------------------
# Modified...:
# see git revision history with git log for more information on changes
# -----------------------------------------------------------------------

# - load instance environment -------------------------------------------
. "$(dirname $0)/00_init_environment"
LDIFFILE="$(dirname $0)/$(basename $0 .sh).ldif"      # LDIF file based on script name
CONFIGFILE="$(dirname $0)/$(basename $0 .sh).conf"      # config file based on script name

# - configure instance --------------------------------------------------
echo "Create root user for OUD proxy instance ${OUD_INSTANCE} using:"
echo "  BASEDN            : ${BASEDN}"
echo "  LDIFFILE          : ${LDIFFILE}"
echo "  CONFIGFILE        : ${CONFIGFILE}"

# Update baseDN in LDIF file if required
if [[ "$BASEDN" != "dc=example,dc=com" ]]; then
  echo "  Different base DN than default dc=example,dc=com."
  echo "  Update LDIF files to match $BASEDN" 
  sed -i "s/dc=example,dc=com/$BASEDN/" ${LDIFFILE}
fi

# Update baseDN in LDIF file if required
if [[ "$BASEDN" != "dc=example,dc=com" ]]; then
  echo "  Different base DN than default dc=example,dc=com."
  echo "  Update LDIF files to match $BASEDN" 
  sed -i "s/dc=example,dc=com/$BASEDN/" ${CONFIGFILE}
fi

# reuse existing password file
ROOT_USERS_PWD_FILE=${OUD_INSTANCE_ADMIN}/etc/${OUD_INSTANCE}_root_users_pwd.txt
if [ -f "$ROOT_USERS_PWD_FILE" ]; then
    echo "    found password file $ROOT_USERS_PWD_FILE"
    export ADMIN_PASSWORD=$(cat $ROOT_USERS_PWD_FILE)
fi
# generate a password
if [ -z ${ADMIN_PASSWORD} ]; then
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
    echo "    Oracle Unified Directory Server auto generated instance"
    echo "    password additional root users:"
    echo "    ----> Admin password  : $s"
    echo "---------------------------------------------------------------"
else
    s=${ADMIN_PASSWORD}
    echo "---------------------------------------------------------------"
    echo "    Oracle Unified Directory Server use pre defined instance"
    echo "    password additional root users:"
    echo "    ----> Directory Admin : ${ADMIN_USER} "
    echo "    ----> Admin password  : $s"
    echo "---------------------------------------------------------------"
fi

# update EUS admin password file
echo "$s" > ${ROOT_USERS_PWD_FILE}
sed -i "s/PASSWORD/$s/" ${LDIFFILE}

echo "  Create for root users"
${OUD_INSTANCE_HOME}/OUD/bin/ldapmodify \
  --hostname ${HOST} \
  --port ${PORT_ADMIN} \
  --bindDN "${DIRMAN}" \
  --bindPasswordFile "${PWD_FILE}" \
  --useSSL \
  --trustAll \
  --defaultAdd \
  --filename "${LDIFFILE}"

echo "  Review root users"
${OUD_INSTANCE_HOME}/OUD/bin/ldapsearch \
  --hostname ${HOST} \
  --port $PORT_ADMIN --trustAll --useSSL \
  --bindDN "${DIRMAN}" \
  --bindPasswordFile "${PWD_FILE}" \
  --baseDN "cn=Root DNs,cn=config" "(objectClass=*)" uid userpassword

echo "  Config root users"
${OUD_INSTANCE_HOME}/OUD/bin/dsconfig \
  --hostname ${HOST} \
  --port ${PORT_ADMIN} \
  --bindDN "${DIRMAN}" \
  --bindPasswordFile "${PWD_FILE}" \
  --no-prompt \
  --verbose \
  --verbose \
  --trustAll \
  --batchFilePath "${CONFIGFILE}"
# - EOF -----------------------------------------------------------------
