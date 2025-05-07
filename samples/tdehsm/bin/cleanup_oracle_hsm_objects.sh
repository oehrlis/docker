#!/bin/bash
# ------------------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# ------------------------------------------------------------------------------
# Name.......: cleanup_oracle_hsm_objects.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
# Editor.....: Stefan Oehrli
# Date.......: 2025.05.05
# Version....: v0.2.0
# Purpose....: Cleanup Oracle HSM key material using pkcs11-tool in a container
# Notes......: Removes Oracle-related data and secret key objects from PKCS#11 token
# Reference..: https://github.com/oehrlis/docker
# License....: Apache License Version 2.0
# ------------------------------------------------------------------------------
# Modified...:
# 2025.05.05 oehrli - initial version based on install_primus_rpm.sh template
# 2025.05.05 oehrli - adjusted to require PIN as command-line parameter
# ------------------------------------------------------------------------------

# Resolve base directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Configuration
CONTAINER_NAME="tdehsm01"
MODULE="/opt/oracle/extapi/64/hsm/primus/2.3.4/libprimusP11.so"

# Check for PIN parameter
if [[ -z "$1" ]]; then
  echo "❌ ERROR: PIN is required as the first argument."
  echo "Usage: $0 <PIN>"
  exit 1
fi

PIN="$1"

echo "🔐 Fetching list of PKCS#11 objects from container $CONTAINER_NAME..."
OBJECTS_OUTPUT=$(docker exec -u oracle "$CONTAINER_NAME" pkcs11-tool --module "$MODULE" --login --list-objects --pin "$PIN")

# Function to delete a given object by label and type
delete_object() {
  local label="$1"
  local type="$2"
  echo "🗑 Deleting object: $label (type: $type)"
  docker exec -u oracle "$CONTAINER_NAME" pkcs11-tool --module "$MODULE" --login --pin "$PIN" --label "$label" --type "$type" --delete-object
}

# Read and parse each label
while read -r line; do
  if [[ "$line" =~ label:\ *\'([^\']+)\' ]]; then
    label="${BASH_REMATCH[1]}"

    if [[ "$label" =~ ^ORACLE\.SECURITY\.KM\.ENCRYPTION\. ]]; then
      delete_object "$label" data
    elif [[ "$label" =~ ^ORACLE\.TDE\.HSM\.MK\. ]]; then
      delete_object "$label" secrkey
    elif [[ "$label" == "DATA_OBJECT_SUPPORTED_IDEN" ]]; then
      delete_object "$label" data
    fi
  fi
done <<< "$OBJECTS_OUTPUT"

echo "🔐 list of PKCS#11 objects from container $CONTAINER_NAME..."
docker exec -u oracle "$CONTAINER_NAME" pkcs11-tool --module "$MODULE" --login --list-objects --pin "$PIN"

echo "✅ HSM cleanup complete."
# - EOF ------------------------------------------------------------------------
