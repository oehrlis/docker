----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 04_create_krb_db_conf.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.04.04
--  Revision..:  
--  Purpose...: Script to apply kerberos configuration
--  Notes.....:  
--  Reference.: SYS (or grant manually to a DBA)
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------
-- set the init.ora parameter os_authent_prefix to null
ALTER SYSTEM SET os_authent_prefix='' SCOPE=SPFILE;

-- create the user king as external user
DROP USER king CASCADE;
CREATE USER king IDENTIFIED EXTERNALLY AS 'king@TRIVADISLABS.COM';
GRANT CONNECT TO king;
GRANT SELECT ON v_$session TO king;

STARTUP FORCE;
-- EOF ---------------------------------------------------------------------