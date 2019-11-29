----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 01_create_ts_users.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.11.25
--  Usage.....: @01_create_ts_users
--  Purpose...: Create a TS USERS
--  Notes.....: 
--  Reference.: 
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------

-- alter the SQL*Plus environment
SET PAGESIZE 200 LINESIZE 160
SET FEEDBACK ON
SET ECHO OFF

---------------------------------------------------------------------------
-- connect as SYSDBA to the root container
CONNECT / as SYSDBA

---------------------------------------------------------------------------
-- create a tablespace USERS
CREATE TABLESPACE users;

EXIT;
-- EOF ---------------------------------------------------------------------