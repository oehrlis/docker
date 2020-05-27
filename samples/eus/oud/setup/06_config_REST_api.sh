#!/bin/bash
# -----------------------------------------------------------------------
# Trivadis AG, Business Development & Support (BDS)
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------
# Name.......: 06_config_REST_api.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2020.03.04
# Revision...: --
# Purpose....: Script to configure the OUD REST API.
# Notes......: The config file 06_config_REST_api.conf is executed using
#              dsconfig in batch mode. If required, each command can 
#              also be executed individually.
#
#              dsconfig -h ${HOSTNAME} -p $PORT_ADMIN \
#                  -D "cn=Directory Manager"-j $PWD_FILE -X -n \
#                  <COMMAND>
#
# Reference..: https://github.com/oehrlis/oudbase
# License....: GPL-3.0+
# -----------------------------------------------------------------------
# Modified...:
# see git revision history with git log for more information on changes
# -----------------------------------------------------------------------

# - load instance environment -------------------------------------------
. "$(dirname $0)/00_init_environment"
CONFIGFILE="$(dirname $0)/$(basename $0 .sh).conf"      # config file based on script name

# - configure instance --------------------------------------------------
echo "Configure OUD instance ${OUD_INSTANCE} using:"
echo "  CONFIGFILE        : ${CONFIGFILE}"

echo "  Config OUD Instance"
${OUD_INSTANCE_HOME}/OUD/bin/dsconfig \
  --hostname ${HOST} \
  --port ${PORT_ADMIN} \
  --bindDN "${DIRMAN}" \
  --bindPasswordFile "${PWD_FILE}" \
  --no-prompt \
  --verbose \
  --verbose \
  --trustAll \
  --batchFilePath "${CONFIGFILE}"

echo "  Restart OUD Instance"
${OUD_INSTANCE_HOME}/OUD/bin/stop-ds --restart

# - EOF -----------------------------------------------------------------
