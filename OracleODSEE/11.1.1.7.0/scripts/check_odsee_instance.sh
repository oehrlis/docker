#!/bin/bash
# -----------------------------------------------------------------------
# Trivadis - Part of Accenture, Platform Factory - Transactional Data Platform
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------
# Name.......: check_odsee_instance.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2017.12.19
# Revision...: 
# Purpose....: check the status of the OUD instance for docker HEALTHCHECK 
# Notes......: Script is a wrapper for oud_status.sh. It makes sure, that
#              the status of the docker OUD instance is checked and the 
#              exit code of oud_status.sh is docker compliant (0 or 1).
# Reference..: --
# License....: Apache License Version 2.0, January 2004 as shown
#              at http://www.apache.org/licenses/
# -----------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# -----------------------------------------------------------------------

# - Environment Variables -----------------------------------------------
# - Set default values for environment variables if not yet defined. 
# -----------------------------------------------------------------------
export ODSEE_HOME=${ORACLE_BASE}/product/${ORACLE_HOME_NAME}
export DSADM="${ODSEE_HOME}/bin/dsadm"

# Default name for ODSEE instance
export ODSEE_INSTANCE=${ODSEE_INSTANCE:-dsDocker}

# ODSEE instance base directory
export OUD_INSTANCE_BASE=${OUD_INSTANCE_BASE:-"$ORACLE_DATA/instances"}

# ODSEE instance home directory
export ODSEE_INSTANCE_HOME=${OUD_INSTANCE_BASE}/${ODSEE_INSTANCE}
# - EOF Environment Variables -------------------------------------------

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
# --- EOF ---------------------------------------------------------------