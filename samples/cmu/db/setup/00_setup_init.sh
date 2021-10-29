#!/bin/bash
# ---------------------------------------------------------------------------
# Trivadis - Part of Accenture, Platform Factory - Transactional Data Platform
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: 00_setup_init.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2018.09.27
# Revision...: 
# Purpose....: Script to initialize the setup scripts and add custom config.
# Notes......: When executed, the init scripts will run stuff after call init 
#              script. If the file is just sourced, only the common functions 
#              and environment variables will be set.
# Reference..: --
# License....: Apache License Version 2.0, January 2004 as shown
#              at http://www.apache.org/licenses/
# ---------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# ---------------------------------------------------------------------------
# - Customization -----------------------------------------------------------
# - just add/update any kind of customized environment variable here
# export KDC_DOMAIN_NAME="trivadislabs.com"                   # domain name of you KDC 
# export KDC_HOSTNAME="ad"                                    # host name of KDC / AD domain controler
# export KDC_DOMAIN_REALM="TRIVADISLABS.COM"                  # KDC realm name
# export AD_BASEDN="dc=trivadislabs,dc=com"                   # AD base DN
# export AD_USER_NAME="oracle18c"                             # AD user used for CMU
# export AD_DISTINGUISH_NAME="cn=${AD_USER_NAME},cn=Users,${AD_BASEDN}" } # DN for AD user used for CMU
# export AD_PASSWORD=""                                       # AD password for user used for CMU
# export CONFIG_KRB5_KEYTAB="/u01/config/etc/keytab.cmudb"    # Path to keytab file exported from AD
# export CONFIG_AD_ROOT_CERT="/u01/config/etc/ad_root.cer"    # Path to root certificate file exported from AD
# - End of Customization ----------------------------------------------------

# - Environment Variables ---------------------------------------------------
# basic TNS configuration
export ORACLE_ROOT=${ORACLE_ROOT:-"/u00"}   # root folder for ORACLE_BASE and binaries
export ORACLE_DATA=${ORACLE_DATA:-"/u01"}   # Oracle data folder eg volume for docker
export ORACLE_BASE=${ORACLE_BASE:-${ORACLE_ROOT}/app/oracle}
export TNS_ADMIN=${TNS_ADMIN:-${ORACLE_BASE}/network/admin}

# sqlnet config file names
export SQLNET_FILE=${SQLNET_FILE:-"sqlnet.ora"}
export DSI_FILE=${DSI_FILE:-"dsi.ora"}

# KDC configuration
export KDC_DOMAIN_NAME=${KDC_DOMAIN_NAME:-"trivadislabs.com"}   # IP address of KDC / AD domain controler
export KDC_HOSTNAME=${KDC_HOSTNAME:-"ad"}                       # Host name address of KDC / AD domain controler
export KDC_FQDN=${KDC_FQDN:-${KDC_HOSTNAME}.${KDC_DOMAIN_NAME}} # Host name address of KDC / AD domain controler
export KDC_IPADDRESS=${KDC_IPADDRESS:-"10.0.0.4"}               # IP address of KDC / AD domain controler
export KDC_DOMAIN_REALM=${KDC_DOMAIN_REALM:-"TRIVADISLABS.COM"} # KDC realm / AD domain name

# AD admin context
export AD_BASEDN=${AD_BASEDN:-$(echo ${KDC_DOMAIN_NAME}|sed 's/\./,dc=/'|sed 's/^/dc=/')} 
export AD_USER_NAME=${AD_USER_NAME:-"oracle18c"}
export AD_DISTINGUISH_NAME=${AD_DISTINGUISH_NAME:-"cn=${AD_USER_NAME},cn=Users,${AD_BASEDN}" }
export AD_PASSWORD=${AD_PASSWORD:-$(cat "${ORACLE_DATA}/config/etc/ad_service_password.txt")}
export AD_ROOT_CERT=${AD_ROOT_CERT:-"ad_root.cer"}

# krb5 config file names
export KRB5_CONF=${KRB5_CONF:-"krb5.conf"}                      # default name for krb5 configuration file
export KRB5_KEYTAB=${KRB5_KEYTAB:-"keytab.cmudb"}                # default name for krb5 keytab file
export KRB5_REALMS=${KRB5_REALMS:-"krb5.realms"}                # default name for krb5 realms file
export KRB5_CC_NAME=${KRB5_CC_NAME:-"krb5.ccache"}              # default name for krb5 credential cache file

export CONFIG_KRB5_KEYTAB=${CONFIG_KRB5_KEYTAB:-${ORACLE_DATA}/config/etc/${KRB5_KEYTAB}}
export CONFIG_AD_ROOT_CERT=${CONFIG_AD_ROOT_CERT:-${ORACLE_DATA}/config/etc/${AD_ROOT_CERT}}
# - EOF Environment Variables -----------------------------------------------

# check if script is sourced and return/exit
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    echo " - Set common functions and variables ---------------------------------"
    return
fi

# Still here, seems that script is executed
# - call init script ---------------------------------------------------------
echo " - Call init script ---------------------------------------------------"
# --- EOF --------------------------------------------------------------------