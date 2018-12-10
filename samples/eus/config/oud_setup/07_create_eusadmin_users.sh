#!/bin/bash
# -----------------------------------------------------------------------
# Trivadis AG, Business Development & Support (BDS)
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------
# Name.......: 07_create_eusadmin_users.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2018.12.07
# Revision...: --
# Purpose....: Script to create EUS Context Admin according to MOS Note 1996363.1.
# Notes......: --
# Reference..: https://github.com/oehrlis/oudbase
# License....: GPL-3.0+
# -----------------------------------------------------------------------
# Modified...:
# see git revision history with git log for more information on changes
# -----------------------------------------------------------------------

# - load instance environment -------------------------------------------
. "$(dirname $0)/00_init_environment"
export EUS_USER="cn=eusadmin,cn=oraclecontext"
# - configure instance --------------------------------------------------
echo "Create EUS Admin user for OUD instance ${OUD_INSTANCE} using:"
echo "  BASEDN            : ${BASEDN}"
echo "  USER              : ${EUS_USER}"

# reuse existing password file
EUSADMIN_USERS_PWD_FILE=/u01/config/${OUD_INSTANCE}_eusadmin_pwd.txt
if [ -f "$EUSADMIN_USERS_PWD_FILE" ]; then
    echo "    found password file $EUSADMIN_USERS_PWD_FILE"
    export ADMIN_PASSWORD=$(cat $EUSADMIN_USERS_PWD_FILE)
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
    echo "    password additional EUS user:"
    echo "    ----> Admin password  : $s"
    echo "---------------------------------------------------------------"
else
    s=${ADMIN_PASSWORD}
    echo "---------------------------------------------------------------"
    echo "    Oracle Unified Directory Server use pre defined instance"
    echo "    password additional EUS user:"
    echo "    ----> Directory Admin : ${EUS_USER} "
    echo "    ----> Admin password  : $s"
    echo "---------------------------------------------------------------"
fi

# update EUS admin password file
echo "$s" > ${EUSADMIN_USERS_PWD_FILE}

# create EUS Admin User
echo "  create EUS admin user ${EUS_USER}"
${OUD_INSTANCE_HOME}/OUD/bin/ldapmodify \
  --hostname ${HOST} \
  --port $PORT \
  --bindDN "${DIRMAN}" \
  --bindPasswordFile "${PWD_FILE}" <<LDIF
dn: ${EUS_USER}
changetype: add
objectclass: inetorgperson
cn: eusadmin
sn: eusadmin
uid: eusadmin
userpassword: $s
ds-privilege-name: password-reset
ds-pwp-password-policy-dn: cn=EUS Password Policy,cn=Password Policies,cn=config
LDIF

# Reset EUS Admin User password to make sure it has a AES passwort entry
echo "  Reset Password for cn=eusadmin to generate AES password entry"
${OUD_INSTANCE_HOME}/OUD/bin/ldappasswordmodify \
  --hostname ${HOST} \
  --port $PORT_ADMIN --trustAll --useSSL \
  --authzID "${EUS_USER}" \
 --currentPasswordFile $EUSADMIN_USERS_PWD_FILE --newPasswordFile $EUSADMIN_USERS_PWD_FILE 

echo "  update EUS Context Privileges"
${OUD_INSTANCE_HOME}/OUD/bin/ldapmodify \
  --hostname ${HOST} \
  --port $PORT \
  --bindDN "${DIRMAN}" \
  --bindPasswordFile "${PWD_FILE}" <<LDIF
dn: cn=OracleContextAdmins,cn=groups,cn=OracleContext,${BASEDN}
changetype: modify
add: uniquemember
uniquemember: ${EUS_USER}
LDIF

echo "  Config EUS users"
${OUD_INSTANCE_HOME}/OUD/bin/dsconfig set-access-control-handler-prop \
    --add global-aci:\(targetattr=\"*\"\)\ \(version\ 3.0\;\ acl\ \"Allow\ OracleContextAdmins\"\;\ allow\ \(all\)\ groupdn=\"ldap:///cn=OracleContextAdmins,cn=Groups,cn=OracleContext,dc=trivadislabs,dc=com\"\;\) \
    --hostname ${HOST} \
    --port ${PORT_ADMIN} \
    --bindDN "${DIRMAN}" \
    --bindPasswordFile "${PWD_FILE}" \
    --no-prompt \
    --verbose \
    --trustAll

${OUD_INSTANCE_HOME}/OUD/bin/dsconfig set-access-control-handler-prop \
    --add global-aci:\(targetcontrol=\"1.2.840.113556.1.4.805\"\)\ \(version\ 3.0\;\ acl\ \"EUS\ Administrator\ SubTree\ delete\ control\ access\"\;\ allow\(read\)\ groupdn=\"ldap:///cn=OracleContextAdmins,cn=Groups,cn=OracleContext,dc=trivadislabs,dc=com\"\;\) \
    --hostname ${HOST} \
    --port ${PORT_ADMIN} \
    --bindDN "${DIRMAN}" \
    --bindPasswordFile "${PWD_FILE}" \
    --no-prompt \
    --verbose \
    --trustAll

# - EOF -----------------------------------------------------------------
