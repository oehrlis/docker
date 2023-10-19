--------------------------------------------------------------------------------
-- Trivadis - Part of Accenture, Platform Factory - Data Platforms
-- Saegereistrasse 29, 8152 Glattbrugg, Switzerland
--------------------------------------------------------------------------------
-- Name......: caua_pol.sql
-- Author....: Stefan Oehrli (oes) stefan.oehrli@accenture.com
-- Editor....: Stefan Oehrli
-- Date......: 2023.07.06
-- Usage.....: 
-- Purpose...: Create custom local audit policies
-- Notes.....: 
-- Reference.: 
-- License...: Apache License Version 2.0, January 2004 as shown
--             at http://www.apache.org/licenses/
--------------------------------------------------------------------------------

SET SERVEROUTPUT ON
SET linesize 160 pagesize 200
COL policy_name FOR A40
COL entity_name FOR A30
COL comments FOR A80

SPOOL caua_audpol.log
SHOW con_name
--------------------------------------------------------------------------------
-- Create audit policy to audit all action for privileged users
CREATE AUDIT POLICY oradba_loc_all_act_priv_usr
    ACTIONS ALL
    ONLY TOPLEVEL;

COMMENT ON AUDIT POLICY oradba_loc_all_act_priv_usr IS
    'OraDBA local audit policy to audit all actions by priviledged users';

--------------------------------------------------------------------------------
-- Create audit policy to audit all action by users with direct access
CREATE AUDIT POLICY oradba_loc_all_act_direct_acc
    ACTIONS ALL
    WHEN '(sys_context(''userenv'',''ip_address'') IS NULL)' EVALUATE PER SESSION
    ONLY TOPLEVEL;

COMMENT ON AUDIT POLICY oradba_loc_all_act_direct_acc IS
    'OraDBA local audit policy to audit all actions through direct access';

--------------------------------------------------------------------------------
-- Create audit policy to audit all action by users with direct access
CREATE AUDIT POLICY oradba_loc_all_act_proxy_usr
ACTIONS ALL
    WHEN '(sys_context(''userenv'',''proxy_user'') IS NOT NULL)'
    EVALUATE PER SESSION
    ONLY TOPLEVEL;

COMMENT ON AUDIT POLICY oradba_loc_all_act_proxy_usr IS
    'OraDBA local audit policy to audit all actions of proxy user access';

--------------------------------------------------------------------------------
-- Create audit policy to audit all action by users with direct access
CREATE AUDIT POLICY oradba_loc_all_act_named_usr
    ACTIONS ALL
    ONLY TOPLEVEL;

COMMENT ON AUDIT POLICY oradba_loc_all_act_named_usr IS
    'OraDBA local audit policy to audit all actions of specific named users';

--------------------------------------------------------------------------------
-- Create audit policy to audit all logon events
CREATE AUDIT POLICY oradba_loc_all_logon_events
    ACTIONS
    LOGON,
    LOGOFF;

COMMENT ON AUDIT POLICY oradba_loc_all_logon_events IS
    'OraDBA local audit policy to audit all logon events';

--------------------------------------------------------------------------------
-- Create audit policy to audit all datapump events
CREATE AUDIT POLICY oradba_loc_all_dp_events
    ACTIONS COMPONENT = datapump export, import;

COMMENT ON AUDIT POLICY oradba_loc_all_dp_events IS
    'OraDBA local audit policy to audit all datapump events';

--------------------------------------------------------------------------------
-- Create audit policy to audit all directory access events
CREATE AUDIT POLICY oradba_loc_dir_acc
    ACTIONS READ DIRECTORY, WRITE DIRECTORY, EXECUTE DIRECTORY
    ONLY TOPLEVEL;

COMMENT ON AUDIT POLICY oradba_loc_dir_acc IS
    'OraDBA local audit policy to audit all directory access events';

--------------------------------------------------------------------------------
-- Create audit policy to audit account management actions
CREATE AUDIT POLICY oradba_loc_acc_mgmt
    ACTIONS
        CREATE ROLE, ALTER ROLE, DROP ROLE,
        CREATE USER, ALTER USER, DROP USER,
        CREATE USER, ALTER USER, DROP USER,
        GRANT,
        REVOKE,
        SET ROLE;

COMMENT ON AUDIT POLICY oradba_loc_acc_mgmt IS
    'OraDBA local audit policy to audit account management actions';

--------------------------------------------------------------------------------
-- Create audit policy to audit instance configuration
CREATE AUDIT POLICY oradba_loc_inst_config
    ACTIONS
        ALTER DATABASE,
        ALTER SYSTEM,
        CREATE PFILE,
        CREATE SPFILE;

COMMENT ON AUDIT POLICY oradba_loc_inst_config IS
    'OraDBA local audit policy to audit instance configuration';

--------------------------------------------------------------------------------
-- Create audit policy to audit secure configuration
CREATE AUDIT POLICY oradba_loc_secure_config
    PRIVILEGES
        AUDIT SYSTEM,
        AUDIT ANY
    ACTIONS
        CREATE AUDIT POLICY,
        ALTER AUDIT POLICY,
        DROP AUDIT POLICY,
        AUDIT,
        NOAUDIT,
        ADMINISTER KEY MANAGEMENT,
        ALL ON AUDSYS.DBMS_AUDIT_MGMT;

COMMENT ON AUDIT POLICY oradba_loc_secure_config IS
    'OraDBA local audit policy to audit secure configuration';

--------------------------------------------------------------------------------
-- Create audit policy to audit all critical database activity
CREATE AUDIT POLICY oradba_loc_critical_db_act
    PRIVILEGES
        ADMINISTER DATABASE TRIGGER,
        ADMINISTER KEY MANAGEMENT,
        ALTER LOCKDOWN PROFILE, CREATE LOCKDOWN PROFILE, DROP LOCKDOWN PROFILE,
        CREATE PLUGGABLE DATABASE,
        ALTER PROFILE, CREATE PROFILE, DROP PROFILE,
        ALTER PUBLIC DATABASE LINK, CREATE PUBLIC DATABASE LINK, DROP PUBLIC DATABASE LINK,
        ALTER ANY ROLE, CREATE ROLE, DROP ANY ROLE, GRANT ANY ROLE,
        ALTER ROLLBACK SEGMENT, CREATE ROLLBACK SEGMENT, DROP ROLLBACK SEGMENT,
        ALTER SYSTEM,
        ALTER TABLESPACE, CREATE TABLESPACE, DROP TABLESPACE,
        ALTER USER, CREATE USER, DROP USER,
        CREATE ANY DIRECTORY, DROP ANY DIRECTORY, SELECT ANY DICTIONARY,
        CREATE PUBLIC SYNONYM, DROP PUBLIC SYNONYM,
        EXEMPT ACCESS POLICY,
        EXEMPT REDACTION POLICY,
        EXPORT FULL DATABASE,
        GRANT ANY ROLE, GRANT ANY PRIVILEGE, GRANT ANY OBJECT PRIVILEGE,
        IMPORT FULL DATABASE,
        LOGMINING ACTIONS ALTER DATABASE,
        PURGE DBA_RECYCLEBIN,
        REVOKE,
        SET ROLE;

COMMENT ON AUDIT POLICY oradba_loc_critical_db_act IS
    'OraDBA audit policy to audit all critical database activity';

--------------------------------------------------------------------------------
-- Create audit policy to audit all database schema changes
CREATE AUDIT POLICY oradba_loc_db_schema_changes
    PRIVILEGES
        CREATE EXTERNAL JOB,
        CREATE JOB,
        CREATE ANY JOB
    ACTIONS
        CREATE ANALYTIC VIEW, ALTER ANALYTIC VIEW, DROP ANALYTIC VIEW,
        CREATE ATTRIBUTE DIMENSION, ALTER ATTRIBUTE DIMENSION, DROP ATTRIBUTE DIMENSION,
        CREATE CLUSTER, ALTER CLUSTER, DROP CLUSTER, TRUNCATE CLUSTER, ANALYZE CLUSTER,
        CREATE CONTEXT, DROP CONTEXT,
        CREATE DATABASE LINK, ALTER DATABASE LINK, DROP DATABASE LINK,
        CREATE DIMENSION, ALTER DIMENSION, DROP DIMENSION,
        CREATE FUNCTION, ALTER FUNCTION, DROP FUNCTION,
        CREATE INDEX, ALTER INDEX, DROP INDEX, PURGE INDEX, ANALYZE INDEX,
        CREATE INDEXTYPE, ALTER INDEXTYPE, DROP INDEXTYPE,
        CREATE JAVA, ALTER JAVA, DROP JAVA,
        CREATE LIBRARY, ALTER LIBRARY, DROP LIBRARY,
        CREATE MATERIALIZED VIEW LOG, ALTER MATERIALIZED VIEW LOG, DROP MATERIALIZED VIEW LOG,
        CREATE MATERIALIZED VIEW, ALTER MATERIALIZED VIEW, DROP MATERIALIZED VIEW,
        CREATE MATERIALIZED ZONEMAP, ALTER MATERIALIZED ZONEMAP, DROP MATERIALIZED ZONEMAP,
        CREATE MINING MODEL, ALTER MINING MODEL, DROP MINING MODEL,
        CREATE OPERATOR, ALTER OPERATOR, DROP OPERATOR,
        CREATE OUTLINE, ALTER OUTLINE, DROP OUTLINE,
        CREATE PACKAGE BODY, ALTER PACKAGE BODY, DROP PACKAGE BODY,
        CREATE PACKAGE, ALTER PACKAGE, DROP PACKAGE,
        CREATE PROCEDURE, ALTER PROCEDURE, DROP PROCEDURE,
        CREATE SEQUENCE, ALTER SEQUENCE, DROP SEQUENCE,
        CREATE SYNONYM, ALTER SYNONYM, DROP SYNONYM,
        CREATE TABLE, ALTER TABLE, DROP TABLE, TRUNCATE TABLE, PURGE TABLE, ANALYZE TABLE,
        CREATE TRIGGER, ALTER TRIGGER, DROP TRIGGER,
        CREATE TYPE BODY, ALTER TYPE BODY, DROP TYPE BODY,
        CREATE TYPE, ALTER TYPE, DROP TYPE,
        CREATE VIEW, ALTER VIEW,
        DROP VIEW;

COMMENT ON AUDIT POLICY oradba_loc_db_schema_changes IS
    'OraDBA local audit policy to audit database schema changes';

-- List enabled audit policies
SELECT * FROM audit_unified_enabled_policies;

-- List audit policies with comments
SELECT * FROM audit_unified_policy_comments;

SPOOL off
-- EOF -------------------------------------------------------------------------