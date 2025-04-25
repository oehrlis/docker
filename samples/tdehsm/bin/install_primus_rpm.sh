#!/bin/bash
# ------------------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# ------------------------------------------------------------------------------
# Name.......: install_primus_rpm.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
# Editor.....: Stefan Oehrli
# Date.......: 2025.04.24
# Revision...: 0.2.0
# Purpose....: Copy and install the Securosys PKCS#11 Primus library into the container
# Notes......: Detects architecture and uses the matching RPM from config/hsm
# Reference..: https://github.com/oehrlis/docker
# License....: Apache License Version 2.0
# ------------------------------------------------------------------------------
# Modified...:
# 2025.04.24 oehrli - initial version
# 2025.04.24 oehrli - adjusted to run from any directory
# ------------------------------------------------------------------------------

# Resolve base directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

CONTAINER_NAME=tdehsm01
ARCH=$(docker exec $CONTAINER_NAME uname -m)

if [[ "$ARCH" == "aarch64" ]]; then
  RPM="$PROJECT_ROOT/config/hsm/PrimusAPI_PKCS11-X-2.3.4-rhel8-aarch64.rpm"
else
  RPM="$PROJECT_ROOT/config/hsm/PrimusAPI_PKCS11-X-2.3.4-rhel8-x86_64.rpm"
fi

echo "📦 Copying RPM to container ($CONTAINER_NAME)..."
docker cp "$RPM" "$CONTAINER_NAME:/tmp/primus.rpm"

echo "💡 Installing Primus PKCS#11 library inside container..."
docker exec -u root $CONTAINER_NAME rpm -ivh /tmp/primus.rpm

echo "✅ Installation complete. You may now configure sqlnet.ora for PKCS#11 access."
# - EOF ------------------------------------------------------------------------