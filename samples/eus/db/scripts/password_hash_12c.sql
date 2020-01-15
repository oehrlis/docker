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
    v_old_hash varchar2(200);
    vHash VARCHAR2(200);
    v_new_hash varchar2(200);
    v_salt varchar2(128);
    v_name varchar2(128);
BEGIN
    SELECT 
        name,
        regexp_substr(spare4,'T\:(.+)',1,1,'i',1),
        substr(regexp_substr(spare4,'t\:(.+)',1,1,'i',1), 1, 128),
        sys.dbms_crypto.hash(utl_raw.cast_to_raw('&pwd')|| hextoraw(substr(regexp_substr(spare4,'t\:(.+)',1,1,'i',1), 129, 32)), sys.dbms_crypto.hash_sh512),
        substr(regexp_substr(spare4,'t\:(.+)',1,1,'i',1), 129, 32)
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
    dbms_output.put_line('User     : ' || v_name ||' (&pwd)');
    IF v_old_hash = v_new_hash THEN
        dbms_output.put_line('Password does match!!');
    ELSE
        dbms_output.put_line('Password is unknown');
    END IF;
    dbms_output.put_line('Hash     : ' || vHash);
    dbms_output.put_line('Old Hash : ' || v_old_hash);
    dbms_output.put_line('New Hash : ' || v_new_hash);
    dbms_output.put_line('Salt     : ' || v_salt);
    dbms_output.put_line('----------------------------------------------------------');
END;
/
-- EOF ---------------------------------------------------------------------
-- S:70DF06A876E8B5A79BF4252687EDB0D1030B16A7  961F464FA0DDE4B1CC3E
-- 961F464FA0DDE4B1CC3E
-- T:
-- 3FA2554AC3CA4026EBE1FB4C3144AB01F1EFDA17D2280401DA406A4E67B8749BC728B578F2D41F68EB562EA3F5648497DF00F1E2E1A07B27F2446E661F81D56
-- E1E0FF33298890FE9B91F0842F41A50EB

-- 3FA2554AC3CA4026EBE1FB4C3144AB01F1EFDA17D2280401DA406A4E67B8749BC728B578F2D41F68EB562EA3F5648497DF00F1E2E1A07B27F2446E661F81D56E 1E0FF33298890FE9B91F0842F41A50EB
-- 3FA2554AC3CA4026EBE1FB4C3144AB01F1EFDA17D2280401DA406A4E67B8749BC728B578F2D41F68EB562EA3F5648497DF00F1E2E1A07B27F2446E661F81D56E



-- Hash	     : 2B3E9EF38DF07EA72268E6E2AA13A4FCADA3579B2D413077D12102D4447150C57C33FE910A62D14F13F453628140E73AC3574B8CFF70483B8F70CD830C4069C2 EAA58579A7F26BCED2BC982E1EC05B80
-- Old Hash  : 2B3E9EF38DF07EA72268E6E2AA13A4FCADA3579B2D413077D12102D4447150C57C33FE910A62D14F13F453628140E73AC3574B8CFF70483B8F70CD830C4069C2
-- New Hash  : CFADE84680A924E57512CC767EF966D70F95AC457BD77EB4D00D8A419ACCD1A14DEFF099B2DB5715C6E346F148543A4F46CBECC59669346B167BFB122043B699
-- Salt	     : EAA58579A7F26BCED2BC982E1EC05B80
--             EAA58579A7F26BCED2BC982E1EC05B80