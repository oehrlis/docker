--------------------------------------------------------------------------------
--  OraDBA - Oracle Database Infrastructur and Security, 5630 Muri, Switzerland
--------------------------------------------------------------------------------
--  Name......: sdenc_dbf_off_enc_files.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
--  Editor....: Stefan Oehrli
--  Date......: 2024.03.05
--  Revision..:  
--  Purpose...: This PL/SQL script is designed to process database files, specifically
--              focusing on identifying files across different chunks based on their
--              sizes and preparing them for encryption commands. It dynamically
--              groups files into chunks, excluding files from specified tablespaces,
--              and generates ALTER DATABASE DATAFILE commands for encryption.
--              The script is optimized for readability and maintainability, with
--              clear separation of logic for collecting file information and
--              displaying chunk summaries.
--
--  Reference.: SYS (or grant manually to a DBA)
--  License...: Apache License Version 2.0, January 2004 as shown
--              at http://www.apache.org/licenses/
--------------------------------------------------------------------------------
-- ALTER SYSTEM SET "_disable_directory_link_check"=TRUE
--              COMMENT='  - Directory SymLink Desupport- March 22, 2024 by Stefan'
--              SCOPE=SPFILE;
-- ALTER SYSTEM SET "_kolfuseslf"=TRUE
--              COMMENT='  - Directory SymLink Desupport- March 22, 2024 by Stefan'
--              SCOPE=SPFILE;

-- create temporary type
CREATE OR REPLACE TYPE t_table_tsnames_type AS
    TABLE OF VARCHAR2(30 CHAR)
/

-- Anonymous PL/SQL Block to configure audit environment
SET SERVEROUTPUT ON
SET LINESIZE 160 PAGESIZE 200
SPOOL sdenc_dbf_off_enc_files.log
DECLARE
    ----------------------------------------------------------------------------
    -- Begin of Customization --------------------------------------------------
    ----------------------------------------------------------------------------
        -- list of tablespaces to skip during encryption
        t_skip_tablespaces t_table_tsnames_type := t_table_tsnames_type('SYSTEM', 'SYSAUX', 'UNDOTBS1' );
    ----------------------------------------------------------------------------
    -- End of Customization ----------------------------------------------------
    ----------------------------------------------------------------------------
    
    -- Types
    SUBTYPE text_type IS VARCHAR2(2000 CHAR);       -- NOSONAR G-2120 keep function independent
    SUBTYPE path_type IS VARCHAR2(266 CHAR);        -- NOSONAR G-2120 keep function independent
    
    -- Define a record type to store file information and calculated chunk information.
    TYPE r_file_rec_type IS RECORD (
            id        PLS_INTEGER,
            chunk_id  PLS_INTEGER,
            file_id   v$datafile.file#%TYPE,
            file_name v$datafile.name%TYPE,
            ts#       PLS_INTEGER,
            file_size v$datafile.bytes%TYPE -- Individual file size, used later to calculate chunk sizes.
    );
    l_admin_dir path_type;
    l_file sys.utl_file.file_type;
    l_sql text_type; -- local variable for dynamic SQL
BEGIN

    sys.dbms_system.get_env('BE_ORA_ADMIN_SID', l_admin_dir);
    l_sql := 'CREATE OR REPLACE DIRECTORY cda_adhoc AS ''' || l_admin_dir || '/adhoc''';
    EXECUTE IMMEDIATE l_sql;

    sys.dbms_output.put_line('-----------------------------------------------------------');
    sys.dbms_output.put_line('- create scripts to encrypt/decrypt datafiles');
    -- Collect file information from database while excluding specified tablespaces.
    << collect_file_info >> FOR r_file IN (
        SELECT
            df.file#,
            df.name,
            df.ts#,
            df.bytes
        FROM
                 v$datafile df
            JOIN v$tablespace ts ON df.ts# = ts.ts#
        WHERE
            ts.name NOT IN (SELECT * FROM TABLE ( t_skip_tablespaces ) )   -- Exclude specified tablespaces.
        ORDER BY
            df.bytes DESC
    ) LOOP
        sys.dbms_output.put_line('- process datafile '||r_file.file#);
        -- create bash script for encrypt datafile
        --sys.dbms_output.put_line('ALTER DATABASE DATAFILE '||r_file.file#||' ENCRYPT;');
        l_file := sys.utl_file.fopen('CDA_ADHOC', 'senc_encrypt_file_'||r_file.file#||'.sh', 'W');
        sys.utl_file.put_line(l_file, '${ORACLE_HOME}/bin/sqlplus -S -L /nolog <<EOFSQL');
        sys.utl_file.put_line(l_file, '    CONNECT / AS SYSDBA');
        sys.utl_file.put_line(l_file, '    ALTER DATABASE DATAFILE '||r_file.file#||' ENCRYPT;');
        sys.utl_file.put_line(l_file, 'EOFSQL');
        sys.utl_file.fclose(l_file);

        -- create bash script for encrypt datafile
        --sys.dbms_output.put_line('ALTER DATABASE DATAFILE '||r_file.file#||' DECRYPT;');
        l_file := sys.utl_file.fopen('CDA_ADHOC', 'senc_decrypt_file_'||r_file.file#||'.sh', 'W');
        sys.utl_file.put_line(l_file, '${ORACLE_HOME}/bin/sqlplus -S -L /nolog <<EOFSQL');
        sys.utl_file.put_line(l_file, '    CONNECT / AS SYSDBA');
        sys.utl_file.put_line(l_file, '    ALTER DATABASE DATAFILE '||r_file.file#||' DECRYPT;');
        sys.utl_file.put_line(l_file, 'EOFSQL');
        sys.utl_file.fclose(l_file);
    END LOOP collect_file_info;
    l_sql := 'DROP DIRECTORY cda_adhoc';
    EXECUTE IMMEDIATE l_sql;
    
EXCEPTION
    -- Capture and output any exceptions that occur during execution .
    WHEN OTHERS THEN  -- NOSONAR
        sys.dbms_output.put_line('Error: '
                                 || sqlerrm
                                 || sys.dbms_utility.format_error_backtrace);
END;
/

-- drop temporary type
DROP TYPE t_table_tsnames_type
/

SPOOL OFF
-- EOF -------------------------------------------------------------------------