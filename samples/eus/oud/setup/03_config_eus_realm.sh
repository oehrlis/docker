#!/bin/bash
# -----------------------------------------------------------------------
# Trivadis AG, Business Development & Support (BDS)
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------
# Name.......: 04_config_oud_ad_proxy.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2018.06.27
# Revision...: --
# Purpose....: Script to configure EUS realm to the OUD proxy instance.
# Notes......: BaseDN in 03_config_eus_realm.ldif will be updated before
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

# - configure instance --------------------------------------------------
echo "Configure OUD proxy instance ${OUD_INSTANCE} using:"
echo "  BASEDN            : ${BASEDN}"
echo "  LDIFFILE          : ${LDIFFILE}"

# - configure instance --------------------------------------------------
# Update baseDN in LDIF file if required
if [[ "$BASEDN" != "dc=example,dc=com" ]]; then
  echo "  Different base DN than default ."
  echo "  Update LDIF files to match $BASEDN" 
  sed -i "s/ou=groups,dc=example,dc=com/$GROUP_OU/" ${LDIFFILE}
  sed -i "s/ou=people,dc=example,dc=com/$USER_OU/" ${LDIFFILE}
  sed -i "s/dc=example,dc=com/$BASEDN/" ${LDIFFILE}
fi

echo "  Update EUS Realm configuration"
${OUD_INSTANCE_HOME}/OUD/bin/ldapmodify \
  --hostname ${HOST} \
  --port ${PORT} \
  --bindDN "${DIRMAN}" \
  --bindPasswordFile "${PWD_FILE}" \
  --defaultAdd \
  --filename "${LDIFFILE}"
# - EOF -----------------------------------------------------------------
