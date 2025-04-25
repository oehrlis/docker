#!/bin/bash
# ------------------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# ------------------------------------------------------------------------------
# Name.......: set_password.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
# Editor.....: Stefan Oehrli
# Date.......: 2025.04.24
# Version....: v0.2.0
# Purpose....: Set a password for SYS and SYSTEM users in the database container
# Notes......: If no password is provided, a random one is generated.
#              Password is stored in ORACLE_BASE/admin/$ORACLE_SID/etc/${ORACLE_SID}_password.txt
#              Environment is sourced from oraenv inside container
# Reference..: https://github.com/oehrlis/docker
# License....: Apache License Version 2.0
# ------------------------------------------------------------------------------
# Modified...:
# 2025.04.24 oehrli - initial version
# 2025.04.24 oehrli - added oraenv sourcing inside container
# ------------------------------------------------------------------------------

# Resolve base directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

CONTAINER_NAME=tdehsm01

# If a password is passed as argument, use it; otherwise generate one
if [[ -z "$1" ]]; then
  PASSWORD=$(openssl rand -base64 12 | tr -d /=+ | cut -c1-12)
  echo "🔐 No password provided. Generated random password: $PASSWORD"
else
  PASSWORD="$1"
  echo "🔐 Using provided password."
fi

# Get ORACLE_SID and ORACLE_BASE from the container
ORACLE_SID=$(docker exec -u oracle $CONTAINER_NAME bash -l -c "echo \$ORACLE_SID")
ORACLE_BASE=$(docker exec -u oracle $CONTAINER_NAME bash -l -c "echo \$ORACLE_BASE")

PASSWORD_FILE="$ORACLE_BASE/admin/$ORACLE_SID/etc/${ORACLE_SID}_password.txt"

echo "🔄 Setting password for SYS and SYSTEM in container [$CONTAINER_NAME]..."

docker exec -u oracle $CONTAINER_NAME bash -l -c "
  echo \"ALTER USER SYS IDENTIFIED BY \\\"$PASSWORD\\\";\" | sqlplus -s / as sysdba
  echo \"ALTER USER SYSTEM IDENTIFIED BY \\\"$PASSWORD\\\";\" | sqlplus -s / as sysdba
"

echo "💾 Saving password to $PASSWORD_FILE..."

docker exec -u oracle $CONTAINER_NAME bash -l -c "
  mkdir -p \"$ORACLE_BASE/admin/$ORACLE_SID/etc\" &&
  echo \"SYS/SYSTEM password: $PASSWORD\" > \"$PASSWORD_FILE\" &&
  echo \"SYS/SYSTEM password: $PASSWORD\" > \"/u01/config/etc/${ORACLE_SID}_password.txt\" &&
  chmod 600 \"$PASSWORD_FILE\"
"

echo "✅ Password updated and saved securely to container."
# - EOF ------------------------------------------------------------------------
