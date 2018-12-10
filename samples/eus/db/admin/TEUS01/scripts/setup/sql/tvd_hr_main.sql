----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: tvd_hr_main.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2018.10.24
--  Revision..:  
--  Purpose...: Main script to create the TVD_HR schema
--  Notes.....:  
--  Reference.: SYS (or grant manually to a DBA)
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------

SET ECHO OFF
SET VERIFY OFF

PROMPT 
PROMPT specify password for TVD_HR as parameter 1:
DEFINE pass     = &1
PROMPT 
PROMPT specify default tablespeace for TVD_HR as parameter 2:
DEFINE tbs      = &2
PROMPT 
PROMPT specify temporary tablespace for TVD_HR as parameter 3:
DEFINE ttbs     = &3
PROMPT 
PROMPT specify log path as parameter 4:
DEFINE log_path = &4
PROMPT

DEFINE spool_file = &log_path/tvd_hr_main.log
SPOOL &spool_file

----------------------------------------------------------------------------
-- Simple example how to get path (@@) of the current script.
rem This script will set "cur_path" variable, so we can use &cur_path later.
  
set termout off
spool _cur_path.remove
@@notfound
spool off;
  
var cur_path varchar2(100);
declare
  v varchar2(100);
  m varchar2(100):='SP2-0310: unable to open file "';
begin v :=rtrim(ltrim( 
                        q'[
                            @_cur_path.remove
                        ]',' '||chr(10)),' '||chr(10));
  v:=substr(v,instr(v,m)+length(m));
  v:=substr(v,1,instr(v,'notfound.')-1);
  :cur_path:=v;
end;
/
set scan off;
ho (rm _cur_path.remove 2>&1  | echo .)
ho (del _cur_path.remove 2>&1 | echo .)
col cur_path new_val cur_path noprint;
select :cur_path cur_path from dual;
set scan on;
set termout on;

----------------------------------------------------------------------------
-- cleanup section 
DECLARE
vcount INTEGER :=0;
BEGIN
SELECT count(1) INTO vcount FROM dba_users WHERE username = 'TVD_HR';
IF vcount != 0 THEN
EXECUTE IMMEDIATE ('DROP USER tvd_hr CASCADE');
END IF;
END;
/

----------------------------------------------------------------------------
-- create user 
CREATE USER tvd_hr IDENTIFIED BY &pass;

ALTER USER tvd_hr DEFAULT TABLESPACE &tbs
    QUOTA UNLIMITED ON &tbs;

ALTER USER tvd_hr TEMPORARY TABLESPACE &ttbs;

GRANT CREATE SESSION, CREATE VIEW, ALTER SESSION, CREATE SEQUENCE TO tvd_hr;
GRANT CREATE SYNONYM, CREATE DATABASE LINK, RESOURCE , UNLIMITED TABLESPACE TO tvd_hr;

----------------------------------------------------------------------------
-- grants from sys schema
GRANT execute ON sys.dbms_stats TO tvd_hr;

----------------------------------------------------------------------------
-- create tvd_hr schema objects
ALTER SESSION SET CURRENT_SCHEMA=TVD_HR;

ALTER SESSION SET NLS_LANGUAGE=American;
ALTER SESSION SET NLS_TERRITORY=America;

----------------------------------------------------------------------------
-- create tables, sequences and constraint
@&cur_path/tvd_hr_cre

----------------------------------------------------------------------------
-- populate tables
@&cur_path/tvd_hr_popul

----------------------------------------------------------------------------
-- create indexes
@&cur_path/tvd_hr_idx

----------------------------------------------------------------------------
-- create procedural objects
@&cur_path/tvd_hr_code

----------------------------------------------------------------------------
-- add comments to tables and columns
@&cur_path/tvd_hr_comnt

----------------------------------------------------------------------------
-- gather schema statistics
@&cur_path/tvd_hr_analz

spool off
-- EOF ---------------------------------------------------------------------