#!/bin/bash
# ---------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: start_OUDSM_Domain.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2017.12.04
# Revision...: 
# Purpose....: Build script for docker image 
# Notes......: Script does look for the AdminServer.log. If it does not exist
#              it assume that the container is started the first time. A new
#              OUDSM domain will be created.
# Reference..: --
# License....: CDDL 1.0 + GPL 2.0
# ---------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# TODO.......:
# ---------------------------------------------------------------------------
# Environment variables required for this build (do NOT change)
# -------------------------------------------------------------

# - Customization -----------------------------------------------------------
export DOMAIN_NAME=${DOMAIN_NAME:-oudsm_domain}         # Default for OUDSM domain
export CREATE_DOMAIN=${CREATE_DOMAIN:-'TRUE'}       # Flag to create domain

# OUDSM domain home directory
export DOMAIN_HOME=${OUDSM_DOMAIN_BASE}/${DOMAIN_NAME}
# - End of Customization ----------------------------------------------------

# ---------------------------------------------------------------------------
# SIGTERM handler
# ---------------------------------------------------------------------------
function int_wls() {
    echo "---------------------------------------------------------------"
    echo "SIGINT received, shutting down the WLS OUDSM Domain!"
    echo "---------------------------------------------------------------"
    ${DOMAIN_HOME}/bin/stopWebLogic.sh
}

# ---------------------------------------------------------------------------
# SIGTERM handler
# ---------------------------------------------------------------------------
function term_wls() {
    echo "---------------------------------------------------------------"
    echo "SIGTERM received, shutting down the WLS OUDSM Domain!"
    echo "---------------------------------------------------------------"
    ${DOMAIN_HOME}/bin/stopWebLogic.sh
}

# ---------------------------------------------------------------------------
# SIGKILL handler
# ---------------------------------------------------------------------------
function kill_wls() {
    echo "---------------------------------------------------------------"
    echo "SIGKILL received, shutting down the WLS OUDSM Domain!"
    echo "---------------------------------------------------------------"
kill -9 $childPID
}

# Set SIGTERM handler
trap int_wls SIGINT

# Set SIGTERM handler
trap term_wls SIGTERM

# Set SIGKILL handler
trap kill_wls SIGKILL

# Normalize CREATE_INSTANCE
export CREATE_DOMAIN=$(echo $CREATE_DOMAIN| sed 's/^false$/0/gi')
export CREATE_DOMAIN=$(echo $CREATE_DOMAIN| sed 's/^true$/1/gi')

echo "--- Seeking for an OUDSM environment on volume ${ORACLE_DATA} -------------"
# check if AdminServer.log does exists
if [ -f ${DOMAIN_HOME}/servers/AdminServer/logs/AdminServer.log ]; then
    # Start existing OUDSM domain
    echo "---------------------------------------------------------------"
    echo "   Start Oracle WebLogic Server Domain (${DOMAIN_NAME}):"
    echo "---------------------------------------------------------------"
    ${DOMAIN_HOME}/startWebLogic.sh
elif [ ${CREATE_DOMAIN} -eq 1 ]; then
    echo "---------------------------------------------------------------"
    echo "   Create Oracle WebLogic Server Domain (${DOMAIN_NAME}):"
    echo "---------------------------------------------------------------"
    # CREATE_DOMAIN is true, therefore we will create new OUDSM domain
    /opt/docker/bin/create_OUDSM_Domain.sh
    
    # start OUDSM instance
    echo "---------------------------------------------------------------"
    echo "   Start Oracle WebLogic Server Domain (${DOMAIN_NAME}):"
    echo "---------------------------------------------------------------"
    ${DOMAIN_HOME}/startWebLogic.sh
else
    echo "---------------------------------------------------------------"
    echo "   WARNING: OUDSM AdminServer.log does not exist and DOMAIN_NAME "
    echo "   is false. OUDSM domain has to be created manually"
    echo "---------------------------------------------------------------"
fi

# Start Admin Server and tail the logs
mkdir -p ${DOMAIN_HOME}/servers/AdminServer/logs
touch ${DOMAIN_HOME}/servers/AdminServer/logs/AdminServer.log
tail -f ${DOMAIN_HOME}/servers/AdminServer/logs/AdminServer.log &

childPID=$!
wait $childPID
# --- EOF -------------------------------------------------------------------