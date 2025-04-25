#!/bin/bash
# ------------------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# ------------------------------------------------------------------------------
# Name.......: 10_wait_for_cdbencs1.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
# Date.......: 2025.01.17
# Version....: v1.0.0
# Purpose....: Wait for WAIT_FOR_HOST to complete configuration
# Notes......: Dynamically determines host to wait for based on script name
# Reference..: --
# License....: Apache License Version 2.0
# ------------------------------------------------------------------------------
# Modified...:
# see git revision history with git log for more information on changes
# ------------------------------------------------------------------------------

# - Customization --------------------------------------------------------------
# - just add/update any kind of customized environment variable here
EXPECTED_HOST="cdbencs3"
WAIT_FOR_HOST="cdbencs1"
CURRENT_HOST=$(hostname)
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

# Variables
COMMON_DIR="/u01/shared"
STATUS_FILE="${COMMON_DIR}/${WAIT_FOR_HOST}_status"
WAIT_TIME=15  # Time in seconds to wait between checks

echo "INFO: Waiting for ${WAIT_FOR_HOST} to complete configuration..."

# Loop until the lock file indicates "done"
while true; do
    if [[ -f "$STATUS_FILE" ]]; then
        STATUS=$(cat "$STATUS_FILE")
        if [[ "$STATUS" == "done" ]]; then
            echo "INFO: ${WAIT_FOR_HOST} Configuration is complete. Proceeding..."
            break
        elif [[ "$STATUS" == "running" ]]; then
            echo "INFO: ${WAIT_FOR_HOST} Still configuring. Waiting ${WAIT_TIME}s ..."
        else
            echo "INFO: ${WAIT_FOR_HOST} Unknown status in lock file. Exiting."
            exit 1
        fi
    else
        echo "INFO: ${WAIT_FOR_HOST} Lock file not found. Waiting ${WAIT_TIME}s ..."
    fi
    sleep $WAIT_TIME
done

# Simulate configuration tasks for this host
echo "Starting configuration for this host..."
# --- EOF ----------------------------------------------------------------------