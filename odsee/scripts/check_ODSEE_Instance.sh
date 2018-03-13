#!/bin/bash
# ---------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: check_ODSE_Instance.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2017.12.19
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

# Get dsadm
export DSADM=$(find $ORACLE_BASE -name dsadm)
export ODSEE_INSTANCE_HOME=$(dirname $(find $ORACLE_DATA/instances -name config))
export ODSEE_INSTANCE=$(basename ${ODSEE_INSTANCE_HOME})

${DSADM} info ${ODSEE_INSTANCE_HOME} >/dev/null
# check if dsadm could be executed
if [ ! $? -eq 0 ]; then
    echo "$0: Can execute ${DSADM}"
    exit 1
fi

# run again dsadm to get the status
STATUS=$(${DSADM} info ${ODSEE_INSTANCE_HOME}|grep -i state|cut -d: -f2| xargs)
# Normalize STATUS
STATUS=$(echo $STATUS| sed 's/^Running$/0/gi')
STATUS=$(echo $STATUS| sed 's/^Stopped$/1/gi')

# check if ODSEE instance is running
if [ ! $STATUS -eq 0 ]; then
    echo "$0: ODSEE instance ${ODSEE_INSTANCE} does not run" 
    exit 1
else
    exit 0
fi
# --- EOF -------------------------------------------------------------------