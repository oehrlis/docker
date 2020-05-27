#!/bin/bash
# -----------------------------------------------------------------------
# Trivadis AG, Business Development & Support (BDS)
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------
# Name.......: 04_update_directory_manager.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2020.03.02
# Revision...: --
# Purpose....: Adjust cn=Directory Manager to use new password storage scheme
# Notes......: --
# Reference..: https://github.com/oehrlis/oudbase
# License....: GPL-3.0+
# -----------------------------------------------------------------------
# Modified...:
# see git revision history with git log for more information on changes
# -----------------------------------------------------------------------

# - load instance environment -------------------------------------------
. "$(dirname $0)/00_init_environment"

# - configure instance --------------------------------------------------
echo "Configure OUD instance ${OUD_INSTANCE} using:"
echo "  OUD_INSTANCE_HOME : ${OUD_INSTANCE_HOME}"

# generate a temporary password
while true; do
    s=$(cat /dev/urandom | tr -dc "A-Za-z0-9" | fold -w 10 | head -n 1)
    if [[ ${#s} -ge 8 && "$s" == *[A-Z]* && "$s" == *[a-z]* && "$s" == *[0-9]*  ]]; then
        break
    fi
done

# Temporary admin password
ADMIN_PASSWORD=$s

echo "  add uid to Directory Manager"
${OUD_INSTANCE_HOME}/OUD/bin/ldapmodify \
  --hostname ${HOST} \
  --port $PORT_ADMIN --trustAll --useSSL \
  --bindDN "${DIRMAN}" \
  --bindPasswordFile "${PWD_FILE}" <<LDIF
dn: cn=Directory Manager,cn=Root DNs,cn=config
changetype: modify
add: uid
uid: cn=Directory Manager
LDIF

echo "  Reset Password for Directory Manager to generate AES password entry"
# set the Directory Manager password to the temporary password ADMIN_PASSWORD
${OUD_INSTANCE_HOME}/OUD/bin/ldappasswordmodify \
  --hostname ${HOST} \
  --port $PORT_ADMIN --trustAll --useSSL \
  --authzID "${DIRMAN}" \
 --currentPasswordFile $PWD_FILE --newPassword ${ADMIN_PASSWORD}
# set the Directory Manager password back to the original password
${OUD_INSTANCE_HOME}/OUD/bin/ldappasswordmodify \
  --hostname ${HOST} \
  --port $PORT_ADMIN --trustAll --useSSL \
  --authzID "${DIRMAN}" \
 --currentPassword ${ADMIN_PASSWORD} --newPasswordFile $PWD_FILE 

echo "  Review Directory Manager"
${OUD_INSTANCE_HOME}/OUD/bin/ldapsearch \
  --hostname ${HOST} \
  --port $PORT_ADMIN --trustAll --useSSL \
  --bindDN "${DIRMAN}" \
  --bindPasswordFile "${PWD_FILE}" \
  --baseDN "cn=config" "cn=Directory Manager" uid userpassword
# - EOF -----------------------------------------------------------------

