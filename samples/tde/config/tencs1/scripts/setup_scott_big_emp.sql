-- -----------------------------------------------------------------------------
-- Trivadis - Part of Accenture, Platform Factory - Transactional Data Platform
-- Saegereistrasse 29, 8152 Glattbrugg, Switzerland
-- -----------------------------------------------------------------------------
-- Name.......: setup_scott_big_emp.sql
-- Author.....: Stefan Oehrli (oes) stefan.oehrli@accenture.com
-- Date.......: 2021.10.21
-- Revision...: 
-- Purpose....: Setup Big_Emp Tabelle
-- Notes......: Preparation if you use 
--              16_expdp_scott_big_emp.par
--              16_impdp_full_transform_arch.par
--              DO NOT FORGET TO DROP THE BIG_EMP TABLE AFTER DEMO !!!
-- Reference..: --
-- License....: Apache License Version 2.0, January 2004 as shown
--              at http://www.apache.org/licenses/
-- -----------------------------------------------------------------------------

REM *** create a BIG_EMP Table for scott
REM
DROP TABLE SCOTT.big_emp PURGE;
CREATE table SCOTT.big_emp
       ( empno     number(20)     not null
        ,ename     varchar2(20)
        ,job       varchar2(9)
        ,mgr       number(4)
        ,hiredate  date not null
        ,sal       number(7,2)
        ,comm      number(7,2)
        ,deptno    number(2)
        ,CONSTRAINT PK_BIG_EMP_P primary key(empno))
  tablespace USERS;


REM *** insert records using loop
REM
DECLARE
  sql_str    VARCHAR2(200);
  v_emp_no   NUMBER(10);
  v_max_loop PLS_INTEGER := 10000000;
BEGIN
  v_emp_no := 0;
  LOOP
    v_emp_no := v_emp_no + 1;
    sql_str := 'INSERT /*+ APPEND */ INTO scott.big_emp ( empno, ename, hiredate ) VALUES ( ' || v_emp_no || ' , ' || CHR(39) || 'SCOTT ' || TO_CHAR(v_emp_no) || CHR(39) || ', sysdate )';
    EXECUTE IMMEDIATE sql_str;
    exit when v_emp_no >= v_max_loop;
    COMMIT;
  END LOOP;
END;
/

EXEC dbms_stats.gather_table_stats ( ownname => 'SCOTT', tabname => 'BIG_EMP' );

REM *** Read some records
REM     Read number of records
SELECT * from scott.big_emp where rownum < 10;
SELECT count(*) from scott.big_emp;

SELECT min(empno), max(empno) from scott.big_emp;

set echo on
REM
REM *** To Drop Big-Table
REM
PROMPT DROP table SCOTT.BIG_EMP cascade constraints; 

EXIT
-- --- EOF ---------------------------------------------------------------------
