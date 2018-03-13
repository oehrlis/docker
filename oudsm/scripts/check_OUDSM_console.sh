#!/bin/bash
# ---------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: check_OUDSM_console.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2017.12.04
# Revision...: 
# Purpose....: check the status of the OUDSM console for docker HEALTHCHECK 
# Notes......: Script is a wrapper for a simple curl. It makes sure, that the 
#              status of the docker OUDSM console is checked and the exit code
#              is docker compliant (0 or 1).
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

# run OUD status check
URL="http://$(hostname):$PORT/oudsm/"
curl -sSf ${URL} >/dev/null 2>&1

# normalize output for docker....
OUD_ERROR=$?
if [ ${OUD_ERROR} -gt 0 ]; then
    echo "$0: OUDSM check (${URL}) did return error ${OUD_ERROR}"
    exit 1
else
    exit 0
fi
# --- EOF -------------------------------------------------------------------