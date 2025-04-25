--------------------------------------------------------------------------------
--  OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
--------------------------------------------------------------------------------
--  Name......: 15_encrypt_ts.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@accenture.com
--  Editor....: Stefan Oehrli
--  Date......: 2025.01.17
--  Version...: v1.0.0
--  Purpose...: Run encrypt Tablespaces
--  Notes.....: SYS (or grant manually to a DBA)
--  Reference.: --
--  License...: Apache License Version 2.0
--------------------------------------------------------------------------------
ALTER SESSION SET CONTAINER=pdb1;
ALTER TABLESPACE users ENCRYPTION ONLINE USING 'AES256' ENCRYPT;
ALTER TABLESPACE audit_data ENCRYPTION ONLINE USING 'AES256' ENCRYPT;
-- EOF -------------------------------------------------------------------------