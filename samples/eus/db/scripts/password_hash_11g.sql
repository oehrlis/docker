----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: password_hash_11g.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.11.29
--  Usage.....: @password_hash_11g
--  Purpose...: Calculate SHA1 / 11g password hash and compare it
--  Notes.....: 
--  Reference.: 
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------

---------------------------------------------------------------------------
-- Define the default values 
DEFINE def_user = "SECADMIN"
DEFINE def_pwd  = "manager"

---------------------------------------------------------------------------
-- define default values for parameter if argument 1 or 2 is empty
-- Parameter 1 : def_user
-- Parameter 2 : def_pwd
SET FEEDBACK OFF
SET VERIFY OFF
COLUMN 1 NEW_VALUE 1 NOPRINT
COLUMN 2 NEW_VALUE 2 NOPRINT
SELECT '' "1" FROM dual WHERE ROWNUM = 0;
SELECT '' "2" FROM dual WHERE ROWNUM = 0;
DEFINE user = &1 &def_user
DEFINE pwd  = &2 &def_pwd

-- alter the SQL*Plus environment
SET PAGESIZE 200 LINESIZE 160
SET FEEDBACK ON
SET SERVEROUTPUT ON 

DECLARE
    v_old_hash VARCHAR2(40);
    vHash VARCHAR2(128);
    v_new_hash VARCHAR2(40);
    v_salt VARCHAR2(40);
    v_name VARCHAR2(30);
BEGIN
    SELECT 
        name,
        regexp_substr(spare4,'S\:(.+);',1,1,'i',1),
        substr(regexp_substr(spare4,'S\:(.+);',1,1,'i',1), 1, 40),
        sys.dbms_crypto.hash(utl_raw.cast_to_raw('&pwd')|| hextoraw(substr(regexp_substr(spare4,'S\:(.+);',1,1,'i',1), 41, 20)), sys.dbms_crypto.hash_sh1),
        substr(regexp_substr(spare4,'S\:(.+);',1,1,'i',1), 41, 20)
    INTO
        v_name,
        vHash,
        v_old_hash,
        v_new_hash,
        v_salt
    FROM
         user$
    WHERE name = '&user';
    
    dbms_output.put_line('----------------------------------------------------------');
    dbms_output.put_line('User         : ' || v_name ||' (&pwd)');
    IF v_old_hash = v_new_hash THEN
        dbms_output.put_line('Password does match!!');
    ELSE
        dbms_output.put_line('Password is unknown');
    END IF;
    dbms_output.put_line('Hash         : ' || vHash);
    dbms_output.put_line('Old Hash     : ' || v_old_hash);
    dbms_output.put_line('New Hash     : ' || v_new_hash);
    dbms_output.put_line('Salt         : ' || v_salt);
    dbms_output.put_line('----------------------------------------------------------');
END;
/
-- EOF ---------------------------------------------------------------------
--select name,REGEXP_SUBSTR(spare4,'S\:(.+);',1,1,'i',1) from user$ where name='SCOTT';