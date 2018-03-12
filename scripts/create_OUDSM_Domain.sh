#!/bin/bash
# ---------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: create_OUDSM_Domain.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2017.12.04
# Revision...: 
# Purpose....: Helper script to create the OUDSM domain  
# Notes......: Script to create an OUDSM domain.
# Reference..: --
# License....: CDDL 1.0 + GPL 2.0
# ---------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# TODO.......:
# ---------------------------------------------------------------------------

# - Customization -----------------------------------------------------------
export PORT=${PORT:-7001}       # Default admin port
export PORT_SSL=${PORT_SSL:-7002} # Default SSL admin port
export ADMIN_USER=${ADMIN_USER:-weblogic}   # Default directory admin user
export ADMIN_PASSWORD=${ADMIN_PASSWORD:-""} # Default directory admin password

# - End of Customization ----------------------------------------------------
echo "--- Setup OUDSM environment on volume ${ORACLE_DATA} --------------------"

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
echo "#  6 : 6 : Directory type eg OUD, OID, ODSEE or OUDSM"    >>${OUDTAB}
echo "#---------------------------------------------"           >>${OUDTAB}
echo "${DOMAIN_NAME}:${PORT}:${PORT_SSL}:${PORT_ADMIN}:${PORT_REP}:OUDSM" >>${OUDTAB}

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
. ${ORACLE_BASE}/local/bin/oudenv.sh ${DOMAIN_NAME} SILENT

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
    echo "    Oracle WebLogic Server Auto Generated OUDSM Domain:"
    echo "    ----> 'weblogic' admin password: $s"
    echo "---------------------------------------------------------------"
else
    s=${ADMIN_PASSWORD}
    echo "---------------------------------------------------------------"
    echo "    Oracle WebLogic Server Auto Generated OUDSM Domain:"
    echo "    ----> 'weblogic' admin password: $s"
    echo "---------------------------------------------------------------"
fi 
sed -i -e "s|ADMIN_PASSWORD|$s|g" ${DOCKER_SCRIPTS}/create_OUDSM.py

echo "--- Create WebLogic Server Domain (${DOMAIN_NAME}) -----------------------------"
echo "  DOMAIN_NAME=${DOMAIN_NAME}"
echo "  DOMAIN_HOME=${DOMAIN_HOME}"
echo "  PORT=${PORT}"
echo "  PORT_SSL=${PORT_SSL}"
echo "  ADMIN_USER=${ADMIN_USER}"

# Create an empty domain
${ORACLE_BASE}/product/fmw12.2.1.3.0/oracle_common/common/bin/wlst.sh -skipWLSModuleScanning ${DOCKER_SCRIPTS}/create_OUDSM.py
if [ $? -eq 0 ]; then
    echo "--- Successfully created WebLogic Server Domain (${DOMAIN_NAME}) --------------"
else 
    echo "--- ERROR creating WebLogic Server Domain (${DOMAIN_NAME}) --------------------"
fi
${DOMAIN_HOME}/bin/setDomainEnv.sh
# --- EOF -------------------------------------------------------------------
