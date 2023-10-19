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

set linesize 180 pagesize 200
set feedback on
set echo on
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

-- create common user
DROP USER c##test cascade;
CREATE USER c##test IDENTIFIED BY manager CONTAINER=ALL QUOTA UNLIMITED ON users;
GRANT CREATE SESSION TO c##test  CONTAINER=ALL;
GRANT CREATE TABLE TO c##test CONTAINER=ALL;
GRANT RESOURCE TO c##test CONTAINER=ALL;

SELECT parameter,value FROM v$option WHERE parameter LIKE 'Unified Auditing';

-- disable all default audit policies
DOC 
# disable all default audit policies
#
ALTER SESSION SET CONTAINER=cdb$root;
NOAUDIT POLICY ora_secureconfig;
NOAUDIT POLICY ora_logon_failures;
NOAUDIT POLICY tvd_logon_all;
DROP AUDIT POLICY tvd_logon_all;
SELECT * FROM audit_unified_enabled_policies;

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
CREATE AUDIT POLICY tvd_logon_all ACTIONS LOGON, LOGOFF container=all;
AUDIT POLICY tvd_logon_all;
SELECT * FROM audit_unified_enabled_policies;

-- connect to CDB
DOC 
# connect to CDB with an unknown user
#
conn abcdef/wrong@localhost:1521/TMOBI01

DOC 
# connect to CDB with an known user but wrong password
#
conn c##test/wrong@localhost:1521/TMOBI01

DOC 
# connect to CDB with an known user and correct password
#
conn c##test/manager@localhost:1521/TMOBI01

-- review audit via CDB
DOC 
# review audit via CDB
#
conn / as sysdba

SELECT event_timestamp,con_id,os_username,dbusername,action_name,return_code,system_privilege_used,unified_audit_policies 
FROM cdb_unified_audit_trail 
ORDER BY event_timestamp;

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

-- Change audit policy
DOC 
# change audit policy and except sys
#

NOAUDIT POLICY tvd_logon_all;
AUDIT POLICY tvd_logon_all EXCEPT sys;
SELECT * FROM audit_unified_enabled_policies;

-- connect to CDB
DOC 
# connect to CDB with an unknown user
#
conn abcdef/wrong@localhost:1521/TMOBI01

DOC 
# connect to CDB with an known user but wrong password
#
conn c##test/wrong@localhost:1521/TMOBI01

DOC 
# connect to CDB with an known user and correct password
#
conn c##test/manager@localhost:1521/TMOBI01

-- review audit via CDB
DOC 
# review audit via CDB
#
conn / as sysdba

SELECT event_timestamp,con_id,os_username,dbusername,action_name,return_code,system_privilege_used,unified_audit_policies 
FROM cdb_unified_audit_trail 
ORDER BY event_timestamp;