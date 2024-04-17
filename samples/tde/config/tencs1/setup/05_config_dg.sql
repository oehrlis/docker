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
ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 GROUP 4 '/u01/oradata/TENCS1/standby_redog4m1TENCS1.dbf' SIZE 200M;
ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 GROUP 5 '/u01/oradata/TENCS1/standby_redog5m1TENCS1.dbf' SIZE 200M;
ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 GROUP 6 '/u01/oradata/TENCS1/standby_redog6m1TENCS1.dbf' SIZE 200M;
ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 GROUP 7 '/u01/oradata/TENCS1/standby_redog7m1TENCS1.dbf' SIZE 200M;
-- EOF ---------------------------------------------------------------------