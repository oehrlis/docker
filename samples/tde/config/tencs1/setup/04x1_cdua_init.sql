--------------------------------------------------------------------------------
--  Trivadis - Part of Accenture, Platform Factory - Data Platforms
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
--------------------------------------------------------------------------------
--  Name......: cdua_init.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@accenture.com
--  Editor....: Stefan Oehrli
--  Date......: 2023.26.29
--  Usage.....: cdua_init.sql <TABLESPACE NAME> <DATAFILE SIZE> <AUDIT RETENTION>
--
--              TABLESPACE NAME   Name of the audit tablespace. Default is AUDIT_DATA
--              DATAFILE SIZE     Initial size of datafile. Default 20480K
--              AUDIT RETENTION   Day for which a audit timestamp will be created e.g.
--                                sysdate - <AUDIT RETENTION> This does help to create
--                                somekind of time window where audit records will be
--                                awailable on the system. This amount of DAY
--                                is also the fallback when the AVAGENT does not CREATE
--                                timestamps. Default 30 days
--  Purpose...: Initialize Audit environment. Create Tablespace, reorganize Audit
--              tables and create jobs
--  Notes.....: 
--  Reference.: 
--  License...: Apache License Version 2.0, January 2004 as shown
--              at http://www.apache.org/licenses/
--------------------------------------------------------------------------------

-- define default values
DEFINE _tablespace_name = 'AUDIT_DATA'
DEFINE _tablespace_size = '20480K'
DEFINE _audit_retention = 30

-- assign default value for parameter if argument 1,2 or 3 is empty
SET FEEDBACK OFF
SET VERIFY OFF
COLUMN 1 NEW_VALUE 1 NOPRINT
COLUMN 2 NEW_VALUE 2 NOPRINT
COLUMN 3 NEW_VALUE 3 NOPRINT
SELECT '' "1" FROM dual WHERE ROWNUM = 0;
SELECT '' "2" FROM dual WHERE ROWNUM = 0;
SELECT '' "3" FROM dual WHERE ROWNUM = 0;
DEFINE tablespace_name    = &1 &_tablespace_name
DEFINE tablespace_size    = &2 &_tablespace_size
DEFINE audit_retention    = &3 &_audit_retention
COLUMN tablespace_name NEW_VALUE tablespace_name NOPRINT
SELECT upper('&tablespace_name') tablespace_name FROM dual;

SPOOL cdua_init.log
-- Anonymous PL/SQL Block to configure audit environment
SET SERVEROUTPUT ON
SET LINESIZE 160 PAGESIZE 200
DECLARE
  v_version           number;
  v_datafile_path     varchar2(513);
  v_db_unique_name    varchar2(30);
  v_audit_tablespace  varchar2(30) := '&tablespace_name';
  v_audit_data_file   varchar2(513);
  e_tablespace_exists EXCEPTION;
  e_job_exists        EXCEPTION;
  e_audit_job_exists  EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_tablespace_exists,-1543);
  PRAGMA EXCEPTION_INIT(e_job_exists, -27477 );
  PRAGMA EXCEPTION_INIT(e_audit_job_exists, -46254);

BEGIN
  DBMS_OUTPUT.put_line('Setup and initialize audit configuration');
  SELECT file_name INTO v_datafile_path FROM dba_data_files WHERE file_name like '%system%' AND rownum <2;
  SELECT db_unique_name INTO v_db_unique_name FROM v$database;
  SELECT regexp_substr(version,'^\d+') INTO v_version FROM v$instance;

-- Create Tablespace but rise an exeption if it allready exists
  DBMS_OUTPUT.put('- Create '||v_audit_tablespace||' Tablespace... ');
  BEGIN
    IF v_datafile_path LIKE '+%' THEN
      SELECT regexp_substr(file_name,'[^/]*') INTO v_datafile_path FROM dba_data_files WHERE file_name like '%system%' AND rownum <2;
      EXECUTE IMMEDIATE 'CREATE TABLESPACE '||v_audit_tablespace||' DATAFILE '''||v_datafile_path||''' SIZE &tablespace_size AUTOEXTEND ON NEXT 10240K MAXSIZE UNLIMITED';
    ELSE
      SELECT regexp_substr(file_name,'^/.*/') INTO v_datafile_path FROM dba_data_files WHERE file_name like '%system%' AND rownum <2;
      -- Datafile String for Audit Tablespace
      v_audit_data_file := v_datafile_path||lower(v_audit_tablespace)||'01'||v_db_unique_name||'.dbf'; 
      EXECUTE IMMEDIATE 'CREATE TABLESPACE '||v_audit_tablespace||' DATAFILE '''||v_audit_data_file||''' SIZE &tablespace_size AUTOEXTEND ON NEXT 10240K MAXSIZE UNLIMITED';
    END IF;
    DBMS_OUTPUT.put_line('created');
  EXCEPTION
     WHEN e_tablespace_exists THEN
          DBMS_OUTPUT.PUT_LINE('already exists');
  END;

  -- set location for Unified Audit Trail
  DBMS_OUTPUT.put_line('Set location to '||v_audit_tablespace||' for Unified Audit');
  DBMS_AUDIT_MGMT.SET_AUDIT_TRAIL_LOCATION(
    audit_trail_type           => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,
    audit_trail_location_value => v_audit_tablespace
  );

  -- set location for Standard and FGA Audit Trail
  DBMS_OUTPUT.put_line('Set location to '||v_audit_tablespace||' for Standard and FGA Audit Trail');
  DBMS_AUDIT_MGMT.SET_AUDIT_TRAIL_LOCATION(
    audit_trail_type           => DBMS_AUDIT_MGMT.AUDIT_TRAIL_DB_STD,
    audit_trail_location_value => v_audit_tablespace
  );

  DBMS_OUTPUT.put_line('Set partition interval to 1 day');
  DBMS_AUDIT_MGMT.ALTER_PARTITION_INTERVAL(
    interval_number       => 1,
    interval_frequency    => 'DAY');

  DBMS_OUTPUT.put_line('Create archive timestamp jobs');
  DBMS_OUTPUT.put('- Unified Audit Trail........... ');
  BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
      job_name   => 'DAILY_UNIFIED_AUDIT_TIMESTAMP',
      job_type   => 'PLSQL_BLOCK',
      job_action => 'BEGIN DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(AUDIT_TRAIL_TYPE => 
                      DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,LAST_ARCHIVE_TIME => sysdate-&audit_retention); END;',
      start_date => sysdate,
      repeat_interval => 'FREQ=HOURLY;INTERVAL=24',
      enabled    =>  TRUE,
      comments   => 'Archive timestamp for unified audit to sysdate-&audit_retention'
    );
    DBMS_OUTPUT.put_line('created');
  EXCEPTION
    WHEN e_job_exists THEN
      DBMS_OUTPUT.PUT_LINE('already exists');
  END;

-- Create daily purge job
  DBMS_OUTPUT.put_line('Create archive purge jobs');
  -- Purge Job Unified Audit Trail
  DBMS_OUTPUT.put('- Unified Audit Trail............ ');
  BEGIN
    DBMS_AUDIT_MGMT.CREATE_PURGE_JOB(
      audit_trail_type           => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,
      audit_trail_purge_interval => 24 /* hours */,
      audit_trail_purge_name     => 'Daily_Unified_Audit_Purge_Job',
      use_last_arch_timestamp    => TRUE
    );
    DBMS_OUTPUT.put_line('created');
  EXCEPTION
    WHEN e_audit_job_exists THEN
      DBMS_OUTPUT.PUT_LINE('already exists');
  END;

END;
/

COL parameter_name FOR a30
COL parameter_value FOR a20
COL audit_trail FOR a20
SELECT audit_trail,parameter_name, parameter_value 
FROM dba_audit_mgmt_config_params ORDER BY audit_trail;

COL job_name FOR a30
COL job_frequency FOR a40
SELECT job_name,job_status,audit_trail,job_frequency FROM dba_audit_mgmt_cleanup_jobs;

COL job_name FOR a30
COL repeat_interval FOR a80
SELECT job_name,repeat_interval,comments FROM dba_scheduler_jobs WHERE job_name LIKE '%AUDIT%' ;

COL policy_name for a40
COL entity_name for a30
SELECT * FROM audit_unified_enabled_policies;

SPOOL off
-- EOF -------------------------------------------------------------------------