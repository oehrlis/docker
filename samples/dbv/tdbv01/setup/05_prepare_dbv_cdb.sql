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
-- Define the default values 
DEFINE def_dbv_password    = "LAB01schulung"

---------------------------------------------------------------------------
-- define default value for parameter if argument 1 is empty
-- Parameter 1 : pdb_db_name
SET FEEDBACK OFF
SET VERIFY OFF
COLUMN 1 NEW_VALUE 1 NOPRINT
SELECT '' "1" FROM dual WHERE ROWNUM = 0;
DEFINE dbv_password    = &1 &def_dbv_password
-- define environment stuff
SET PAGESIZE 200 LINESIZE 160
SET FEEDBACK ON
-- connect as SYSDBA to the root container
CONNECT / as SYSDBA

---------------------------------------------------------------------------
-- CREATE DV Users
GRANT CREATE SESSION, SET CONTAINER TO c##sec_admin IDENTIFIED BY &dbv_password CONTAINER = ALL;
GRANT CREATE SESSION, SET CONTAINER TO c##sec_accts_admin IDENTIFIED BY &dbv_password CONTAINER = ALL;
GRANT CREATE SESSION, SET CONTAINER TO c##dbv_acctmgr_root_backup IDENTIFIED BY &dbv_password CONTAINER = ALL;
GRANT CREATE SESSION, SET CONTAINER TO c##dbv_owner_root_backup IDENTIFIED BY &dbv_password CONTAINER = ALL;

-- configure the DV users
BEGIN
    CONFIGURE_DV (
        dvowner_uname         => 'c##dbv_owner_root_backup',
        dvacctmgr_uname       => 'c##dbv_acctmgr_root_backup',
        force_local_dvowner   => FALSE);
END;
/

-- enable DV
CONNECT c##dbv_owner_root_backup/&dbv_password
EXEC DBMS_MACADM.ENABLE_DV;

-- Restart Database
CONNECT / AS SYSDBA
SHUTDOWN IMMEDIATE
STARTUP

-- DV Status
SET LINESIZE 160 PAGESIZE 200
COL description FOR a40
SELECT * FROM DBA_DV_STATUS;
SELECT * FROM DBA_OLS_STATUS;
SELECT * FROM CDB_DV_STATUS;
-- SELECT * FROM CDB_OLS_STATUS;

-- Connect as the backup DV_OWNER user and then grant the 
-- DV_OWNER role to the primary DV_OWNER user that you created earlier.
CONNECT c##dbv_owner_root_backup/&dbv_password
GRANT DV_OWNER TO c##sec_admin WITH ADMIN OPTION;

-- Connect as the backup DV_ACCTMGR user and then grant the 
-- DV_ACCTMGR role to the backup DV_ACCTMGR user.
CONNECT c##dbv_acctmgr_root_backup/&dbv_password
GRANT DV_ACCTMGR TO c##sec_accts_admin WITH ADMIN OPTION;

EXIT;
-- EOF ---------------------------------------------------------------------