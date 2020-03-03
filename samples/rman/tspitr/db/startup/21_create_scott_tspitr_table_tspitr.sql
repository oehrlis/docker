----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 21_create_scott_tspitr_table_tspitr.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.11.26
--  Revision..:  
--  Purpose...: Script to create a SCOTT TSPITR table
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

-- Define PDB pdb_create_file_dest
COLUMN pdb_create_file_dest NEW_VALUE pdb_create_file_dest NOPRINT

-- alter the SQL*Plus environment
SET PAGESIZE 200 LINESIZE 160
SET FEEDBACK ON
SET ECHO OFF

-- connect as SYSDBA to the root container
CONNECT / as SYSDBA

---------------------------------------------------------------------------
-- Remove scott.tspitr tabel if it already exists
ALTER SESSION SET CONTAINER=&pdb_db_name;
DECLARE
    vcount INTEGER :=0;
BEGIN
    SELECT count(1) INTO vcount FROM dba_tables WHERE table_name = 'TSPITR' and OWNER='SCOTT';
    IF vcount != 0 THEN
        EXECUTE IMMEDIATE ('DROP TABLE scott.tspitr');
    END IF;
END;
/

---------------------------------------------------------------------------
-- get pdb_create_file_dest
SELECT value pdb_create_file_dest FROM v$parameter WHERE name='db_create_file_dest';

---------------------------------------------------------------------------
-- create scott.tspitr table
CREATE TABLE scott.tspitr AS SELECT 'before TSPITR,'||to_char(SYSDATE,'DD.MM.YYYY HH24:MI:SS') info FROM DUAL;
COMMIT;

---------------------------------------------------------------------------
-- spool output of scott.tspitr table to before_issue.txt
SET FEEDBACK OFF
SET HEADING OFF
SPOOL &pdb_create_file_dest/before_issue.txt
SELECT 'before TSPITR,'||to_char(SYSDATE,'DD.MM.YYYY HH24:MI:SS') FROM DUAL;
SPOOL OFF;

EXIT;
-- EOF ---------------------------------------------------------------------