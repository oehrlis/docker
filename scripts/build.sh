#!/bin/bash
# -----------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------------
# Name.......: build.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: 
# Date.......: 
# Revision...: 
# Purpose....: Build script for docker image 
# Notes......: --
# Reference..: --
# License....: CDDL 1.0 + GPL 2.0
# -----------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# TODO.......:
# -----------------------------------------------------------------------------
DOCKERFILE="$(dirname $0)/../Dockerfile"
DOCKERDIR="$(dirname $0)/.."
docker build -t oehrlis/odsee -f "${DOCKERFILE}" "${DOCKERDIR}"