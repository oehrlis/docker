#!/bin/bash
# -----------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------
# Name.......: start_ODSEE_Instance.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2017.12.04
# Revision...: 
# Purpose....: Helper script to start the OUD instance 
# Notes......: Script does look for the config.ldif. If it does not exist
#              it assume that the container is started the first time. 
#              A new ODSEE instance will be created. If CREATE_INSTANCE 
#              is set to false no instance will be created.
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

# Flag to create instance on first boot
export CREATE_INSTANCE=${CREATE_INSTANCE:-'TRUE'}

# ODSEE instance base directory
export OUD_INSTANCE_BASE=${OUD_INSTANCE_BASE:-"$ORACLE_DATA/instances"}

# ODSEE instance home directory
export ODSEE_INSTANCE_HOME=${OUD_INSTANCE_BASE}/${ODSEE_INSTANCE}
export ODSEE_HOME=${ORACLE_BASE}/product/${ORACLE_HOME_NAME}
# - EOF Environment Variables -------------------------------------------

# -----------------------------------------------------------------------
# SIGINT handler
# -----------------------------------------------------------------------
function int_odsee() {
    echo "---------------------------------------------------------------"
    echo "SIGINT received, shutting down ODSEE instance!"
    echo "---------------------------------------------------------------"
    ${ODSEE_HOME}/bin/dsadm stop ${ODSEE_INSTANCE_HOME} >/dev/null 2>&1
}

# ---------------------------------------------------------------------------
# SIGTERM handler
# ---------------------------------------------------------------------------
function term_odsee() {
    echo "---------------------------------------------------------------"
    echo "SIGTERM received, shutting down ODSEE instance!"
    echo "---------------------------------------------------------------"
    ${ODSEE_HOME}/bin/dsadm stop ${ODSEE_INSTANCE_HOME} >/dev/null 2>&1
}

# ---------------------------------------------------------------------------
# SIGKILL handler
# ---------------------------------------------------------------------------
function kill_odsee() {
    echo "---------------------------------------------------------------"
    echo "SIGKILL received, shutting down ODSEE instance!"
    echo "---------------------------------------------------------------"
kill -9 $childPID
}

# Set SIGTERM handler
trap int_odsee SIGINT

# Set SIGTERM handler
trap term_odsee SIGTERM

# Set SIGKILL handler
trap kill_odsee SIGKILL

# Normalize CREATE_INSTANCE
export CREATE_INSTANCE=$(echo $CREATE_INSTANCE| sed 's/^false$/0/gi')
export CREATE_INSTANCE=$(echo $CREATE_INSTANCE| sed 's/^true$/1/gi')

echo "--- Seeking for an OUD environment on volume ${ORACLE_DATA} -------------"
# check if dse.ldif does exists
if [ -f ${ODSEE_INSTANCE_HOME}/config/dse.ldif ]; then
    # Start existing OUD instance
    echo "---------------------------------------------------------------"
    echo "   Start ODSEE instance (${ODSEE_INSTANCE}):"
    echo "---------------------------------------------------------------"
    ${ODSEE_HOME}/bin/dsadm start ${ODSEE_INSTANCE_HOME}
elif [ ${CREATE_INSTANCE} -eq 1 ]; then
    echo "---------------------------------------------------------------"
    echo "   Create ODSEE instance (${ODSEE_INSTANCE}):"
    echo "---------------------------------------------------------------"
    # CREATE_INSTANCE is true, therefore we will create new ODSEE instance
    ${DOCKER_SCRIPTS}/create_odsee_instance.sh
    
    if [ $? -eq 0 ]; then
        # restart ODSEE instance
        echo "---------------------------------------------------------------"
        echo "   Start ODSEE instance (${ODSEE_INSTANCE}):"
        echo "---------------------------------------------------------------"
        ${ODSEE_HOME}/bin/dsadm start ${ODSEE_INSTANCE_HOME} >/dev/null 2>&1
    fi
else
    echo "---------------------------------------------------------------"
    echo "   WARNING: ODSEE dse.ldif does not exist and CREATE_INSTANCE "
    echo "   is false. ODSEE instance has to be created manually"
    echo "---------------------------------------------------------------"
fi

# Check whether ODSEE instance is up and running
${DOCKER_SCRIPTS}/check_odsee_instance.sh
# check if ODSEE instance is running
if [ $? -eq 0 ]; then
    echo "---------------------------------------------------------------"
    echo "   ODSEE instance is ready to use:"
    echo "   Instance Name      : ${ODSEE_INSTANCE}"
    echo "   Instance Home (ok) : ${ODSEE_INSTANCE_HOME}"
    echo "   Oracle Home        : ${ODSEE_HOME}"
    echo "   Instance Status    : up"
    echo "   LDAP Port          : ${PORT}"
    echo "   LDAPS Port         : ${PORT_SSL}"
    echo "   Admin Port         : ${ADMIN_PORT}"
    echo "---------------------------------------------------------------"
fi

# Tail on server log and wait (otherwise container will exit)
mkdir -p ${ODSEE_INSTANCE_HOME}/logs
touch ${ODSEE_INSTANCE_HOME}/logs/access
tail -f ${ODSEE_INSTANCE_HOME}/logs/access &

childPID=$!
echo "childPID=$childPID"
wait $childPID
# --- EOF ---------------------------------------------------------------