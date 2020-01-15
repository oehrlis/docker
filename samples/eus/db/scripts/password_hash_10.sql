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
DEFINE def_user = "SYSTEM"
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
    vSecKey RAW(128);
    vEncRAW RAW(2048);
    vUniStr VARCHAR2(124) := '';
    -- Define CONSTANT for the crypto type DES in CBC Mode with zero padding
    cCryptoTyp CONSTANT PLS_INTEGER := dbms_crypto.encrypt_des + dbms_crypto.chain_cbc + dbms_crypto.pad_zero;
    BEGIN  
    -- Build the new userpwd String as multibyte with the high byte set to 0 and convert the string into raw
    FOR i IN 1..length(upper(&user||&pwd)) LOOP vUniStr := vUniStr||CHR(0)||SUBSTR(UPPER(&user||&pwd),i,1); END LOOP;
    -- First DES encryption to create the second DES key
    vEncRAW:= dbms_crypto.encrypt(src=>utl_raw.cast_to_raw(vUniStr), typ => cCryptoTyp, key => hextoraw('0123456789ABCDEF'));
    -- Get the last 8 Bytes as second key
    vSecKey:= hextoraw(substr(vEncRAW,(length(vEncRAW)-16+1),16));
    -- Second DES encryption to create the Hash
    vEncRAW:= dbms_crypto.encrypt(src=> utl_raw.cast_to_raw(vUniStr), typ => cCryptoTyp, key => vSecKey);
    -- Return the last 8 bytes as Oracle Hash

    dbms_output.put_line('----------------------------------------------------------');
    dbms_output.put_line('User         :  &user (&pwd)');
    dbms_output.put_line('Hash         : ' || hextoraw(substr(vEncRAW,(length(vEncRAW)-16+1),16)));
    dbms_output.put_line('----------------------------------------------------------');
END;
/
-- EOF ---------------------------------------------------------------------
