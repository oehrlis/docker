-- -----------------------------------------------------------------------------
-- Trivadis - Part of Accenture, Platform Factory - Transactional Data Platform
-- Saegereistrasse 29, 8152 Glattbrugg, Switzerland
-- -----------------------------------------------------------------------------
-- Name.......: setup_emp_part.sql
-- Author.....: Stefan Oehrli (oes) stefan.oehrli@accenture.com
-- Date.......: 2021.10.21
-- Revision...: 
-- Purpose....: Setup Range Partitioning for Demo of export of Partitions
-- Notes......: do not forget to drop the partitioned table after demo !!!
-- Reference..: --
-- License....: Apache License Version 2.0, January 2004 as shown
--              at http://www.apache.org/licenses/
-- -----------------------------------------------------------------------------
REM *** create a partitioned table on data of scott.emp
REM
CREATE table SCOTT.emp_p
       ( empno     number(4) not null
        ,ename     varchar2(10) not null
        ,job       varchar2(9)
        ,mgr       number(4)
        ,hiredate  date not null
        ,sal       number(7,2)
        ,comm      number(7,2)
        ,deptno    number(2)
        ,CONSTRAINT PK_EMP_P primary key(empno))
  tablespace USERS
  PARTITION by RANGE (hiredate)
   (PARTITION EMP_P_P1 values less than (to_date('1980-12-31','YYYY-MM-DD')) tablespace users
  , PARTITION EMP_P_P2 values less than (to_date('1981-12-31','YYYY-MM-DD')) tablespace users
  , PARTITION EMP_P_P3 values less than (to_date('1982-12-31','YYYY-MM-DD')) tablespace users
  , PARTITION EMP_P_P4 values less than (to_date('1987-12-31','YYYY-MM-DD')) tablespace users
 );

INSERT /*+ APPEND */ into SCOTT.EMP_P SELECT * from SCOTT.EMP;

COMMIT;

ANALYZE TABLE scott.emp_p COMPUTE STATISTICS;

REM
REM *** To Drop partitioned table
REM
PROMPT DROP table SCOTT.EMP_P cascade constraints; 
-- --- EOF ---------------------------------------------------------------------
