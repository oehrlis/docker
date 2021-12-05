#!/bin/bash
# -----------------------------------------------------------------------
# Trivadis AG, Business Development & Support (BDS)
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------
# Name.......: 03_add_tnsnames.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2018.06.27
# Revision...: --
# Purpose....: Script to configure the EUS for Database.
# Notes......: --
# Reference..: https://github.com/oehrlis/oudbase
# License....: Apache License Version 2.0, January 2004 as shown
#              at http://www.apache.org/licenses/
# -----------------------------------------------------------------------
# Modified...:
# see git revision history with git log for more information on changes
# -----------------------------------------------------------------------
export CATALOG_HOST=${CATALOG_HOST:-"catalog.trivadislabs.com"}
export CATALOG_SID=${CATALOG_SID:-"TDB184R"}

echo "catalog= 
    (DESCRIPTION = 
        (ADDRESS = (PROTOCOL = TCP)(HOST=${CATALOG_HOST})(PORT = 1521))
            (CONNECT_DATA =
                (SERVER = DEDICATED)
            (SERVICE_NAME = ${CATALOG_SID})
        )
    )" >> ${TNS_ADMIN}/tnsnames.ora
# - EOF -----------------------------------------------------------------
