----------------------------------------------------------------------------
--  Trivadis - Part of Accenture, Platform Factory - Data Platforms
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 00_config_db.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@accenture.com
--  Editor....: Stefan Oehrli
--  Date......: 2023.05.04
--  Revision..:  
--  Purpose...: Configure database parameter
--  Notes.....:  
--  Reference.: SYS (or grant manually to a DBA)
--  License...: Apache License Version 2.0, January 2004 as shown
--              at http://www.apache.org/licenses/
----------------------------------------------------------------------------
ALTER SYSTEM SET db_domain='trivadislabs.com' SCOPE=spfile;
ALTER SYSTEM SET LOG_ARCHIVE_CONFIG='DG_CONFIG=(tencs1,tencs2)';
ALTER SYSTEM SET LOG_ARCHIVE_DEST_1='LOCATION=USE_DB_RECOVERY_FILE_DEST';
ALTER SYSTEM SET LOG_ARCHIVE_DEST_2='SERVICE=tencs2 LGWR ASYNC VALID_FOR=(ONLINE_LOGFILE,PRIMARY_ROLE) DB_UNIQUE_NAME=tencs2';
ALTER SYSTEM SET LOG_ARCHIVE_DEST_STATE_1=ENABLE;
ALTER SYSTEM SET FAL_SERVER=tencs2;
ALTER SYSTEM SET FAL_CLIENT=tencs1;
ALTER SYSTEM SET DB_FILE_NAME_CONVERT='tencs2','tencs1','TENCS2','TENCS1' scope=spfile;
ALTER SYSTEM SET LOG_FILE_NAME_CONVERT='tencs2','tencs1','TENCS2','TENCS1' scope=spfile;
STARTUP FORCE;
-- EOF ---------------------------------------------------------------------