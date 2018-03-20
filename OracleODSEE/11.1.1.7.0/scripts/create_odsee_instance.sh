#!/bin/bash
# -----------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------
# Name.......: create_oud_instance.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2017.12.04
# Revision...: 
# Purpose....: Helper script to create the OUD instance 
# Notes......: Script to create an OUD instance. If configuration files 
#              are provided, the will be used to configure the instance.
# Reference..: --
# License....: Licensed under the Universal Permissive License v 1.0 as 
#              shown at http://oss.oracle.com/licenses/upl.
# -----------------------------------------------------------------------
# Modified...: 
# see git revision history for more information on changes/updates
# -----------------------------------------------------------------------
# - Environment Variables -----------------------------------------------
# - Set default values for environment variables if not yet defined. 
# -----------------------------------------------------------------------
# Default name for ODSEE instance
export ODSEE_INSTANCE=${ODSEE_INSTANCE:-dsDocker}

# ODSEE instance base directory
export OUD_INSTANCE_BASE=${OUD_INSTANCE_BASE:-"$ORACLE_DATA/instances"}

# ODSEE instance home directory
export ODSEE_INSTANCE_HOME=${OUD_INSTANCE_BASE}/${ODSEE_INSTANCE}
export ODSEE_HOME=${ORACLE_BASE}/product/${ORACLE_HOME_NAME}

# Default values for the instance home and admin directory
export OUD_INSTANCE_ADMIN=${OUD_INSTANCE_ADMIN:-${ORACLE_DATA}/admin/${ODSEE_INSTANCE}}

# Default values for host and ports
export HOST=$(hostname 2>/dev/null ||echo $HOSTNAME)    # Hostname
export PORT=${PORT:-1389}                               # Default LDAP port
export PORT_SSL=${PORT_SSL:-1636}                       # Default LDAPS port

# Default value for the directory
export ADMIN_USER=${ADMIN_USER:-'cn=Directory Manager'} # Default directory admin user
export PWD_FILE=${PWD_FILE:-${OUD_INSTANCE_ADMIN}/etc/${ODSEE_INSTANCE}_pwd.txt}
export ADMIN_PASSWORD=${ADMIN_PASSWORD:-""}             # Default directory admin password
export BASEDN=${BASEDN:-'dc=postgasse,dc=org'}          # Default directory base DN
export SAMPLE_DATA=${SAMPLE_DATA:-'TRUE'}               # Flag to load sample data

# default folder for OUD instance init scripts
export OUD_INSTANCE_INIT=${OUD_INSTANCE_INIT:-$ORACLE_DATA/scripts}
# - EOF Environment Variables -------------------------------------------

echo "--- Setup ODSEE environment on volume ${ORACLE_DATA} --------------------"

echo "--- Setup OUD environment on volume ${ORACLE_DATA} ----------------------"
# create instance directories on volume
mkdir -v -p ${ORACLE_DATA}
for i in admin backup etc instances domains log scripts; do
    mkdir -v -p ${ORACLE_DATA}/${i}
done
mkdir -v -p ${OUD_INSTANCE_ADMIN}/etc

# create oudtab file for OUD Base
OUDTAB=${ORACLE_DATA}/etc/oudtab
echo "${OUD_INSTANCE}:${PORT}:${PORT_SSL}:::ODSEE" >>${OUDTAB}

# generate a password
if [ -z ${ADMIN_PASSWORD} ]; then
    # Auto generate Oracle WebLogic Server admin password
    while true; do
        s=$(cat /dev/urandom | tr -dc "A-Za-z0-9" | fold -w 8 | head -n 1)
        if [[ ${#s} -ge 8 && "$s" == *[A-Z]* && "$s" == *[a-z]* && "$s" == *[0-9]*  ]]; then
            break
        else
            echo "Password does not Match the criteria, re-generating..."
        fi
    done
    echo "----------------------------------------------------------------------"
    echo "    Oracle Directory Server Enterprise Edition auto generated instance"
    echo "    admin password :"
    echo "    ----> Directory Admin : ${ADMIN_USER} "
    echo "    ----> Admin password  : $s"
    echo "----------------------------------------------------------------------"
else
    s=${ADMIN_PASSWORD}
    echo "----------------------------------------------------------------------"
    echo "    Oracle Directory Server Enterprise Edition auto generated instance"
    echo "    admin password :"
    echo "    ----> Directory Admin : ${ADMIN_USER} "
    echo "    ----> Admin password  : $s"
    echo "---------------------------------------------------------------"
fi

# write password file
echo "$s" > ${PWD_FILE}

# set instant init location create folder if it does exists
if [ -d "${OUD_INSTANCE_ADMIN}/create" ]; then
    ODSEE_INSTANCE_INIT="${OUD_INSTANCE_ADMIN}/create"
else
    ODSEE_INSTANCE_INIT="${ODSEE_INSTANCE_INIT}/setup"
fi

echo "--- Create ODSE instance ---------------------------------------------"
echo "  ODSEE_INSTANCE      = ${ODSEE_INSTANCE}"
echo "  ODSEE_INSTANCE_BASE = ${OUD_INSTANCE_BASE}"
echo "  ODSEE_INSTANCE_HOME = ${ODSEE_INSTANCE_HOME}"
echo "  OUD_INSTANCE_ADMIN  = ${OUD_INSTANCE_ADMIN}"
echo "  OUD_INSTANCE_INIT   = ${OUD_INSTANCE_INIT}"
echo "  ODSEE_HOME          = ${ODSEE_HOME}"
echo "  PORT                = ${PORT}"
echo "  PORT_SSL            = ${PORT_SSL}"
echo "  ADMIN_USER          = ${ADMIN_USER}"
echo "  BASEDN              = ${BASEDN}"
echo ""

# Create an directory
${ODSEE_HOME}/bin/dsadm create -p ${PORT} -P ${PORT_SSL} -w ${PWD_FILE} ${ODSEE_INSTANCE_HOME}
if [ $? -eq 0 ]; then
    echo "--- Successfully created ODSEE instance (${ODSEE_INSTANCE}) -------------------"
    # Execute custom provided setup scripts
    ${ODSEE_HOME}/bin/dsadm start ${ODSEE_INSTANCE_HOME}
    ${DOCKER_SCRIPTS}/config_odsee_instance.sh ${ODSEE_INSTANCE_INIT}/setup
else
    echo "--- ERROR creating ODSEE instance (${ODSEE_INSTANCE}) -------------------------"
    exit 1
fi
# --- EOF -------------------------------------------------------------------