--------------------------------------------------------------------------------
--  OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
--------------------------------------------------------------------------------
--  Name......: ssenc_info.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
--  Editor....: Stefan Oehrli
--  Date......: 2024.04.25
--  Version...: v0.1.0
--  Purpose...: Show information about the TDE Configuration 
--  Notes.....:  
--  Reference.: Requires SYS, SYSDBA or SYSKM privilege
--  License...: Apache License Version 2.0, January 2004 as shown
--              at http://www.apache.org/licenses/
--------------------------------------------------------------------------------
-- format SQLPlus output and behavior
SET LINESIZE 180 PAGESIZE 66
SET HEADING ON
SET VERIFY ON
SET FEEDBACK ON

COLUMN wrl_type             FORMAT A8
COLUMN wrl_parameter        FORMAT A75
COLUMN status               FORMAT A18
COLUMN wallet_type          FORMAT A15
COLUMN con_id               FORMAT 99999
COLUMN name                 FORMAT A42
COLUMN value                FORMAT A60
COLUMN memory               FORMAT A50
COLUMN spfile               FORMAT A50
COLUMN owner                FORMAT A20
COLUMN table_name           FORMAT A30
COLUMN column_name          FORMAT A30
COLUMN encryption_alg       FORMAT A5
COLUMN salt                 FORMAT A5
COLUMN integrity_alg        FORMAT A5
COLUMN Parameter            FORMAT A42
COLUMN Container            FORMAT A12
COLUMN Session              FORMAT A9
COLUMN Instance             FORMAT A35
COLUMN S                    FORMAT A1
COLUMN I                    FORMAT A1
COLUMN D                    FORMAT A1
COLUMN Description          FORMAT A65
COLUMN key_id               FORMAT A52
COLUMN creation_time        FORMAT A20
COLUMN creator              FORMAT A10
COLUMN creator_pdbname      FORMAT A10
COLUMN activation_time      FORMAT A20
COLUMN activating_pdbname   FORMAT A10
ALTER SESSION SET nls_timestamp_tz_format='DD.MM.YYYY HH24:MI:SS';
SPOOL ssenc_info.log

PROMPT =========================================================================
PROMPT == Current TDE Configuration ============================================
PROMPT =========================================================================

-- list pending parameter init.ora parameter for TDE information i.e., parameter
-- which are set in SPFILE but not yet active in memory
PROMPT == Pending parameter for the TDE configuration in SPFILE ================ 
SELECT vsp.name,nvl(vp.value,'undef') memory,nvl(vsp.value,'undef') spfile,vsp.ISSPECIFIED FROM v$parameter vp, v$spparameter vsp
WHERE vsp.name IN ('wallet_root','tde_configuration','tablespace_encryption','encrypt_new_tablespaces')
AND vsp.name = vp.name
AND nvl(vsp.value,'undef') != nvl(vp.value,'undef')
AND vsp.isspecified ='TRUE'
ORDER BY vsp.name;

PROMPT == Current regular parameter for TDE configuration ======================
SELECT  
  lower(a.ksppinm)  "Parameter", 
  decode(c.con_id,0,'CDB',(SELECT pdb.name||' ('||pdb.con_id||')' FROM v$pdbs pdb WHERE pdb.con_id=c.con_id))  "Container",
  decode(p.isses_modifiable,'FALSE',NULL,NULL,NULL,b.ksppstvl) "Session", 
  c.ksppstvl "Instance",
  decode(p.isses_modifiable,'FALSE','F','TRUE','T') "S",
  decode(p.issys_modifiable,'FALSE','F','TRUE','T','IMMEDIATE','I','DEFERRED','D') "I",
  decode(p.isdefault,'FALSE','F','TRUE','T') "D",
  a.ksppdesc "Description"
FROM x$ksppi a, x$ksppcv b, x$ksppsv c, v$parameter p
WHERE a.indx = b.indx AND a.indx = c.indx
  AND p.name(+) = a.ksppinm
  AND upper(a.ksppinm) IN (
    'WALLET_ROOT',
    'TDE_CONFIGURATION',
    'TABLESPACE_ENCRYPTION',
    'ENCRYPT_NEW_TABLESPACES',
    'EXTERNAL_KEYSTORE_CREDENTIAL_LOCATION'
    )
ORDER BY a.ksppinm,c.con_id;

PROMPT == Current hidden parameter for TDE configuration =======================
SELECT  
  lower(a.ksppinm)  "Parameter", 
  decode(c.con_id,0,'CDB',(SELECT pdb.name||' ('||pdb.con_id||')' FROM v$pdbs pdb WHERE pdb.con_id=c.con_id))  "Container",
  decode(p.isses_modifiable,'FALSE',NULL,NULL,NULL,b.ksppstvl) "Session", 
  c.ksppstvl "Instance",
  decode(p.isses_modifiable,'FALSE','F','TRUE','T') "S",
  decode(p.issys_modifiable,'FALSE','F','TRUE','T','IMMEDIATE','I','DEFERRED','D') "I",
  decode(p.isdefault,'FALSE','F','TRUE','T') "D",
  a.ksppdesc "Description"
FROM x$ksppi a, x$ksppcv b, x$ksppsv c, v$parameter p
WHERE a.indx = b.indx AND a.indx = c.indx
  AND p.name(+) = a.ksppinm
  AND upper(a.ksppinm) IN (
    '_DB_DISCARD_LOST_MASTERKEY',
    '_REMOVE_INACTIVE_STANDBY_TDE_MASTER_KEY',
    '_REMOVE_STDBY_OLD_KEY_AFTER_CHECKPOINT_SCN',
    '_ASSERT_ENCRYPTED_TABLESPACE_BLOCKS',
    '_BACKUP_ENCRYPT_OPT_MODE',
    '_OVERRIDE_DATAFILE_ENCRYPT_CHECK',
    '_TABLESPACE_ENCRYPTION_DEFAULT_ALGORITHM',
    '_USE_HYBRID_ENCRYPTION_MODE',
    '_USE_PLATFORM_ENCRYPTION_LIB',
    '_VERIFY_ENCRYPTED_TABLESPACE_KEYS',
    '_AUTO_REKEY_DURING_MRCV',
    '_DB_GENERATE_DUMMY_MASTERKEY',
    '_TSENC_OBFUSCATE_KEY'
    )
ORDER BY a.ksppinm,c.con_id;

-- list encryption wallet information
PROMPT == Encryption wallet information from v$encryption_wallet ===============
SELECT * FROM v$encryption_wallet;

-- list encryption key information
PROMPT 
PROMPT =========================================================================
PROMPT 🔐 Final TDE Key Summary
PROMPT =========================================================================

SELECT
    key_id,
    key_use,
    keystore_type,
    creation_time,
    creator,
    activation_time
FROM v$encryption_keys
ORDER BY creation_time;
PROMPT == Encryption key information from v$encryption_keys ====================
SELECT
    key_id,key_use, keystore_type, backed_up,creation_time,creator,
    creator_pdbname,activation_time,activating_pdbname,con_id
FROM v$encryption_keys ORDER BY creation_time;

-- list wallet information
PROMPT == Wallet information from v$wallet =====================================
SELECT * FROM v$wallet;

-- list information about TDE TS
PROMPT == List of encrypted tablespaces ========================================
SELECT tablespace_name, encrypted FROM dba_tablespaces WHERE encrypted ='YES';

PROMPT == Details about encrypted tablespaces ==================================
SELECT
    t.ts#,t.name, 
    et.encryptionalg,
    et.encryptedts,
    et.blocks_encrypted,
    et.blocks_decrypted,
    et.con_id
FROM v$tablespace t, v$encrypted_tablespaces et
WHERE t.ts# = et.ts#;

-- list information about TDE column
PROMPT == Details about encrypted table columns ================================
SELECT * FROM dba_encrypted_columns;

SPOOL OFF
-- EOF -------------------------------------------------------------------------
