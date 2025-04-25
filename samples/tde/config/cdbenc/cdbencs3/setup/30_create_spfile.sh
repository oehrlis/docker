#!/bin/bash
# ------------------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# ------------------------------------------------------------------------------
# Name.......: 30_create_spfile.sh
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
ORACLE_SID_SRC="CDBENCS1"
ORACLE_SID_DST=$ORACLE_SID
# - End of Customization -------------------------------------------------------

# - Default Values -------------------------------------------------------------
# - EOF Default Values ---------------------------------------------------------

# - configure instance ---------------------------------------------------------
echo "INFO: Copy orapw file of ${ORACLE_SID} from common folder:"
echo "INFO:   ORACLE_SID          :   ${ORACLE_SID}"
echo "INFO:   ORACLE_BASE         :   ${ORACLE_BASE}" 
echo "INFO:   ORACLE_HOME         :   ${ORACLE_HOME}"
echo "INFO:   ORACLE_SID_SRC      :   ${ORACLE_SID_SRC}"
echo "INFO:   ORACLE_SID_DST      :   ${ORACLE_SID_DST}"

mkdir -pv /u01/oradata/${ORACLE_SID}
mkdir -pv /u01/fast_recovery_area/${ORACLE_SID}

echo "INFO: Create pfile ${ORACLE_BASE}/admin/${ORACLE_SID_DST}/pfile/init${ORACLE_SID_DST}.ora"
cat <<EOF > ${ORACLE_BASE}/admin/${ORACLE_SID_DST}/pfile/init${ORACLE_SID_DST}.ora
*.audit_file_dest='/u00/app/oracle/admin/${ORACLE_SID_DST}/adump'
*.audit_trail='db','extended'
*.compatible='19.0.0'
*.control_files='/u01/oradata/${ORACLE_SID_DST}/control01${ORACLE_SID_DST}.dbf','/u01/fast_recovery_area/${ORACLE_SID_DST}/CDBENC/control02${ORACLE_SID_DST}.dbf'
*.db_block_size=8192
*.db_domain='trivadislabs.com'
*.db_file_name_convert='${ORACLE_SID_SRC,,}','${ORACLE_SID_DST,,}','${ORACLE_SID_SRC}','${ORACLE_SID_DST}'
*.db_name='CDBENC'
*.db_recovery_file_dest='/u01/fast_recovery_area/${ORACLE_SID_DST}'
*.db_recovery_file_dest_size=6400m
*.db_unique_name='${ORACLE_SID_DST}'
*.dg_broker_start=TRUE
*.diagnostic_dest='/u00/app/oracle'
*.dispatchers='(PROTOCOL=TCP) (SERVICE=${ORACLE_SID_DST}XDB)'
*.fal_client='${ORACLE_SID_DST}'
*.fal_server=''
*.local_listener=''
*.log_archive_config='DG_CONFIG=(${ORACLE_SID_DST,,},${ORACLE_SID_SRC,,})'
*.log_archive_dest_1='LOCATION=USE_DB_RECOVERY_FILE_DEST'
*.log_archive_dest_2='service="${ORACLE_SID_SRC,,}"','ASYNC NOAFFIRM delay=0 optional compression=disable max_failure=0 reopen=300 db_unique_name="${ORACLE_SID_SRC}" net_timeout=30','valid_for=(online_logfile,all_roles)'
*.log_archive_dest_state_1='ENABLE'
*.log_archive_dest_state_2='ENABLE'
*.log_archive_format='%t_%s_%r.dbf'
*.log_file_name_convert='${ORACLE_SID_SRC,,}','${ORACLE_SID_DST,,}','${ORACLE_SID_SRC}','${ORACLE_SID_DST}'
*.nls_language='AMERICAN'
*.nls_territory='AMERICA'
*.open_cursors=300
*.pga_aggregate_target=256m
*.processes=300
*.remote_login_passwordfile='EXCLUSIVE'
*.sga_target=768m
*.standby_file_management='AUTO'
*.tde_configuration='KEYSTORE_CONFIGURATION=FILE'
*.undo_tablespace='UNDOTBS1'
*.wallet_root='/u00/app/oracle/admin/${ORACLE_SID_DST}/wallet'
EOF

echo "INFO: Create spfile from pfile ${ORACLE_BASE}/admin/${ORACLE_SID_DST}/pfile/init${ORACLE_SID_DST}.ora"
${ORACLE_HOME}/bin/sqlplus -S -L /nolog <<EOFSQL
    connect / as sysdba
    create spfile='${ORACLE_BASE}/admin/${ORACLE_SID_DST}/pfile/spfile${ORACLE_SID_DST}.ora' from pfile='${ORACLE_BASE}/admin/${ORACLE_SID_DST}/pfile/init${ORACLE_SID_DST}.ora';
EOFSQL

echo "INFO: Create spfile link in ${ORACLE_HOME}/dbs"
ln -sf ${ORACLE_BASE}/admin/${ORACLE_SID_DST}/pfile/spfile${ORACLE_SID_DST}.ora ${ORACLE_HOME}/dbs/spfile${ORACLE_SID_DST}.ora

echo "INFO: Startup database ${ORACLE_SID_DST} in nomount mode"
${ORACLE_HOME}/bin/sqlplus -S -L /nolog <<EOFSQL
    connect / as sysdba
    startup force nomount;
    exit;
EOFSQL
# - EOF ------------------------------------------------------------------------
