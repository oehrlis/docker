----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 10_common_audit_issue.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.03.18
--  Revision..:  
--  Purpose...: Script test common audit issue
--  Notes.....:  
--  Reference.: SYS (or grant manually to a DBA)
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------
set serveroutput on
set linesize 180 pagesize 200
col USER_NAME for a20
col POLICY_NAME for a30
col ENTITY_NAME for a40
col EVENT_TIMESTAMP for a30 
col OS_USERNAME for a11
col DBUSERNAME for a10
col ACTION_NAME for a25
col RETURN_CODE for 999999999999
col SYSTEM_PRIVILEGE_USED for a20
col UNIFIED_AUDIT_POLICIES for a40

-- remove current audit policies
DOC 
# disable and remove audit policies except the oracle default
#

set heading off
set feedback off
set echo off
SET termout off
spool /tmp/noaudit.sql
SELECT 'NOAUDIT POLICY '||policy_name||';' FROM audit_unified_enabled_policies WHERE entity_name='ALL USERS';
SELECT 'NOAUDIT POLICY '||policy_name||' BY '||entity_name||';' FROM audit_unified_enabled_policies WHERE entity_name<>'ALL USERS';
SELECT DISTINCT 'DROP AUDIT POLICY '||policy_name||';' FROM audit_unified_policies WHERE policy_name NOT LIKE 'ORA_%';
ALTER SESSION SET CONTAINER="PDB1";
SELECT 'ALTER SESSION SET CONTAINER="PDB1";' FROM DUAL;
SELECT 'NOAUDIT POLICY '||policy_name||';' FROM audit_unified_enabled_policies WHERE entity_name='ALL USERS';
SELECT 'NOAUDIT POLICY '||policy_name||' BY '||entity_name||';' FROM audit_unified_enabled_policies WHERE entity_name<>'ALL USERS';
SELECT DISTINCT 'DROP AUDIT POLICY '||policy_name||';' FROM audit_unified_policies WHERE policy_name NOT LIKE 'ORA_%';
ALTER SESSION SET CONTAINER="PDB2";
SELECT 'ALTER SESSION SET CONTAINER="PDB2";' FROM DUAL;
SELECT 'NOAUDIT POLICY '||policy_name||';' FROM audit_unified_enabled_policies WHERE entity_name='ALL USERS';
SELECT 'NOAUDIT POLICY '||policy_name||' BY '||entity_name||';' FROM audit_unified_enabled_policies WHERE entity_name<>'ALL USERS';
SELECT DISTINCT 'DROP AUDIT POLICY '||policy_name||';' FROM audit_unified_policies WHERE policy_name NOT LIKE 'ORA_%';
ALTER SESSION SET CONTAINER="CDB$ROOT";
SELECT 'ALTER SESSION SET CONTAINER="CDB$ROOT";' FROM DUAL;
spool off
set heading on
set feedback on
set echo on
SET termout on
SET verify on
@/tmp/noaudit.sql

-- create common user
DECLARE
  vcount INTEGER :=0;
BEGIN
  SELECT count(1) INTO vcount FROM dba_users WHERE username = 'C##TEST';
  IF vcount != 0 THEN
    EXECUTE IMMEDIATE ('DROP USER C##TEST CASCADE');
  END IF;
END;
/

CREATE USER c##test IDENTIFIED BY manager CONTAINER=ALL QUOTA UNLIMITED ON users;
GRANT CREATE SESSION TO c##test  CONTAINER=ALL;
GRANT CREATE TABLE TO c##test CONTAINER=ALL;
GRANT RESOURCE TO c##test CONTAINER=ALL;

SELECT parameter,value FROM v$option WHERE parameter LIKE 'Unified Auditing';

-- purge audit trail
DOC 
# purge audit trail
#
ALTER SESSION SET CONTAINER=cdb$root;
BEGIN
  dbms_audit_mgmt.clean_audit_trail(
    audit_trail_type => dbms_audit_mgmt.audit_trail_unified,
    container => dbms_audit_mgmt.container_all,
    use_last_arch_timestamp => false);
END;
/  

-- create common audit policies
DOC 
# create common audit policies
#
ALTER SESSION SET CONTAINER=cdb$root;
CREATE AUDIT POLICY tvd_create_table_all ACTIONS CREATE TABLE, DROP TABLE container=all;
CREATE AUDIT POLICY tvd_logon_all ACTIONS LOGON, LOGOFF container=all;
AUDIT POLICY tvd_create_table_all;
AUDIT POLICY tvd_logon_all;
SELECT * FROM audit_unified_enabled_policies;

-- create local audit policy in pdb1
DOC 
# create local audit policy in pdb1
#
ALTER SESSION SET CONTAINER=pdb1;
CREATE AUDIT POLICY tvd_logon_pdb1 ACTIONS LOGON, LOGOFF;
AUDIT POLICY tvd_logon_pdb1;
SELECT * FROM audit_unified_enabled_policies;

-- create local audit policy in pdb2
DOC 
# review audit policy in pdb2
#
ALTER SESSION SET CONTAINER=pdb2;
SELECT * FROM audit_unified_enabled_policies;

-- connect to PDB1
DOC 
# connect to PDB1 wrong / correct password and create a table
#
conn scott/wrong@localhost:1521/PDB1

conn scott/tiger@localhost:1521/PDB1

CREATE TABLE test AS SELECT SYSDATE "DATE" FROM DUAL;
COMMIT;
DROP TABLE test;
COMMIT;

-- connect to PDB2
DOC 
# connect to PDB2 wrong / correct password and create a table
#
conn scott/wrong@localhost:1521/PDB2

conn scott/tiger@localhost:1521/PDB2

CREATE TABLE test AS SELECT SYSDATE "DATE" FROM DUAL;
COMMIT;
DROP TABLE test;
COMMIT;

-- connect to CDB
DOC 
# connect to CDB wrong / correct password and create a table
#
conn c##test/wrong@localhost:1521/TMOBI01

conn c##test/manager@localhost:1521/TMOBI01

CREATE TABLE test AS SELECT SYSDATE "DATE" FROM DUAL;
COMMIT;
DROP TABLE test;
COMMIT;

-- review audit via CDB
DOC 
# -- review audit via CDB
#
conn / as sysdba

select CON_ID, NAME, OPEN_MODE from v$pdbs;
SELECT event_timestamp,con_id,os_username,dbusername,action_name,return_code,system_privilege_used,unified_audit_policies 
FROM cdb_unified_audit_trail 
ORDER BY event_timestamp;
