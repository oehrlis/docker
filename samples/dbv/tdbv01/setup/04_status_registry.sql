----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 04_status_registry.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.11.28
--  Revision..:  
--  Purpose...: Select status of dba_registry
--  Notes.....:  
--  Reference.: SYS (or grant manually to a DBA)
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------

-- connect as SYSDBA to the root container
CONNECT / as SYSDBA

---------------------------------------------------------------------------
-- define default values / format
SET LINESIZE 160 PAGESIZE 200
COL reg_comp_name HEAD "Component Name" FOR a50
COL reg_version HEAD "Version" FOR a15
COL reg_status HEAD "Status" FOR a11
COL reg_schema HEAD "Schema" FOR a15
COL reg_modified HEAD "Modified" FOR a20

---------------------------------------------------------------------------
-- Query dba_registry
SELECT 
    comp_name reg_comp_name,
    version reg_version,
    status reg_status,
    schema reg_schema,
    modified reg_modified
FROM
    dba_registry;
EXIT;
-- EOF ---------------------------------------------------------------------