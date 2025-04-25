#!/bin/bash
# ------------------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# ------------------------------------------------------------------------------
# Name.......: install_primus_rpm.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
# Editor.....: Stefan Oehrli
# Date.......: 2025.04.24
# Version....: v0.3.0
# Purpose....: Copy and install the Securosys PKCS#11 Primus library and useful tools into the container
# Notes......: Detects architecture and uses the matching RPM from config/hsm
# Reference..: https://github.com/oehrlis/docker
# License....: Apache License Version 2.0
# ------------------------------------------------------------------------------
# Modified...:
# 2025.04.24 oehrli - initial version
# 2025.04.24 oehrli - adjusted to run from any directory
# 2025.04.24 oehrli - extended to install pkcs11-tool and file
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

echo "🛠 Copying Primus PKCS#11 library for Oracle TDE..."
REAL_LIB=$(docker exec -u root $CONTAINER_NAME readlink -f /usr/local/primus/lib/libprimusP11.so)

docker exec -u root $CONTAINER_NAME bash -c "
  mkdir -p /opt/oracle/extapi/64/hsm/primus/2.3.4 &&
  cp '$REAL_LIB' /opt/oracle/extapi/64/hsm/primus/2.3.4/libprimusP11.so &&
  chown oracle:oinstall /opt/oracle/extapi/64/hsm/primus/2.3.4/libprimusP11.so
"

echo "🛠 Installing useful tools (file, pkcs11-tool)..."
docker exec -u root $CONTAINER_NAME bash -c "
  dnf -y install file opensc &&
  dnf -y clean all &&
  echo '✅ Tools installed: file, pkcs11-tool (via opensc)'
"

echo "✅ Installation complete. You may now configure sqlnet.ora for PKCS#11 access and use pkcs11-tool to inspect the token."
# - EOF ------------------------------------------------------------------------