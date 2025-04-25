#!/bin/bash
# ------------------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# ------------------------------------------------------------------------------
# Name.......: 33_create_tde_master.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
# Date.......: 2025.01.23
# Version....: v1.0.0
# Purpose....: Script to create SPFILE
# Notes......: --
# Reference..: --
# License....: Apache License Version 2.0
# ------------------------------------------------------------------------------
# Modified...:
# see git revision history with git log for more information on changes
# ------------------------------------------------------------------------------

# - Customization --------------------------------------------------------------
# - just add/update any kind of customized environment variable here
# - End of Customization -------------------------------------------------------

# - Default Values -------------------------------------------------------------
# - EOF Default Values ---------------------------------------------------------

# - configure instance ---------------------------------------------------------
echo "INFO: Copy orapw file of ${ORACLE_SID} from common folder:"
echo "INFO:   ORACLE_SID          :   ${ORACLE_SID}"
echo "INFO:   ORACLE_BASE         :   ${ORACLE_BASE}" 
echo "INFO:   ORACLE_HOME         :   ${ORACLE_HOME}"

unique_tag="initial after clone $(date +%Y%m%d%H%M%S)"
echo "INFO: run csenc_master.sql script"
${ORACLE_HOME}/bin/sqlplus -S -L /nolog <<EOFSQL
    connect / as sysdba
    COLUMN key_id NEW_VALUE key_id  NOPRINT
    ADMINISTER KEY MANAGEMENT CREATE KEY USING TAG '${unique_tag}' FORCE KEYSTORE IDENTIFIED BY EXTERNAL STORE WITH BACKUP;
    SELECT key_id FROM v\$encryption_keys WHERE tag='${unique_tag}';
    ADMINISTER KEY MANAGEMENT USE ENCRYPTION KEY '&key_id' FORCE KEYSTORE IDENTIFIED BY EXTERNAL STORE WITH BACKUP;
    @/u00/app/oracle/local/oradba/sql/ssenc_info.sql
    exit;
EOFSQL

# - EOF ------------------------------------------------------------------------
