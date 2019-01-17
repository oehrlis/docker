----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 01_create_catalog_user.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2018.12.10
--  Revision..:  
--  Purpose...: Script to create the RMAN schema
--  Notes.....:  
--  Reference.: SYS (or grant manually to a DBA)
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------
CREATE TABLESPACE RMAN DATAFILE '/u01/oradata/TDB184R/rman01TDB184R.dbf' SIZE 10M AUTOEXTEND ON MAXSIZE 1024M;

CREATE USER rman IDENTIFIED BY rman 
    DEFAULT TABLESPACE rman
    TEMPORARY TABLESPACE temp
    QUOTA UNLIMITED ON users;

GRANT recovery_catalog_owner TO rman;

host rman cmdfile=01_create_catalog_user.rcv catalog rman/rman

-- EOF ---------------------------------------------------------------------