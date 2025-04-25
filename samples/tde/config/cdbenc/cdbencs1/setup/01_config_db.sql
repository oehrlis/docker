--------------------------------------------------------------------------------
--  OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
--------------------------------------------------------------------------------
--  Name......: 00_config_db.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@accenture.com
--  Editor....: Stefan Oehrli
--  Date......: 2025.01.17
--  Version...: v1.0.0
--  Purpose...: Configure basic database parameter
--  Notes.....: SYS (or grant manually to a DBA)
--  Reference.: --
--  License...: Apache License Version 2.0
--------------------------------------------------------------------------------
ALTER SYSTEM SET db_domain='trivadislabs.com' SCOPE=spfile;
ALTER SYSTEM SET LOG_ARCHIVE_CONFIG='DG_CONFIG=(cdbencs1,cdbencs2)';
ALTER SYSTEM SET LOG_ARCHIVE_DEST_1='LOCATION=USE_DB_RECOVERY_FILE_DEST';
ALTER SYSTEM SET LOG_ARCHIVE_DEST_STATE_1=ENABLE;
ALTER SYSTEM SET FAL_SERVER='CDBENCS2';
ALTER SYSTEM SET FAL_CLIENT='CDBENCS1';
ALTER SYSTEM SET DB_FILE_NAME_CONVERT='cdbencs2','cdbencs1','CDBENCS2','CDBENCS1' scope=spfile;
ALTER SYSTEM SET LOG_FILE_NAME_CONVERT='cdbencs2','cdbencs1','CDBENCS2','CDBENCS1' scope=spfile;
STARTUP FORCE;
-- EOF -------------------------------------------------------------------------