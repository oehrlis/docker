--------------------------------------------------------------------------------
--  OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
--------------------------------------------------------------------------------
--  Name......: ssenc_info_html.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
--  Editor....: Stefan Oehrli
--  Date......: 2025.04.25
--  Version...: v0.1.0
--  Purpose...: HTML report of TDE configuration
--  Notes.....:  
--  Reference.: Requires SYS, SYSDBA or SYSKM privilege
--------------------------------------------------------------------------------

SET MARKUP HTML ON ENTMAP OFF SPOOL ON PREFORMAT OFF
SET LINESIZE 180 PAGESIZE 1000
SET FEEDBACK OFF VERIFY OFF HEADING ON TERMOUT OFF

-- Set date format
ALTER SESSION SET nls_timestamp_tz_format='DD.MM.YYYY HH24:MI:SS';

-- Set output HTML file
SPOOL ssenc_info.html

PROMPT <h1>🔐 TDE Configuration Report</h1>
PROMPT <hr>

PROMPT <h2>▶️ Pending Parameters in SPFILE</h2>
SELECT vsp.name,
       NVL(vp.value, 'undef') AS memory,
       NVL(vsp.value, 'undef') AS spfile,
       vsp.ISSPECIFIED
FROM   v$parameter vp,
       v$spparameter vsp
WHERE  vsp.name IN ('wallet_root', 'tde_configuration',
                    'tablespace_encryption', 'encrypt_new_tablespaces')
  AND  vsp.name = vp.name
  AND  NVL(vsp.value, 'undef') != NVL(vp.value, 'undef')
  AND  vsp.isspecified = 'TRUE'
ORDER BY vsp.name;

PROMPT <h2>▶️ Regular TDE Parameters</h2>
SELECT  LOWER(a.ksppinm) AS "Parameter",
        DECODE(c.con_id, 0, 'CDB',
          (SELECT pdb.name || ' (' || pdb.con_id || ')'
           FROM v$pdbs pdb WHERE pdb.con_id = c.con_id)) AS "Container",
        b.ksppstvl AS "Session",
        c.ksppstvl AS "Instance"
FROM    x$ksppi a, x$ksppcv b, x$ksppsv c
WHERE   a.indx = b.indx AND a.indx = c.indx
  AND   UPPER(a.ksppinm) IN (
           'WALLET_ROOT', 'TDE_CONFIGURATION',
           'TABLESPACE_ENCRYPTION', 'ENCRYPT_NEW_TABLESPACES',
           'EXTERNAL_KEYSTORE_CREDENTIAL_LOCATION'
       )
ORDER BY a.ksppinm, c.con_id;

PROMPT <h2>▶️ Hidden TDE Parameters</h2>
SELECT  LOWER(a.ksppinm) AS "Parameter",
        DECODE(c.con_id, 0, 'CDB',
          (SELECT pdb.name || ' (' || pdb.con_id || ')'
           FROM v$pdbs pdb WHERE pdb.con_id = c.con_id)) AS "Container",
        DECODE(p.isses_modifiable, 'FALSE', NULL, NULL, NULL, b.ksppstvl) AS "Session",
        c.ksppstvl AS "Instance",
        DECODE(p.isses_modifiable, 'FALSE', 'F', 'TRUE', 'T') AS "S",
        DECODE(p.issys_modifiable, 'FALSE', 'F', 'IMMEDIATE', 'I', 'DEFERRED', 'D') AS "I",
        DECODE(p.isdefault, 'FALSE', 'F', 'TRUE', 'T') AS "D",
        a.ksppdesc AS "Description"
FROM    x$ksppi a, x$ksppcv b, x$ksppsv c, v$parameter p
WHERE   a.indx = b.indx AND a.indx = c.indx
  AND   p.name(+) = a.ksppinm
  AND   UPPER(a.ksppinm) IN (
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
ORDER BY a.ksppinm, c.con_id;

PROMPT <h2>▶️ TDE Master Keys</h2>
SELECT
    key_id,
    key_use,
    keystore_type,
    backed_up,
    creation_time,
    creator,
    creator_pdbname,
    activation_time,
    activating_pdbname,
    con_id
FROM v$encryption_keys
ORDER BY creation_time;

PROMPT <h2>▶️ Encrypted Tablespaces</h2>
SELECT tablespace_name, encrypted FROM dba_tablespaces WHERE encrypted = 'YES';

PROMPT <h2>▶️ Encrypted Table Columns</h2>
SELECT owner, table_name, column_name, encryption_alg, salt, integrity_alg
FROM dba_encrypted_columns;

PROMPT <hr>
PROMPT <h3>✅ Report generated on SYSDATE</h3>

SPOOL OFF
SET MARKUP HTML OFF
SET FEEDBACK ON VERIFY ON TERMOUT ON
-- EOF -------------------------------------------------------------------------
