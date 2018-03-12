#!/bin/bash
# ----------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ----------------------------------------------------------------------
# Name.......: setup_tvd.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2017.09.22
# Revision...: 
# Purpose....: Setup script for docker base image 
# Notes......: --
# Reference..: --
# License....: CDDL 1.0 + GPL 2.0
# ----------------------------------------------------------------------
# Modified...: 
# see git revision history for more information on changes/updates
# TODO.......: 
# ----------------------------------------------------------------------

# ignore secure linux (not available on slim linux

# define environment variables
export ORACLE_ROOT=/u00             # oracle root directory
export ORACLE_DATA=/u01             # oracle data directory
export ORACLE_BASE=/u00/app/oracle  # oracle base directory

# create oracle groups
groupadd --gid 1000 oinstall
groupadd --gid 1010 osdba
groupadd --gid 1020 osoper
groupadd --gid 1030 osbackupdba
groupadd --gid 1040 oskmdba
groupadd --gid 1050 osdgdba

# create oracle user
useradd --create-home --gid oinstall --shell /bin/bash \
    --groups oinstall,osdba,osoper,osbackupdba,osdgdba,oskmdba \
    oracle

# remove the copies of the group and password files
rm /etc/group- /etc/gshadow- /etc/passwd- /etc/shadow-

echo "--- Create OFA directory structure"
# create oracle directories
install --owner oracle --group oinstall --mode=775 --verbose --directory \
    ${ORACLE_ROOT} \
    ${ORACLE_DATA} \
    ${ORACLE_BASE}/etc \
    ${ORACLE_BASE}/network \
    ${ORACLE_BASE}/network/admin \
    ${ORACLE_BASE}/local \
    ${ORACLE_BASE}/product

# limit locale to the different english languages
echo "%_install_langs   en_US" >/etc/rpm/macros.lang

# update existing packages
yum upgrade -y

# clean up
yum clean all
rm -rf /var/cache/yum