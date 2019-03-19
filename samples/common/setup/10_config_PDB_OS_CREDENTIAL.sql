----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 10_config_PDB_OS_CREDENTIAL.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.03.18
--  Revision..:  
--  Purpose...: Script to configure PDB_OS_CREDENTIAL
--  Notes.....:  
--  Reference.: SYS (or grant manually to a DBA)
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------
-- set the container to CDB$ROOT
ALTER SESSION SET CONTAINER=cdb$root;

-- Define a common credential
BEGIN
    dbms_credential.create_credential(
      credential_name => 'GENERIC_PDB_OS_USER',
      username => 'orapdb',
      password => 'manager');
END;
/

-- set the container to PDB1
ALTER SESSION SET CONTAINER=pdb1;

-- set PDB_OS_CREDENTIAL parameter
ALTER SYSTEM SET PDB_OS_CREDENTIAL=GENERIC_PDB_OS_USER SCOPE=SPFILE; 

-- restart database
startup force;

-- check parameter
conn / as sysdba
ALTER SESSION SET CONTAINER=pdb1;
show parameter PDB_OS_CREDENTIAL

-- create a directory exec_dir
host mkdir -p /u01/eng
CREATE OR REPLACE DIRECTORY exec_dir AS '/u01/eng'; 

-- create pre-processor script
host echo "/bin/id" >/u01/eng/run_id.sh
host chmod 755 /u01/eng/run_id.sh

-- create an external table
DROP TABLE id;
CREATE TABLE id (id VARCHAR2(2000)) 
  ORGANIZATION EXTERNAL( 
    TYPE ORACLE_LOADER 
    DEFAULT DIRECTORY exec_dir 
    ACCESS PARAMETERS( 
      RECORDS DELIMITED BY NEWLINE 
      PREPROCESSOR exec_dir:'run_id.sh') 
    LOCATION(exec_dir:'run_id.sh') 
  ); 

SELECT * FROM id;
-- EOF ---------------------------------------------------------------------
