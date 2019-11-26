----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 01_create_pdb_tspitr.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.11.25
--  Usage.....: @01_create_pdb_tspitr
--  Purpose...: Create a PDB (tspitr) used for PDB rman engineering
--  Notes.....: 
--  Reference.: 
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------

---------------------------------------------------------------------------
-- Define the default values 
DEFINE def_pdb_admin_user = "pdbadmin"
DEFINE def_pdb_admin_pwd  = "LAB01schulung"
DEFINE def_pdb_db_name    = "tspitr"

---------------------------------------------------------------------------
-- define default values for parameter if argument 1,2 or 3 is empty
-- Parameter 1 : pdb_db_name
-- Parameter 2 : pdb_admin_user
-- Parameter 3 : pdb_admin_pwd
SET FEEDBACK OFF
SET VERIFY OFF
COLUMN 1 NEW_VALUE 1 NOPRINT
COLUMN 2 NEW_VALUE 2 NOPRINT
COLUMN 3 NEW_VALUE 3 NOPRINT
SELECT '' "1" FROM dual WHERE ROWNUM = 0;
SELECT '' "2" FROM dual WHERE ROWNUM = 0;
SELECT '' "3" FROM dual WHERE ROWNUM = 0;
DEFINE pdb_db_name    = &1 &def_pdb_db_name
DEFINE pdb_admin_user = &2 &def_pdb_admin_user
DEFINE pdb_admin_pwd  = &3 &def_pdb_admin_pwd

-- change pdb_db_name to upper case
COLUMN pdb_db_name NEW_VALUE pdb_db_name NOPRINT
SELECT upper('&pdb_db_name') pdb_db_name FROM dual;

-- get a PDB path based on CDB datafile 1
COLUMN pdb_path NEW_VALUE pdb_path NOPRINT
SELECT substr(file_name, 1, instr(file_name, '/', -1, 1))||'&pdb_db_name' pdb_path 
    FROM dba_data_files WHERE file_id=1;

-- alter the SQL*Plus environment
SET PAGESIZE 200 LINESIZE 160
COL PROPERTY_NAME FOR A30
COL PROPERTY_VALUE FOR A30
SET FEEDBACK ON
SET ECHO OFF

---------------------------------------------------------------------------
-- connect as SYSDBA to the root container
CONNECT / as SYSDBA

---------------------------------------------------------------------------
-- create a PDB
CREATE PLUGGABLE DATABASE &pdb_db_name 
    ADMIN USER &pdb_admin_user IDENTIFIED BY &pdb_admin_pwd ROLES=(dba)
    PATH_PREFIX = '&pdb_path/directories/'
    CREATE_FILE_DEST = '&pdb_path';

---------------------------------------------------------------------------
-- open PDB 
ALTER PLUGGABLE DATABASE &pdb_db_name OPEN;

---------------------------------------------------------------------------
-- save state of PDB 
ALTER PLUGGABLE DATABASE &pdb_db_name SAVE STATE;

---------------------------------------------------------------------------
-- set the current PDB 
ALTER SESSION SET CONTAINER=&pdb_db_name;

---------------------------------------------------------------------------
-- create a tablespace USERS
CREATE TABLESPACE users;

---------------------------------------------------------------------------
-- select DB properties
SELECT property_name,property_value 
FROM database_properties 
WHERE PROPERTY_NAME='PATH_PREFIX' OR PROPERTY_NAME='DEFAULT_PERMANENT_TABLESPACE';

EXIT;
-- EOF ---------------------------------------------------------------------