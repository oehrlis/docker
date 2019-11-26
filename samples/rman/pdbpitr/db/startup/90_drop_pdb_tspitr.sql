----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 90_drop_pdb_tspitr.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.11.25
--  Usage.....: @90_creat90_drop_pdb_tspitre_pdb_tspitr
--  Purpose...: Drop PDB (tspitr) used for PDB security engineering
--  Notes.....: 
--  Reference.: 
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
---------------------------------------------------------------------------
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

---------------------------------------------------------------------------
-- connect as SYSDBA to the root container
CONNECT / as SYSDBA
---------------------------------------------------------------------------
-- close PDB 
ALTER PLUGGABLE DATABASE &pdb_db_name CLOSE;
---------------------------------------------------------------------------
-- drop PDB 
DROP PLUGGABLE DATABASE &pdb_db_name INCLUDING DATAFILES;

EXIT;
-- EOF ---------------------------------------------------------------------