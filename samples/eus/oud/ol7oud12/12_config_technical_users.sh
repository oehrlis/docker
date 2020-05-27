#!/bin/bash
# -----------------------------------------------------------------------
# Trivadis AG, Business Development & Support (BDS)
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------
# Name.......: 08_config_technical_users.sh.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2020.03.02
# Revision...: --
# Purpose....: Script to configure technical users and groups.
# Notes......: BaseDN in 08_config_technical_users.ldif will be updated before
#              it is loaded using ldapmodify.
# Reference..: https://github.com/oehrlis/oudbase
# License....: GPL-3.0+
# -----------------------------------------------------------------------
# Modified...:
# see git revision history with git log for more information on changes
# -----------------------------------------------------------------------

# - load instance environment -------------------------------------------
. "$(dirname $0)/00_init_environment"
LDIFFILE="$(dirname $0)/$(basename $0 .sh).ldif"      # LDIF file based on script name
CONFIGFILE="$(dirname $0)/$(basename $0 .sh).conf"    # config file based on script name

# - configure instance --------------------------------------------------
echo "Configure OUD instance ${OUD_INSTANCE} using:"
echo "OUD_INSTANCE_HOME : ${OUD_INSTANCE_HOME}"
echo "PWD_FILE          : ${PWD_FILE}"
echo "HOSTNAME          : ${HOST}"
echo "PORT              : ${PORT}"
echo "PORT_ADMIN        : ${PORT_ADMIN}"
echo "DIRMAN            : ${DIRMAN}"
echo "LDIFFILE          : ${LDIFFILE}"
echo "CONFIGFILE        : ${CONFIGFILE}"

# - configure instance --------------------------------------------------
# Update baseDN in LDIF file if required
if [[ "$BASEDN" != "dc=example,dc=com" ]]; then
  echo "  Different base DN than default ."
  echo "  Update LDIF files to match $BASEDN" 
  sed -i "s/ou=groups,dc=example,dc=com/$GROUP_OU/" ${LDIFFILE}
  sed -i "s/ou=people,dc=example,dc=com/$USER_OU/" ${LDIFFILE}
  sed -i "s/dc=example,dc=com/$BASEDN/" ${LDIFFILE}
fi

echo "Add technical user"
${OUD_INSTANCE_HOME}/OUD/bin/ldapmodify \
  --hostname ${HOST} \
  --port ${PORT} \
  --bindDN "${DIRMAN}" \
  --bindPasswordFile "${PWD_FILE}" \
  --defaultAdd \
  --filename "${LDIFFILE}"

echo "Config OUD Instance for technical user"
${OUD_INSTANCE_HOME}/OUD/bin/dsconfig \
  --hostname ${HOST} \
  --port ${PORT_ADMIN} \
  --bindDN "${DIRMAN}" \
  --bindPasswordFile "${PWD_FILE}" \
  --no-prompt \
  --verbose \
  --trustAll \
  --batchFilePath "${CONFIGFILE}"
# - EOF -----------------------------------------------------------------
