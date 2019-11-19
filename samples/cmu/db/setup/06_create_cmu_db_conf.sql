----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 06_create_cmu_db_conf.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.04.04
--  Revision..:  
--  Purpose...: Script to apply cmu configuration
--  Notes.....:  
--  Reference.: SYS (or grant manually to a DBA)
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------
-- set the init.ora parameter for LDAP
ALTER SYSTEM SET ldap_directory_access = 'PASSWORD';
ALTER SYSTEM SET ldap_directory_sysauth = YES SCOPE=SPFILE;
STARTUP FORCE;

-- cleanup section 
DECLARE
vcount INTEGER :=0;
BEGIN

-- remove tvd_global_users if exists
SELECT count(1) INTO vcount FROM dba_users WHERE username = 'TVD_GLOBAL_USERS';
IF vcount != 0 THEN
EXECUTE IMMEDIATE ('DROP USER tvd_global_users CASCADE');
END IF;

-- remove adams if exists
SELECT count(1) INTO vcount FROM dba_users WHERE username = 'ADAMS';
IF vcount != 0 THEN
EXECUTE IMMEDIATE ('DROP USER adams CASCADE');
END IF;

-- remove fleming if exists
SELECT count(1) INTO vcount FROM dba_users WHERE username = 'FLEMING';
IF vcount != 0 THEN
EXECUTE IMMEDIATE ('DROP USER fleming CASCADE');
END IF;

-- remove rd_role if exists
SELECT count(1) INTO vcount FROM dba_roles WHERE role = 'RD_ROLE';
IF vcount != 0 THEN
EXECUTE IMMEDIATE ('DROP ROLE rd_role');
END IF;

-- remove mgmt_role if exists
SELECT count(1) INTO vcount FROM dba_roles WHERE role = 'MGMT_ROLE';
IF vcount != 0 THEN
EXECUTE IMMEDIATE ('DROP ROLE mgmt_role');
END IF;

END;
/

-- create the global shared cmu user tvd_global_users
CREATE USER tvd_global_users IDENTIFIED GLOBALLY AS 'CN=Trivadislabs Users,OU=Groups,DC=trivadislabs,DC=com';
GRANT create session TO tvd_global_users ;
GRANT SELECT ON v_$session TO tvd_global_users ;

-- create a global mgmt role
CREATE ROLE mgmt_role IDENTIFIED GLOBALLY AS
'CN=Trivadis LAB Management,OU=Groups,DC=trivadislabs,DC=com';

-- create a global rd role
CREATE ROLE rd_role IDENTIFIED GLOBALLY AS
'CN=Trivadis LAB Developers,OU=Groups,DC=trivadislabs,DC=com';

-- create a global private user adams
CREATE USER adams IDENTIFIED GLOBALLY AS 'CN=Douglas Adams,OU=Research,OU=People,DC=trivadislabs,DC=com';
GRANT create session TO adams ;
GRANT SELECT ON v_$session TO adams ;

-- create a global private user fleming for sysdba
CREATE USER fleming IDENTIFIED GLOBALLY AS
'CN=Ian Fleming,OU=Information Technology,OU=People,DC=trivadislabs,DC=com';
GRANT SYSDBA TO fleming;
GRANT connect TO fleming;
GRANT SELECT ON v_$session TO fleming;
-- EOF ---------------------------------------------------------------------