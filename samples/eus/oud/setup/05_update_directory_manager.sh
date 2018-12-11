#!/bin/bash
# -----------------------------------------------------------------------
# Trivadis AG, Business Development & Support (BDS)
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------
# Name.......: 04_update_directory_manager.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2018.03.18
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
${OUD_INSTANCE_HOME}/OUD/bin/ldappasswordmodify \
  --hostname ${HOST} \
  --port $PORT_ADMIN --trustAll --useSSL \
  --authzID "${DIRMAN}" \
 --currentPasswordFile $PWD_FILE --newPasswordFile $PWD_FILE 

echo "  Review Directory Manager"
${OUD_INSTANCE_HOME}/OUD/bin/ldapsearch \
  --hostname ${HOST} \
  --port $PORT_ADMIN --trustAll --useSSL \
  --bindDN "${DIRMAN}" \
  --bindPasswordFile "${PWD_FILE}" \
  --baseDN "cn=config" "cn=Directory Manager" uid userpassword
# - EOF -----------------------------------------------------------------
