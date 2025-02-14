--------------------------------------------------------------------------------
--  OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
--------------------------------------------------------------------------------
--  Name......: 13_restart_db.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@accenture.com
--  Editor....: Stefan Oehrli
--  Date......: 2025.01.17
--  Version...: v1.0.0
--  Purpose...: Configure database parameter for dataguard
--  Notes.....:  
--  Reference.: SYS (or grant manually to a DBA)
--  License...: Apache License Version 2.0
--------------------------------------------------------------------------------
ALTER SYSTEM SET standby_file_management=AUTO;
ALTER SYSTEM SET dg_broker_start=TRUE scope=both;
ALTER SYSTEM RESET log_archive_dest_2 scope=both;
STARTUP FORCE MOUNT;
-- EOF -------------------------------------------------------------------------