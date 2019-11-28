----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 05_prepare_dbv_cdb.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.11.28
--  Revision..:  
--  Purpose...: prepare DBV in CDB
--  Notes.....:  
--  Reference.: SYS (or grant manually to a DBA)
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------
-- default values
DEFINE def_pdb_db_name      = "pdb1"
DEFINE def_pdb_admin_user   = "pdbadmin"
DEFINE def_pdb_admin_pwd    = "LAB01schulung"
-- Define the default values 
DEFINE pass=tvd_hr
DEFINE pass_sec=tvd_hr_sec;
DEFINE tbs=USERS
DEFINE ttbs=TEMP

-- define a default value for parameter if argument 1,2 or 3 is empty
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
COLUMN pdb_db_name NEW_VALUE pdb_db_name NOPRINT
SELECT upper('&pdb_db_name') pdb_db_name FROM dual;
-- define environment stuff
SET PAGESIZE 200 LINESIZE 160
SET FEEDBACK ON

-- connect as SYSDBA to the root container
CONNECT / as SYSDBA

-- set the current
ALTER SESSION SET CONTAINER=&pdb_db_name;
---------------------------------------------------------------------------
-- Grant the CREATE SESSION and SET CONTAINER privileges to the users for this PDB.
GRANT CREATE SESSION, SET CONTAINER TO c##sec_admin_owen CONTAINER = CURRENT;
GRANT CREATE SESSION, SET CONTAINER TO c##accts_admin_ace CONTAINER = CURRENT;

-- configure the two backup Database Vault user accounts.
BEGIN
    CONFIGURE_DV (
        dvowner_uname   => 'c##dbv_owner_root_backup',
        dvacctmgr_uname => 'c##dbv_acctmgr_root_backup');
 END;
/

-- enable DV
CONNECT c##dbv_owner_root_backup/&pdb_admin_pwd@&pdb_db_name
EXEC DBMS_MACADM.ENABLE_DV;

-- connect as SYSDBA to the root container
CONNECT / as SYSDBA
-- Restart PDB Database
ALTER PLUGGABLE DATABASE &pdb_db_name CLOSE IMMEDIATE;
ALTER PLUGGABLE DATABASE &pdb_db_name OPEN;

-- set the current
ALTER SESSION SET CONTAINER=&pdb_db_name;
SELECT * FROM DBA_DV_STATUS;

-- Connect as the backup DV_OWNER user and then grant the 
-- DV_OWNER role to the primary DV_OWNER user that you created earlier.
CONNECT c##dbv_owner_root_backup/&pdb_admin_pwd@&pdb_db_name
GRANT DV_OWNER TO c##sec_admin_owen WITH ADMIN OPTION;

-- Connect as the backup DV_ACCTMGR user and then grant the 
-- DV_ACCTMGR role to the backup DV_ACCTMGR user.
CONNECT c##dbv_acctmgr_root_backup/&pdb_admin_pwd@&pdb_db_name
GRANT DV_ACCTMGR TO c##accts_admin_ace WITH ADMIN OPTION;
CREATE USER secadmin IDENTIFIED BY &pdb_admin_pwd;
CREATE USER secacctmgr IDENTIFIED BY &pdb_admin_pwd;
GRANT DV_ACCTMGR TO secacctmgr WITH ADMIN OPTION;

CONNECT c##dbv_owner_root_backup/&pdb_admin_pwd@&pdb_db_name
GRANT DV_OWNER TO secadmin WITH ADMIN OPTION;

EXIT;
-- EOF ---------------------------------------------------------------------