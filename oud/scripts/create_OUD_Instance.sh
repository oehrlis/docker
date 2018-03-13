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
export PORT_REP=${PORT_REP:-8989}                       # Default replication port
export PORT_ADMIN=${PORT_ADMIN:-4444}                   # Default admin port
export ADMIN_USER=${ADMIN_USER:-'cn=Directory Manager'} # Default directory admin user
export ADMIN_PASSWORD=${ADMIN_PASSWORD:-""}             # Default directory admin password
export BASEDN=${BASEDN:-'dc=postgasse,dc=org'}          # Default directory base DN
export SAMPLE_DATA=${SAMPLE_DATA:-'TRUE'}               # Flag to load sample data
export OUD_PROXY=${OUD_PROXY:-'FALSE'}                  # Flag to create proxy instance

# default folder for OUD instance init scripts
export OUD_INSTANCE_INIT=${OUD_INSTANCE_INIT:-$ORACLE_DATA/scripts}
# - End of Customization ----------------------------------------------------

echo "--- Setup OUD environment on volume ${ORACLE_DATA} --------------------"

# create instance directories on volume
mkdir -v -p ${ORACLE_DATA}
for i in admin backup etc instances domains log scripts; do
    mkdir -v -p ${ORACLE_DATA}/${i}
done

# create oudtab file
OUDTAB=${ORACLE_DATA}/etc/oudtab
echo "# OUD Config File"                                        > ${OUDTAB}
echo "#  1 : OUD Instance Name"                                 >>${OUDTAB}
echo "#  2 : OUD LDAP Port"                                     >>${OUDTAB}
echo "#  3 : OUD LDAPS Port"                                    >>${OUDTAB}
echo "#  4 : OUD Admin Port"                                    >>${OUDTAB}
echo "#  5 : OUD Replication Port"                              >>${OUDTAB}
echo "#  6 : Directory type eg OUD, OID, ODSEE or OUDSM"        >>${OUDTAB}
echo "#---------------------------------------------"           >>${OUDTAB}
echo "${OUD_INSTANCE}:${PORT}:${PORT_SSL}:${PORT_ADMIN}:${PORT_REP}:OUD" >>${OUDTAB}

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
. ${ORACLE_BASE}/local/bin/oudenv.sh ${OUD_INSTANCE} SILENT

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
    echo "---------------------------------------------------------------"
    echo "    Oracle Unified Directory Server auto generated instance"
    echo "    admin password :"
    echo "    ----> Directory Admin : ${ADMIN_USER} "
    echo "    ----> Admin password  : $s"
    echo "---------------------------------------------------------------"
else
    s=${ADMIN_PASSWORD}
    echo "---------------------------------------------------------------"
    echo "    Oracle Unified Directory Server auto generated instance"
    echo "    admin password :"
    echo "    ----> Directory Admin : ${ADMIN_USER} "
    echo "    ----> Admin password  : $s"
    echo "---------------------------------------------------------------"
fi

# write password file
echo "$s" > ${OUD_INSTANCE_ADMIN}/etc/${OUD_INSTANCE}_pwd.txt

# set instant init location create folder if it does exists
if [ -d "${OUD_INSTANCE_ADMIN}/create" ]; then
    OUD_INSTANCE_INIT="${OUD_INSTANCE_ADMIN}/create"
else
    OUD_INSTANCE_INIT="${OUD_INSTANCE_INIT}/setup"
fi

echo "--- Create OUD instance --------------------------------------------------------"
echo "  OUD_INSTANCE       = ${OUD_INSTANCE}"
echo "  OUD_INSTANCE_BASE  = ${OUD_INSTANCE_BASE}"
echo "  OUD_INSTANCE_ADMIN = ${OUD_INSTANCE_ADMIN}"
echo "  OUD_INSTANCE_INIT  = ${OUD_INSTANCE_INIT}"
echo "  OUD_INSTANCE_HOME  = ${INSTANCE_BASE}/${OUD_INSTANCE}"
echo "  PORT               = ${PORT}"
echo "  PORT_SSL           = ${PORT_SSL}"
echo "  PORT_REP           = ${PORT_REP}"
echo "  PORT_ADMIN         = ${PORT_ADMIN}"
echo "  ADMIN_USER         = ${ADMIN_USER}"
echo "  BASEDN             = ${BASEDN}"
echo "  OUD_PROXY          = ${OUD_PROXY}"
echo ""

# Normalize CREATE_INSTANCE
export OUD_PROXY=$(echo $OUD_PROXY| sed 's/^false$/0/gi')
export OUD_PROXY=$(echo $OUD_PROXY| sed 's/^true$/1/gi')

if [ ${OUD_PROXY} -eq 0 ]; then
# Create an directory
${ORACLE_BASE}/product/${ORACLE_HOME_NAME}/oud/oud-setup \
    --cli \
    --instancePath ${OUD_INSTANCE_HOME}/OUD \
    --adminConnectorPort ${PORT_ADMIN} \
    --rootUserDN "${ADMIN_USER}" \
    --rootUserPasswordFile ${OUD_INSTANCE_ADMIN}/etc/${OUD_INSTANCE}_pwd.txt \
    --ldapPort ${PORT} \
    --ldapsPort ${PORT_SSL} \
    --generateSelfSignedCertificate \
    --hostname $(hostname) \
    --baseDN ${BASEDN} \
    --addBaseEntry \
    --serverTuning jvm-default \
    --offlineToolsTuning autotune \
    --no-prompt \
    --noPropertiesFile
    if [ $? -eq 0 ]; then
        echo "--- Successfully created OUD instance (${OUD_INSTANCE}) ------------------------"
        # Execute custom provided setup scripts
        
        ${DOCKER_SCRIPTS}/config_OUD_Instance.sh ${OUD_INSTANCE_INIT}
    else
        echo "--- ERROR creating OUD instance (${OUD_INSTANCE}) ------------------------------"
        exit 1
    fi
fi
# --- EOF -------------------------------------------------------------------