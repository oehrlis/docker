----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 04_config_audit.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.03.18
--  Revision..:  
--  Purpose...: Script to config unified audit
--  Notes.....:  
--  Reference.: SYS (or grant manually to a DBA)
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------

--Check status of unified audit.VALUE muss TRUE sein
select * from v$option where parameter = 'Unified Auditing';
 
--Check DB audit TBS
SELECT * FROM dba_audit_mgmt_config_params WHERE audit_trail = 'UNIFIED AUDIT TRAIL' 
AND parameter_name = 'DB AUDIT TABLESPACE';
 
--Create TBS AUDIT_DATA
CREATE TABLESPACE AUDIT_DATA DATAFILE
  '/u01/oradata/TTVD01/PDB1/audit_data01TTVD01.dbf' SIZE 1M AUTOEXTEND 
  ON NEXT 256M MAXSIZE UNLIMITED;

CREATE TABLESPACE AUDIT_DATA DATAFILE
  '/u01/oradata/TUA122/PDB1/audit_data01TUA122.dbf' SIZE 1M AUTOEXTEND 
  ON NEXT 256M MAXSIZE UNLIMITED;
 
--Initial cleanup of unified audit on all PDB's
begin
  dbms_audit_mgmt.clean_audit_trail(
    audit_trail_type => dbms_audit_mgmt.audit_trail_unified,
    container => dbms_audit_mgmt.container_all,
    use_last_arch_timestamp => false);
end;
/   
 
--Move audit data into new audit tablespace
begin
DBMS_AUDIT_MGMT.SET_AUDIT_TRAIL_LOCATION
    (audit_trail_type => dbms_audit_mgmt.audit_trail_unified,
     audit_trail_location_value => 'AUDIT_DATA');
end;
/    

select
table_owner,table_name,tablespace_name,partition_name,partition_position,segment_created,read_only,parent_table_partition from dba_tab_partitions where
table_name like 'AUD%';
 select
table_owner,table_name,tablespace_name,partition_name,partition_position,segment_created from dba_tab_partitions where table_name like 'AUD%';
 

--Create daily timestamp job
---BEGIN SYS.DBMS_SCHEDULER.DROP_JOB (job_name  => 'SYS.DAILY_AUDIT_TIMESTAMP_UNIFIED'); END; /
BEGIN
   DBMS_SCHEDULER.CREATE_JOB (
      job_name          => 'DAILY_AUDIT_TIMESTAMP_UNIFIED',
      job_type          => 'PLSQL_BLOCK',
      job_action        => 'BEGIN DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(AUDIT_TRAIL_TYPE => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED, container => dbms_audit_mgmt.container_all, LAST_ARCHIVE_TIME => sysdate-0.5); END;',
      start_date        => SYSDATE,
      repeat_interval   => 'FREQ=HOURLY;INTERVAL=12',
      enabled           => TRUE,
      comments          => 'Create an archive timestamp for unified audit');
END;
/
 
--Create regular purge job
--exec dbms_audit_mgmt.drop_purge_job(audit_trail_purge_name => 'DAILY_AUDIT_PURGE_JOB');
BEGIN
   DBMS_AUDIT_MGMT.CREATE_PURGE_JOB (
      AUDIT_TRAIL_TYPE             => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,
      AUDIT_TRAIL_PURGE_INTERVAL   => 12,
      AUDIT_TRAIL_PURGE_NAME       => 'Daily_Audit_Purge_Job',
      container                    => dbms_audit_mgmt.container_all,
      USE_LAST_ARCH_TIMESTAMP      => TRUE);
END;
/

--Check DB audit TBS
set linesize 160 pagesize 200
col PARAMETER_NAME for a25
col PARAMETER_VALUE for a30
SELECT * FROM cdb_audit_mgmt_config_params WHERE audit_trail = 'UNIFIED AUDIT TRAIL';

col LAST_ARCHIVE_TS for a36
SELECT audit_trail,last_archive_ts,database_id,con_id FROM cdb_audit_mgmt_last_arch_ts

col job_name for a25
col JOB_FREQUENCY for a30
SELECT job_name,job_status,job_frequency,use_last_archive_timestamp,
job_container,audit_trail,con_id 
FROM cdb_audit_mgmt_cleanup_jobs;

--Prüfen, dass keine aktivierten Policies vorhanden sind
col USER_NAME for a20
col POLICY_NAME for a30
col ENTITY_NAME for a20
select * from audit_unified_enabled_policies order by 2,1;
--select * from audit_unified_policies
 
--LOGON_LOGOFF alle, ohne Ausnahmen
CREATE AUDIT POLICY TVD_LOGON_LOGOFF
  Actions
    LOGOFF,
    LOGON
  container=all;

audit policy TVD_LOGON_LOGOFF;

CREATE AUDIT POLICY TVD_DBA
  ROLE DBA container=all;
audit policy TVD_DBA;

--LOGON_LOGOFF alle, ohne Ausnahmen
CREATE AUDIT POLICY TVD_DATAPUMP
  ACTIONS COMPONENT=DATAPUMP ALL container=all;

audit policy TVD_DATAPUMP;

alter session set container=pdb1;
CREATE AUDIT POLICY TVD_EMPLOYEES
  ACTIONS ALL on tvd_hr.employees container=current;
audit policy TVD_EMPLOYEES;

CREATE AUDIT POLICY TVD_SCOTT_EMP
  ACTIONS ALL on scott.emp container=current;
audit policy TVD_SCOTT_EMP;

alter session set container=cdb$root;

col USER_NAME for a20
col POLICY_NAME for a30
col ENTITY_NAME for a20
select * from audit_unified_enabled_policies order by 2,1;

-- EOF ---------------------------------------------------------------------