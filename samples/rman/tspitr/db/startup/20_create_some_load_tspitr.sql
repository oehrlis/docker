----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 20_create_some_load_tspitr.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.11.26
--  Revision..:  
--  Purpose...: Script to create some load on scott.emp
--  Notes.....:  
--  Reference.: SYS (or grant manually to a DBA)
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------
CONNECT / as SYSDBA
-- Define the default values 
DEFINE def_pdb_db_name    = "tspitr"

---------------------------------------------------------------------------
-- define default value for parameter if argument 1 is empty
-- Parameter 1 : pdb_db_name
SET FEEDBACK OFF
SET VERIFY OFF
COLUMN 1 NEW_VALUE 1 NOPRINT
SELECT '' "1" FROM dual WHERE ROWNUM = 0;
DEFINE pdb_db_name    = &1 &def_pdb_db_name

-- alter the SQL*Plus environment
SET PAGESIZE 200 LINESIZE 160
SET FEEDBACK ON
SET ECHO OFF

-- connect as SYSDBA to the root container
CONNECT / as SYSDBA

---------------------------------------------------------------------------
-- set the current to PDB and run some dummy updates
ALTER SESSION SET CONTAINER=&pdb_db_name;
UPDATE scott.emp SET ename=ename;
COMMIT;
UPDATE scott.emp SET ename=ename;
COMMIT;

---------------------------------------------------------------------------
-- change container to cdb$root and switch logfiles
ALTER SESSION SET CONTAINER=cdb$root;
ALTER SYSTEM SWITCH LOGFILE;
ALTER SYSTEM SWITCH LOGFILE;
ALTER SYSTEM SWITCH LOGFILE;

---------------------------------------------------------------------------
-- set the current to PDB and run some dummy updates
ALTER SESSION SET CONTAINER=&pdb_db_name;
UPDATE scott.emp SET ename=ename;
COMMIT;

---------------------------------------------------------------------------
-- change container to cdb$root and switch logfiles
ALTER SESSION SET CONTAINER=cdb$root;
ALTER SYSTEM SWITCH LOGFILE;
ALTER SYSTEM SWITCH LOGFILE;

---------------------------------------------------------------------------
-- set the current to PDB and run some dummy updates
ALTER SESSION SET CONTAINER=&pdb_db_name;
UPDATE scott.emp SET ename=ename;
COMMIT;
UPDATE scott.emp SET ename=ename;
COMMIT;

---------------------------------------------------------------------------
-- change container to cdb$root and switch logfiles
ALTER SESSION SET CONTAINER=cdb$root;
ALTER SYSTEM SWITCH LOGFILE;
COMMIT;
ALTER SYSTEM SWITCH LOGFILE;
ALTER SYSTEM SWITCH LOGFILE;
EXIT;
-- EOF ---------------------------------------------------------------------