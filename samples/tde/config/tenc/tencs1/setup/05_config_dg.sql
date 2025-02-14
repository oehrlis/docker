--------------------------------------------------------------------------------
--  OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
--------------------------------------------------------------------------------
--  Name......: 00_config_db.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@accenture.com
--  Editor....: Stefan Oehrli
--  Date......: 2023.05.04
--  Revision..:  
--  Purpose...: Configure database parameter
--  Notes.....: SYS (or grant manually to a DBA)
--  Reference.: --
--  License...: Apache License Version 2.0
--------------------------------------------------------------------------------
ALTER SYSTEM SET standby_file_management=AUTO;
ALTER SYSTEM SET dg_broker_start=TRUE scope=both;
ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 GROUP 4 '/u01/oradata/TENCS1/standby_redog4m1TENCS1.dbf' SIZE 200M;
ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 GROUP 5 '/u01/oradata/TENCS1/standby_redog5m1TENCS1.dbf' SIZE 200M;
ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 GROUP 6 '/u01/oradata/TENCS1/standby_redog6m1TENCS1.dbf' SIZE 200M;
ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 GROUP 7 '/u01/oradata/TENCS1/standby_redog7m1TENCS1.dbf' SIZE 200M;
-- EOF -------------------------------------------------------------------------