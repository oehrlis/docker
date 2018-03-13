#!/bin/bash
# ---------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: check_OUD_Instance.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2017.12.04
# Revision...: 
# Purpose....: check the status of the OUD instance for docker HEALTHCHECK 
# Notes......: Script is a wrapper for oud_status.sh. It makes sure, that the 
#              status of the docker OUD instance is checked and the exit code
#              of oud_status.sh is docker compliant (0 or 1).
# Reference..: --
# License....: CDDL 1.0 + GPL 2.0
# ---------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# TODO.......:
# - Support Replication checks for Docker
# ---------------------------------------------------------------------------

# Load OUD environment
. ${ORACLE_BASE}/local/bin/oudenv.sh ${OUD_INSTANCE} SILENT

# set OUD Status Script
OUD_STATUS="${ORACLE_BASE}/local/bin/oud_status.sh"

# check if OUD Base status scrip is available
if [ ! -x ${OUD_STATUS} ]; then
    echo "$0: Can not find check script ${OUD_STATUS}"
    exit 1
fi

# check if password file is available
if [ ! -e ${PWD_FILE} ]; then
    echo "$0: Can not find password file ${PWD_FILE}"
    exit 1
fi

# run OUD status check
${OUD_STATUS} -v -j ${PWD_FILE} -i ${OUD_INSTANCE}

# normalize output for docker....
OUD_ERROR=$?
if [ ${OUD_ERROR} -gt 0 ]; then
    echo "$0: OUD check (${OUD_STATUS}) did return error ${OUD_ERROR}"
    exit 1
else
    exit 0
fi
# --- EOF -------------------------------------------------------------------