#!/bin/bash
# -----------------------------------------------------------------------
# Trivadis AG, Business Development & Support (BDS)
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------
# Name.......: 06_add_pdb_os_user.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2019.02.20
# Revision...: --
# Purpose....: Script to add a PDB OS user.
# Notes......: --
# Reference..: https://github.com/oehrlis/oudbase
# License....: GPL-3.0+
# -----------------------------------------------------------------------
# Modified...:
# see git revision history with git log for more information on changes
# -----------------------------------------------------------------------

# - Customization -------------------------------------------------------
PDB_OS_USER=orapdb
PDB_OS_PASSWD=manager
PDB_OS_GRP=restricted
# - End of Customization ------------------------------------------------

# Make sure only root can run our script
if [ $EUID -ne 0 ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# if neccessary install the password utility
if [ -n "$(command -v passwd)" ]; then 
    echo "Found passwd utility"
else 
    echo "Install passwd and set password for ${PDB_OS_USER}:"
    yum install -y passwd
    yum clean all
    rm -rf /var/cache/yum
fi

# create OS group
echo "Add PDB OS group ${PDB_OS_GRP}:"
groupadd restricted

# create a bunch of OS user
for i in oracdb orapdb1 orapdb2 orapdb3; do
    PDB_OS_USER=${i}

    # - configure instance --------------------------------------------------
    echo "Add PDB OS User:"
    echo "  PDB_OS_USER         :   ${PDB_OS_USER}"
    echo "  PDB_OS_GRP          :   ${PDB_OS_GRP}"

    echo "Add PDB OS user ${PDB_OS_USER}:"
    useradd --create-home --gid restricted --shell /bin/bash ${PDB_OS_USER}
    echo "${PDB_OS_PASSWD}" | passwd ${PDB_OS_USER} --stdin 
done
# - EOF -----------------------------------------------------------------
