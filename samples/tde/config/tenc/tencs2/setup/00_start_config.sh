#!/bin/bash
# ------------------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# ------------------------------------------------------------------------------
# Name.......: 00_start_config.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
# Date.......: 2025.01.17
# Version....: v1.0.0
# Purpose....: Start configuration for EXPECTED_HOST and set lock file to "running"
# Notes......: This script initializes the configuration for EXPECTED_HOST
# Reference..: --
# License....: Apache License Version 2.0
# ------------------------------------------------------------------------------
# Modified...:
# see git revision history with git log for more information on changes
# ------------------------------------------------------------------------------

# - Customization --------------------------------------------------------------
# - just add/update any kind of customized environment variable here
EXPECTED_HOST="tencs2"
COMMON_DIR="/u01/shared"
# - End of Customization -------------------------------------------------------

# - Default Values -------------------------------------------------------------
CURRENT_HOST=$(hostname)
STATUS_FILE="${COMMON_DIR}/${EXPECTED_HOST}_status"
# - EOF Default Values ---------------------------------------------------------

# - stop script if not on the expected host ------------------------------------
if [[ "$CURRENT_HOST" != "$EXPECTED_HOST" ]]; then
    echo "ERROR: This script must be run on $EXPECTED_HOST. Current host: $CURRENT_HOST"
    exit 1
fi

# Set the lock file to "running"
echo "running" > "$STATUS_FILE"
echo "Host $EXPECTED_HOST: Configuration started. Lock file $STATUS_FILE set to 'running'."
# - EOF ------------------------------------------------------------------------