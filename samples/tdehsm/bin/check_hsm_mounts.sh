#!/bin/bash
# ------------------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# ------------------------------------------------------------------------------
# Name.......: check_hsm_mounts.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
# Editor.....: Stefan Oehrli
# Date.......: 2025.04.24
# Revision...: 0.2
# Purpose....: Check for required HSM config files before starting the container
# Notes......: Verifies presence of primus.cfg and .secrets.cfg in config/hsm
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

echo "🔍 Checking HSM configuration files in $PROJECT_ROOT/config/hsm..."

for file in primus.cfg .secrets.cfg; do
  if [[ ! -f "$PROJECT_ROOT/config/hsm/$file" ]]; then
    echo "❌ Missing required file: config/hsm/$file"
    exit 1
  fi
done

echo "✅ All HSM files present. Ready to launch container."
# - EOF ------------------------------------------------------------------------