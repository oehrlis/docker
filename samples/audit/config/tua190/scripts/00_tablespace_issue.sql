----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 00_tablespace_issue.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.03.18
--  Revision..:  
--  Purpose...: Script test audit tablespace issue bug 27576342
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
col segment_name for a30
col tablespace_name for a20
col parameter for a30
col value for a20
col interval for a40
col TABLE_OWNER for a11
col TABLE_NAME for a20
col PARTITION_NAME for a25
col PARENT_TABLE_PARTITION for a30
col PARAMETER_NAME for a30
col PARAMETER_VALUE for a20
col OWNER for a10
col LOB_INDPART_NAME for a20
col LOB_PARTITION_NAME for a20
col LOB_NAME for a30
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

-- PDBs
SELECT name FROM v$pdbs;
/*
SQL> SELECT name FROM v$pdbs;

NAME
--------------------------------------------------------------------------------------------------------------------------------
PDB$SEED
PDB1

2 rows selected.
*/

-- change container
ALTER SESSION SET CONTAINER=pdb1;
SHOW con_id

-- status of unified audit
SELECT parameter,value FROM v$option WHERE parameter LIKE 'Unified Auditing';

-- objects of AUDSYS user
SELECT segment_name,ds.tablespace_name FROM dba_segments ds WHERE owner = 'AUDSYS';
/*
SQL> SELECT parameter,value FROM v$option WHERE parameter LIKE 'Unified Auditing';

PARAMETER		       VALUE
------------------------------ --------------------
Unified Auditing	       TRUE

1 row selected.
*/

-- AUD Table partitions
SELECT table_owner,table_name,tablespace_name,partition_name,partition_position,segment_created,read_only,parent_table_partition 
FROM dba_tab_partitions WHERE table_name LIKE 'AUD%';
/*
SELECT table_owner,table_name,tablespace_name,partition_name,partition_position,segment_created,read_only,parent_table_partition 
  2  FROM dba_tab_partitions WHERE table_name LIKE 'AUD%';

TABLE_OWNER TABLE_NAME		 TABLESPACE_NAME      PARTITION_NAME		PARTITION_POSITION SEGM READ PARENT_TABLE_PARTITION
----------- -------------------- -------------------- ------------------------- ------------------ ---- ---- ------------------------------
AUDSYS	    AUD$UNIFIED 	 SYSAUX 	      AUD_UNIFIED_P0				 1 NO	NO
AUDSYS	    AUD$UNIFIED 	 SYSAUX 	      SYS_P201					 2 YES	NO

2 rows selected.
*/

--Check DB audit TBS
SELECT * FROM dba_audit_mgmt_config_params WHERE audit_trail = 'UNIFIED AUDIT TRAIL' 
AND parameter_name = 'DB AUDIT TABLESPACE';
/*
SELECT * FROM dba_audit_mgmt_config_params WHERE audit_trail = 'UNIFIED AUDIT TRAIL' 
  2  AND parameter_name = 'DB AUDIT TABLESPACE';

PARAMETER_NAME		       PARAMETER_VALUE	    AUDIT_TRAIL
------------------------------ -------------------- ----------------------------
DB AUDIT TABLESPACE	       SYSAUX		    UNIFIED AUDIT TRAIL

1 row selected.
*/

--Create TBS AUDIT_DATA
CREATE TABLESPACE AUDIT_DATA DATAFILE
  '/u01/oradata/TUA122/PDB1/audit_data01TUA122.dbf' SIZE 1M AUTOEXTEND 
  ON NEXT 256M MAXSIZE UNLIMITED;

-- move audit trail
EXEC dbms_audit_mgmt.set_audit_trail_location(audit_trail_type=>DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,audit_trail_location_value=>'AUDIT_DATA');
 
-- change interval for partitions
EXEC dbms_audit_mgmt.alter_partition_interval(interval_number=>1, interval_frequency=>'DAY'); 
 
-- segments
SELECT owner,segment_name,tablespace_name,partition_name,segment_type,retention FROM dba_Segments WHERE owner='AUDSYS';
/*
SELECT owner,segment_name,tablespace_name,partition_name,segment_type,retention FROM dba_Segments WHERE owner='AUDSYS';

OWNER	   SEGMENT_NAME 		  TABLESPACE_NAME      PARTITION_NAME		 SEGMENT_TYPE	    RETENTI
---------- ------------------------------ -------------------- ------------------------- ------------------ -------
AUDSYS	   AUD$UNIFIED			  SYSAUX	       SYS_P201 		 TABLE PARTITION
AUDSYS	   SYS_IL0000017939C00097$$	  SYSAUX	       SYS_IL_P207		 INDEX PARTITION
AUDSYS	   SYS_IL0000017939C00031$$	  SYSAUX	       SYS_IL_P205		 INDEX PARTITION
AUDSYS	   SYS_IL0000017939C00030$$	  SYSAUX	       SYS_IL_P203		 INDEX PARTITION
AUDSYS	   SYS_LOB0000017939C00030$$	  SYSAUX	       SYS_LOB_P202		 LOB PARTITION	    DEFAULT
AUDSYS	   SYS_LOB0000017939C00031$$	  SYSAUX	       SYS_LOB_P204		 LOB PARTITION	    DEFAULT
AUDSYS	   SYS_LOB0000017939C00097$$	  SYSAUX	       SYS_LOB_P206		 LOB PARTITION	    DEFAULT

7 rows selected.
*/

-- audit partions
SELECT table_owner,table_name,tablespace_name,partition_name,partition_position,segment_created FROM dba_tab_partitions WHERE table_name LIKE 'AUD%';
 
 /*
SQL>  SELECT table_owner,table_name,tablespace_name,partition_name,partition_position,segment_created FROM dba_tab_partitions WHERE table_name LIKE 'AUD%';

TABLE_OWNER TABLE_NAME		 TABLESPACE_NAME      PARTITION_NAME		PARTITION_POSITION SEGM
----------- -------------------- -------------------- ------------------------- ------------------ ----
AUDSYS	    AUD$UNIFIED 	 SYSAUX 	      AUD_UNIFIED_P0				 1 NO
AUDSYS	    AUD$UNIFIED 	 SYSAUX 	      SYS_P201					 2 YES

2 rows selected.
*/

SELECT owner,table_name,interval,partitioning_type,partition_count,def_tablespace_name FROM dba_part_Tables WHERE owner='AUDSYS';
/*
SQL> SELECT owner,table_name,interval,partitioning_type,partition_count,def_tablespace_name FROM dba_part_Tables WHERE owner='AUDSYS';

OWNER	   TABLE_NAME		INTERVAL				 PARTITION PARTITION_COUNT DEF_TABLESPACE_NAME
---------- -------------------- ---------------------------------------- --------- --------------- ------------------------------
AUDSYS	   AUD$UNIFIED		NUMTODSINTERVAL(1, 'DAY')		 RANGE		   1048575 AUDIT_DATA
AUDSYS	   CLI_SWP$fe0e7a69$1$1 					 RANGE			 1 AUDIT_DATA

2 rows selected.
*/

SELECT table_owner,table_name,tablespace_name,lob_partition_name,lob_name,lob_indpart_name,
partition_position,segment_created,in_row,lob_indpart_name FROM
dba_lob_partitions WHERE table_owner='AUDSYS';
/*
SELECT table_owner,table_name,tablespace_name,lob_partition_name,lob_name,lob_indpart_name,
partition_position,segment_created,in_row,lob_indpart_name FROM
  2    3  dba_lob_partitions WHERE table_owner='AUDSYS';

TABLE_OWNER TABLE_NAME		 TABLESPACE_NAME      LOB_PARTITION_NAME   LOB_NAME			  LOB_INDPART_NAME     PARTITION_POSITION SEG IN_ LOB_INDPART_NAME
----------- -------------------- -------------------- -------------------- ------------------------------ -------------------- ------------------ --- --- --------------------
AUDSYS	    AUD$UNIFIED 	 SYSAUX 	      SYS_LOB_P139	   SYS_LOB0000017939C00030$$	  SYS_IL_P140				1 NO  YES SYS_IL_P140
AUDSYS	    AUD$UNIFIED 	 SYSAUX 	      SYS_LOB_P202	   SYS_LOB0000017939C00030$$	  SYS_IL_P203				2 YES YES SYS_IL_P203
AUDSYS	    AUD$UNIFIED 	 SYSAUX 	      SYS_LOB_P141	   SYS_LOB0000017939C00031$$	  SYS_IL_P142				1 NO  YES SYS_IL_P142
AUDSYS	    AUD$UNIFIED 	 SYSAUX 	      SYS_LOB_P204	   SYS_LOB0000017939C00031$$	  SYS_IL_P205				2 YES YES SYS_IL_P205
AUDSYS	    AUD$UNIFIED 	 SYSAUX 	      SYS_LOB_P143	   SYS_LOB0000017939C00097$$	  SYS_IL_P144				1 NO  YES SYS_IL_P144
AUDSYS	    AUD$UNIFIED 	 SYSAUX 	      SYS_LOB_P206	   SYS_LOB0000017939C00097$$	  SYS_IL_P207				2 YES YES SYS_IL_P207
AUDSYS	    CLI_SWP$fe0e7a69$1$1 AUDIT_DATA	      SYS_LOB_P241	   SYS_LOB0000073452C00014$$	  SYS_IL_P242				1 NO  YES SYS_IL_P242

7 rows selected.
*/
-- EOF ---------------------------------------------------------------------