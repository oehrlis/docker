#!/bin/bash
# ---------------------------------------------------------------------------
# Trivadis - Part of Accenture, Platform Factory - Transactional Data Platform
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: 01_setup_os_db.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2019.04.04
# Revision...: 
# Purpose....: Script to configure OEL for Oracle Database installations.
# Notes......: Script would like to be executed as root :-).
# Reference..: --
# License....: Apache License Version 2.0, January 2004 as shown
#              at http://www.apache.org/licenses/
# ---------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# ---------------------------------------------------------------------------

# - Environment Variables ---------------------------------------------------
# source genric environment variables and functions
source "$(dirname ${BASH_SOURCE[0]})/00_setup_init.sh"
# - EOF Environment Variables -----------------------------------------------

# - Main --------------------------------------------------------------------
# - create krb5 config file ---------------------------------------------
if [ ! -f "${TNS_ADMIN}/${KRB5_CONF}" ]; then
    echo " - Create kerberos config file ${KRB5_CONF} using:"
    echo "      TNS_ADMIN           :   ${TNS_ADMIN}"
    echo "      KRB5_CONF           :   ${KRB5_CONF}"
    echo "      KDC_DOMAIN_REALM    :   ${KDC_DOMAIN_REALM}"
    echo "      KDC_DOMAIN_NAME     :   ${KDC_DOMAIN_NAME}"
    echo "      KDC_HOSTNAME        :   ${KDC_HOSTNAME}"
    echo "      KDC_FQDN            :   ${KDC_FQDN}"
    echo "      KDC_IPADDRESS       :   ${KDC_IPADDRESS}"

    cat << KRB5 > ${TNS_ADMIN}/${KRB5_CONF}
# --------------------------------------------------------------------------- 
# Trivadis - Part of Accenture, Platform Factory - Transactional Data Platform
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# --------------------------------------------------------------------------- 
# Name.......: krb5.conf
# Purpose....: Automatic generated Kerberos config file.
# --------------------------------------------------------------------------- 
[libdefaults]
 default_realm = ${KDC_DOMAIN_REALM}
 clockskew=300
 ticket_lifetime = 24h
 renew_lifetime = 7d
 forwardable = true

[realms]
 ${KDC_DOMAIN_REALM} = {
   kdc = ${KDC_FQDN}
   admin_server = ${KDC_FQDN}
}

[domain_realm]
.${KDC_DOMAIN_NAME} = ${KDC_DOMAIN_REALM}
${KDC_DOMAIN_NAME} = ${KDC_DOMAIN_REALM}
KRB5

else
    echo " - Kerberos config file ${KRB5_CONF} already exists"
fi

# - update sqlnet.ora file ----------------------------------------------
echo " - Update sqlnet.ora file ${SQLNET_FILE} using:"
echo "      TNS_ADMIN       :   ${TNS_ADMIN}"
echo "      SQLNET_FILE     :   ${SQLNET_FILE}"
echo "      KRB5_CONF       :   ${KRB5_CONF}"
echo "      KRB5_KEYTAB     :   ${KRB5_KEYTAB}"
echo "      KRB5_REALMS     :   ${KRB5_REALMS}"
echo "      KRB5_CC_NAME    :   ${KRB5_CC_NAME}"

# remove kerberos entries
for i in    AUTHENTICATION_SERVICES \
            FALLBACK_AUTHENTICATION \
            KERBEROS5_KEYTAB \
            KERBEROS5_REALMS \
            KERBEROS5_CC_NAME \
            KERBEROS5_CONF \
            KERBEROS5_CONF_MIT \
            AUTHENTICATION_KERBEROS5_SERVICE \
            Kerberos EOF; do
    sed -i "/$i/d" ${TNS_ADMIN}/${SQLNET_FILE}
done
# add new kerberos entries
cat << SQLNET >>${TNS_ADMIN}/${SQLNET_FILE}
# Kerberos Configuration
SQLNET.AUTHENTICATION_SERVICES = (BEQ,KERBEROS5)
SQLNET.FALLBACK_AUTHENTICATION = TRUE
SQLNET.KERBEROS5_KEYTAB = ${TNS_ADMIN}/${KRB5_KEYTAB}
SQLNET.KERBEROS5_REALMS = ${TNS_ADMIN}/${KRB5_REALMS}
SQLNET.KERBEROS5_CC_NAME = ${TNS_ADMIN}/${KRB5_CC_NAME}
SQLNET.KERBEROS5_CONF = ${TNS_ADMIN}/${KRB5_CONF}
SQLNET.KERBEROS5_CONF_MIT=TRUE
SQLNET.AUTHENTICATION_KERBEROS5_SERVICE = oracle
#================================================================= EOF
SQLNET

# copy the kerberos keytab file
cp ${CONFIG_KRB5_KEYTAB} ${TNS_ADMIN}/${KRB5_KEYTAB}

oklist -e -k ${TNS_ADMIN}/${KRB5_KEYTAB}
# --- EOF --------------------------------------------------------------------