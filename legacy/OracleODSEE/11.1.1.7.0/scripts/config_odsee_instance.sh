#!/bin/bash
# ---------------------------------------------------------------------------
# Trivadis - Part of Accenture, Platform Factory - Transactional Data Platform
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: config_ODSEE_Instance.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2017.12.04
# Revision...: 
# Purpose....: Configure ODSEE instance using custom scripts 
# Notes......: Script is a wrapper for custom setup script in SCRIPTS_ROOT 
#              All files in folder SCRIPTS_ROOT will be executet but not in 
#              any subfolder. Currently just *.sh, *.ldif and *.conf files 
#              are supported.
#              sh   : Shell scripts will be executed
#              ldif : LDIF files will be loaded via ldapmodify
#              To ensure proper order it is recommended to prefix your scripts
#              with a number. For example 01_instance.conf, 
#              02_schemaextention.ldif, etc.
# Reference..: --
# License....: Apache License Version 2.0, January 2004 as shown
#              at http://www.apache.org/licenses/
# ---------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# -----------------------------------------------------------------------
# - Environment Variables -----------------------------------------------
# - Set default values for environment variables if not yet defined. 
# -----------------------------------------------------------------------
# Default name for ODSEE instance
export ODSEE_INSTANCE=${ODSEE_INSTANCE:-dsDocker}
export ODSEE_HOME=${ORACLE_BASE}/product/${ORACLE_HOME_NAME}

# Default values for host and ports
export HOST=$(hostname 2>/dev/null ||cat /etc/hostname ||echo $HOSTNAME)   # Hostname
export PORT=${PORT:-1389}                               # Default LDAP port
export PORT_SSL=${PORT_SSL:-1636}                       # Default LDAPS port

# Default value for the directory
export ADMIN_USER=${ADMIN_USER:-'cn=Directory Manager'} # Default directory admin user
export PWD_FILE=${PWD_FILE:-${OUD_INSTANCE_ADMIN}/etc/${OUD_INSTANCE}_pwd.txt}

# default folder for OUD instance init scripts
export OUD_INSTANCE_INIT=${OUD_INSTANCE_INIT:-$ORACLE_DATA/scripts}
# - EOF Environment Variables -----------------------------------------------

# use parameter 1 as script root
SCRIPTS_ROOT="$1";

# Check whether parameter has been passed on
if [ -z "${SCRIPTS_ROOT}" ]; then
   echo "$0: No SCRIPTS_ROOT passed on, no scripts will be run";
   exit 1;
fi

# Execute custom provided files (only if directory exists and has files in it)
if [ -d "${SCRIPTS_ROOT}" ] && [ -n "$(ls -A ${SCRIPTS_ROOT})" ]; then
    echo "";
    echo "--- Executing user defined scripts -------------------------------------"

# Loop over the files in the current directory
    for f in $(find ${SCRIPTS_ROOT} -maxdepth 1 -type f|sort); do
        # Skip ldif and conf file if a bash script with same name exists
        if [ -f "$(dirname $f)/$(basename $f .ldif).sh" ]; then
            echo "INFO: skip file $f, bash script with same name exists."
            continue
        fi
        echo "--- --------------------------------------------------------------------"
        case "$f" in
            *.sh)     echo "INFO: running $f"; . "$f" ;;
            *.ldif)   echo "INFO: running $f"; echo "exit" | ${ODSEE_HOME}/dsrk/bin/ldapmodify -h $HOST -p ${PORT} -D "${ADMIN_USER}" -j ${PWD_FILE} -f "$f"; echo ;;
           *)        echo "INFO: skip file $f" ;; 
        esac
        echo "";
    done
    echo "--- Successfully executed user defined ---------------------------------"
  echo ""
else
    echo "--- no user defined scripts to execute ---------------------------------"
fi
# --- EOF -------------------------------------------------------------------