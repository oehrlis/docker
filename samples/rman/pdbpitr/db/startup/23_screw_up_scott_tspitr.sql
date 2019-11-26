----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 23_screw_up_scott_tspitr.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.11.26
--  Revision..:  
--  Purpose...: Script to screw up the SCOTT schema
--  Notes.....:  
--  Reference.: SYS (or grant manually to a DBA)
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------
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

-- change pdb_db_name to upper case
COLUMN pdb_db_name NEW_VALUE pdb_db_name NOPRINT
SELECT upper('&pdb_db_name') pdb_db_name FROM dual;

-- Define PDB pdb_create_file_dest
COLUMN pdb_create_file_dest NEW_VALUE pdb_create_file_dest NOPRINT

-- alter the SQL*Plus environment
SET PAGESIZE 200 LINESIZE 160
SET FEEDBACK ON
SET ECHO OFF

---------------------------------------------------------------------------
-- set the current to PDB and run some updates
ALTER SESSION SET CONTAINER=&pdb_db_name;
UPDATE scott.emp SET ename='ERROR';
COMMIT;
UPDATE scott.tspitr SET info='After TSPITR,'||to_char(SYSDATE,'DD.MM.YYYY HH24:MI:SS');
COMMIT;

---------------------------------------------------------------------------
-- get pdb_create_file_dest
SELECT value pdb_create_file_dest FROM v$parameter WHERE name='db_create_file_dest';

---------------------------------------------------------------------------
-- spool output of scott.tspitr table to after_issue.txt
SPOOL &pdb_create_file_dest/after_issue.txt
SELECT info FROM scott.tspitr;
SPOOL OFF

UPDATE scott.emp SET ename=ename;
commit;
UPDATE scott.emp SET ename=ename;
---------------------------------------------------------------------------
-- change container to cdb$root and switch logfiles
ALTER SESSION SET CONTAINER=cdb$root;
ALTER SYSTEM SWITCH LOGFILE;
ALTER SYSTEM SWITCH LOGFILE;

---------------------------------------------------------------------------
-- set the current to PDB and run some dummy updates
ALTER SESSION SET CONTAINER=&pdb_db_name;
SET LINESIZE 160 PAGESIZE 200
SELECT * FROM scott.tspitr;
SELECT * FROM scott.emp;
EXIT;
-- EOF ---------------------------------------------------------------------