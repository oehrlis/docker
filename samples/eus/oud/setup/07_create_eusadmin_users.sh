#!/bin/bash
# -----------------------------------------------------------------------
# Trivadis AG, Business Development & Support (BDS)
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------
# Name.......: 07_create_eusadmin_users.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2020.07.01
# Revision...: --
# Purpose....: Script to create EUS Context Admin according to MOS Note 1996363.1.
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
export EUSADMIN_USERS_PWD_FILE=${EUSADMIN_USERS_PWD_FILE:-"${INSTANCE_INIT}/etc/${EUS_USER_NAME}_pwd.txt"}
export EUS_USER_NAME=${EUS_USER_NAME:-"eusadmin"}
export EUS_USER_DN=${EUS_USER_DN:-"cn=${EUS_USER_NAME},cn=oraclecontext"}

# - configure instance --------------------------------------------------
echo "Create EUS Admin user for OUD instance ${OUD_INSTANCE} using:"
echo "  BASEDN                  : ${BASEDN}"
echo "  EUS_USER_NAME           : ${EUS_USER_NAME}"
echo "  EUS_USER_DN             : ${EUS_USER_DN}"
echo "  EUSADMIN_USERS_PWD_FILE : ${EUSADMIN_USERS_PWD_FILE}"

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

# create EUS Admin User
echo "- create EUS admin user ${EUS_USER_DN}"
${OUD_INSTANCE_HOME}/OUD/bin/ldapmodify \
  --hostname ${HOST} \
  --port $PORT \
  --bindDN "${DIRMAN}" \
  --bindPasswordFile "${PWD_FILE}" <<LDIF
dn: ${EUS_USER_DN}
changetype: add
objectclass: inetorgperson
cn: ${EUS_USER_NAME}
sn: ${EUS_USER_NAME}
uid: ${EUS_USER_NAME}
ds-privilege-name: password-reset
ds-pwp-password-policy-dn: cn=EUS Password Policy,cn=Password Policies,cn=config
userpassword: ${ADMIN_PASSWORD}

DN: cn=OracleDBSecurityAdmins,cn=OracleContext
changetype: modify
add: uniquemember
uniquemember: ${EUS_USER_DN}

dn: cn=OracleContextAdmins,cn=groups,cn=OracleContext,${BASEDN}
changetype: modify
add: uniquemember
uniquemember: ${EUS_USER_DN}
LDIF

# check if we do have role_eus_admins
ROLE_DN=$(ldapsearch -h ${HOST} -p ${PORT} -D "${DIRMAN}" -j ${PWD_FILE} -b ${BASEDN} -s sub "(ou=role_eus_admins)" dn 2>/dev/null)
if [ -n "$ROLE_DN" ]; then 
    echo "- add EUS admin user ${EUS_USER_DN} to ${ROLE_DN}"
    ${OUD_INSTANCE_HOME}/OUD/bin/ldapmodify \
        --hostname ${HOST} \
        --port $PORT \
        --bindDN "${DIRMAN}" \
        --bindPasswordFile "${PWD_FILE}" <<LDIF
dn: ou=role_eus_admins,ou=groups,ou=local,${BASEDN}
changetype: modify
add: uniquemember
uniquemember: ${EUS_USER_DN}
LDIF
fi

# Reset EUS Admin User password to make sure it has a AES passwort entry
echo "- Reset Password for ${EUS_USER_DN} to generate AES password entry"
${OUD_INSTANCE_HOME}/OUD/bin/ldappasswordmodify \
    --hostname ${HOST} \
    -D "${DIRMAN}" -j $PWD_FILE \
    --port $PORT_ADMIN --trustAll --useSSL \
    --authzID "${EUS_USER_DN}" \
    --newPasswordFile $EUSADMIN_USERS_PWD_FILE 

# check if we do have an AES hash
echo "- review password attribute for ${EUS_USER_DN}"
${OUD_INSTANCE_HOME}/OUD/bin/ldapsearch \
  --hostname ${HOST} \
  --port $PORT \
  --bindDN "${DIRMAN}" \
  --bindPasswordFile "${PWD_FILE}" \
  --baseDN "cn=OracleContext" "(cn=${EUS_USER_NAME})" uid userpassword

echo "- Config ACI for Context Admin"
${OUD_INSTANCE_HOME}/OUD/bin/dsconfig set-access-control-handler-prop \
    --add global-aci:\(targetattr=\"*\"\)\ \(version\ 3.0\;\ acl\ \"Allow\ OracleContextAdmins\"\;\ allow\ \(all\)\ groupdn=\"ldap:///cn=OracleContextAdmins,cn=Groups,cn=OracleContext,${BASEDN}\"\;\) \
    --hostname ${HOST} \
    --port ${PORT_ADMIN} \
    --bindDN "${DIRMAN}" \
    --bindPasswordFile "${PWD_FILE}" \
    --no-prompt \
    --verbose \
    --trustAll

${OUD_INSTANCE_HOME}/OUD/bin/dsconfig set-access-control-handler-prop \
    --add global-aci:\(targetcontrol=\"1.2.840.113556.1.4.805\"\)\ \(version\ 3.0\;\ acl\ \"EUS\ Administrator\ SubTree\ delete\ control\ access\"\;\ allow\(read\)\ groupdn=\"ldap:///cn=OracleContextAdmins,cn=Groups,cn=OracleContext,${BASEDN}\"\;\) \
    --hostname ${HOST} \
    --port ${PORT_ADMIN} \
    --bindDN "${DIRMAN}" \
    --bindPasswordFile "${PWD_FILE}" \
    --no-prompt \
    --verbose \
    --trustAll
# - EOF -----------------------------------------------------------------
