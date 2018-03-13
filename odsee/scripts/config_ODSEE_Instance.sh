#!/bin/bash
# ---------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: config_ODSEE_Instance.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2017.12.19
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
# License....: CDDL 1.0 + GPL 2.0
# ---------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# TODO.......:
# ---------------------------------------------------------------------------

# use parameter 1 as script root
SCRIPTS_ROOT="$1";

# Check whether parameter has been passed on
if [ -z "${SCRIPTS_ROOT}" ]; then
   echo "$0: No SCRIPTS_ROOT passed on, no scripts will be run";
   exit 1;
fi

# Load OUD environment
. ${ORACLE_BASE}/local/bin/oudenv.sh ${ODSEE_INSTANCE} SILENT

# Execute custom provided files (only if directory exists and has files in it)
if [ -d "${SCRIPTS_ROOT}" ] && [ -n "$(ls -A ${SCRIPTS_ROOT})" ]; then
    echo "";
    echo "--- Executing user defined scripts ---------------------------------------------"

# Loop over the files in the current directory
    for f in $(find ${SCRIPTS_ROOT} -maxdepth 1 -type f|sort); do
        case "$f" in
            *.sh)     echo "$0: running $f"; . "$f" ;;
            *.ldif)   echo "$0: running $f"; echo "exit" | ${ODSEE_HOME}/dsrk/bin/ldapmodify -h $(hostname) -p ${LDAP_PORT} -D "${ADMIN_USER}" -j ${PWD_FILE} -f "$f"; echo ;;
           *)        echo "$0: ignoring $f" ;; 
        esac
        echo "";
    done
    echo "--- Successfully executed user defined -----------------------------------------"
  echo ""
else
    echo "--- no user defined scripts to execute -----------------------------------------"
fi
# --- EOF -------------------------------------------------------------------