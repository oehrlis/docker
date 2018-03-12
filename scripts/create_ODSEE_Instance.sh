#!/bin/bash
# ---------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: create_OUD_instance.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2017.12.04
# Revision...: 
# Purpose....: Helper script to create the OUD instance 
# Notes......: Script to create an OUD instance. If configuration files are
#              provided, the will be used to configure the instance.
# Reference..: --
# License....: CDDL 1.0 + GPL 2.0
# ---------------------------------------------------------------------------
# Modified...: 
# see git revision history for more information on changes/updates
# TODO.......:
# ---------------------------------------------------------------------------
# - Customization -----------------------------------------------------------
export PORT=${PORT:-1389}                               # Default LDAP port
export PORT_SSL=${PORT_SSL:-1636}                       # Default LDAPS port
export ADMIN_PASSWORD=${ADMIN_PASSWORD:-""}             # Default directory admin password
export BASEDN=${BASEDN:-'dc=postgasse,dc=org'}          # Default directory base DN
export SAMPLE_DATA=${SAMPLE_DATA:-'TRUE'}               # Flag to load sample data

# default folder for ODSEE instance init scripts
export ODSEE_INSTANCE_INIT=${ODSEE_INSTANCE_INIT:-$ORACLE_DATA/scripts}
export ODSEE_HOME=${ODSEE_HOME:-"$ORACLE_BASE/product/$ORACLE_HOME_NAME"}    
# - End of Customization ----------------------------------------------------

echo "--- Setup ODSEE environment on volume ${ORACLE_DATA} --------------------"

# create instance directories on volume
mkdir -v -p ${ORACLE_DATA}
for i in admin backup etc instances domains log scripts; do
    mkdir -v -p ${ORACLE_DATA}/${i}
done

# create oudtab file
OUDTAB=${ORACLE_DATA}/etc/oudtab
echo "# OUD Config File"                                    > ${OUDTAB}
echo "#  1 : OUD Instance Name"                             >>${OUDTAB}
echo "#  2 : OUD LDAP Port"                                 >>${OUDTAB}
echo "#  3 : OUD LDAPS Port"                                >>${OUDTAB}
echo "#  4 : OUD Admin Port"                                >>${OUDTAB}
echo "#  5 : OUD Replication Port"                          >>${OUDTAB}
echo "#  6 : Directory type eg OUD, OID, ODSEE or OUDSM"    >>${OUDTAB}
echo "#---------------------------------------------"       >>${OUDTAB}
echo "${ODSEE_INSTANCE}:${PORT}:${PORT_SSL}:${PORT_ADMIN}:${PORT_REP}:ODSEE" >>${OUDTAB}

# Create default config file in ETC_BASE in case they are not yet available...
for i in oud._DEFAULT_.conf oudenv_custom.conf oudenv.conf oudtab; do
    if [ ! -f "${ORACLE_DATA}/etc/${i}" ]; then
        cp ${ORACLE_BASE}/templates/etc/${i} ${ORACLE_DATA}/etc
    fi
done

# create also some soft links from ETC_CORE to ETC_BASE
for i in oudenv.conf oudtab; do
    if [ ! -f "${ORACLE_DATA}/etc/${i}" ]; then
        ln -sf ${ORACLE_DATA}/etc/${i} ${ORACLE_BASE}/etc/${i}
    fi
done

# Load OUD environment for this instance
. ${ORACLE_BASE}/local/bin/oudenv.sh ${ODSEE_INSTANCE} SILENT

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
echo "$s" > ${OUD_INSTANCE_ADMIN}/etc/${ODSEE_INSTANCE}_pwd.txt


# set instant init location create folder if it does exists
if [ -d "${OUD_INSTANCE_ADMIN}/create" ]; then
    ODSEE_INSTANCE_INIT="${OUD_INSTANCE_ADMIN}/create"
else
    ODSEE_INSTANCE_INIT="${ODSEE_INSTANCE_INIT}/setup"
fi

echo "--- Create ODSE instance --------------------------------------------------------"
echo "  ODSEE_INSTANCE      = ${ODSEE_INSTANCE}"
echo "  ODSEE_INSTANCE_BASE = ${OUD_INSTANCE_BASE}"
echo "  OUD_INSTANCE_ADMIN  = ${OUD_INSTANCE_ADMIN}"
echo "  OUD_INSTANCE_INIT   = ${OUD_INSTANCE_INIT}"
echo "  ODSEE_INSTANCE_HOME = ${OUD_INSTANCE_BASE}/${ODSEE_INSTANCE}"
echo "  PORT                = ${PORT}"
echo "  PORT_SSL            = ${PORT_SSL}"
echo "  PORT_REP            = ${PORT_REP}"
echo "  PORT_ADMIN          = ${PORT_ADMIN}"
echo "  ADMIN_USER          = ${ADMIN_USER}"
echo "  BASEDN              = ${BASEDN}"
echo ""

# Create an directory
${ODSEE_HOME}/bin/dsadm create -p ${PORT} -P ${PORT_SSL} -w ${OUD_INSTANCE_ADMIN}/etc/${ODSEE_INSTANCE}_pwd.txt ${ODSEE_INSTANCE_HOME}
if [ $? -eq 0 ]; then
    echo "--- Successfully created ODSEE instance (${ODSEE_INSTANCE}) ------------------------"
    # Execute custom provided setup scripts
    ${ODSEE_HOME}/bin/dsadm start ${ODSEE_INSTANCE_HOME}
    ${DOCKER_SCRIPTS}/config_ODSEE_Instance.sh ${ODSEE_INSTANCE_INIT}/setup
else
    echo "--- ERROR creating ODSEE instance (${ODSEE_INSTANCE}) ------------------------------"
    exit 1
fi
# --- EOF -------------------------------------------------------------------