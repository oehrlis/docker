#!/bin/bash
# ------------------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# ------------------------------------------------------------------------------
# Name.......: 90_demo_mode.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
# Editor.....: Stefan Oehrli
# Date.......: 2025.04.24
# Version....: v0.1.0
# Purpose....: Run demo SQLs automatically if DEMO_MODE is enabled
# Notes......: --
# Reference..: --
# License....: Apache License Version 2.0
# ------------------------------------------------------------------------------
# Modified...:
# 2025.04.24 oehrli - initial version
# see git revision history with git log for more information on changes
# ------------------------------------------------------------------------------

# - Customization --------------------------------------------------------------
# - just add/update any kind of customized environment variable here
DEMO_PAUSE=${DEMO_PAUSE:-true}  # Set to "false" to skip pauses
# - End of Customization -------------------------------------------------------

# - Default Values -------------------------------------------------------------
CURRENT_HOST=$(hostname)
# - EOF Default Values ---------------------------------------------------------

# - Functions ------------------------------------------------------------------
# Function: demo_pause
# Description: Function for conditional pause
demo_pause() {
  if [[ "${DEMO_PAUSE,,}" == "true" ]]; then
    read -p "⏸ Press [Enter] to continue..." _
  fi
}
# - EOF Functions --------------------------------------------------------------

# - Main Demo Logic ------------------------------------------------------------
if [[ "${DEMO_MODE^^}" == "TRUE" ]]; then
  echo "🔄 [DEMO_MODE] Running sample TDE setup and queries..."

  # Step 1: Show encryption wallet status
  echo "🧪 Step 1/4: Show TDE wallet and key configuration"
  sqlplus -s / as sysdba <<EOF
    @/u01/config/scripts/demo/ssenc_info.sql
    EXIT;
EOF
  demo_pause

  # Step 2: Create and encrypt a sample tablespace
  echo "🧪 Step 2/4: Create encrypted tablespace and user"
  sqlplus -s / as sysdba <<EOF
    @/u01/config/scripts/demo/demo_encrypt_sample.sql
    EXIT;
EOF
  demo_pause

  # Step 3: Run a query to verify encryption
  echo "🧪 Step 3/4: Verify encrypted tablespace and test data"
  sqlplus -s / as sysdba <<EOF
    SELECT tablespace_name, encrypted FROM dba_tablespaces WHERE encrypted = 'YES';
    SELECT username, default_tablespace FROM dba_users WHERE username = 'TDE_DEMO';
    EXIT;
EOF
  demo_pause

  # Step 4: Show available keys and wallet state again
  echo "🧪 Step 4/4: Recheck encryption keys after sample data load"
  sqlplus -s / as sysdba <<EOF
    @/u01/config/scripts/demo/ssenc_info.sql
    EXIT;
EOF
  demo_pause

  echo "✅ [DEMO_MODE] Demo complete — database encryption with HSM was tested successfully."

else
  echo "🔇 [DEMO_MODE] Skipping demo scripts. Set DEMO_MODE=TRUE to enable."
fi
# - EOF ------------------------------------------------------------------------