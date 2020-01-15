----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: hashcat.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.12.07
--  Usage.....: @hashcat
--  Purpose...: Script to dump S:/SHA1 password hashes for hashcat
--  Notes.....: 
--  Reference.: 
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------
SET HEAD OFF
SET FEEDBACK OFF
SET ECHO OFF
SET LINESIZE 160 PAGESIZE 200
SPOOL /u01/config/etc/hash_list.txt
COLUMN hashcat FORMAT A90
SELECT
    name ||':'||
    substr(regexp_substr(spare4,'S\:(.+);',1,1,'i',1), 1, 40) ||':'||
    substr(regexp_substr(spare4,'S\:(.+);',1,1,'i',1), 41, 20) hashcat
FROM user$
WHERE spare4 IS NOT NULL 
AND substr(regexp_substr(spare4,'S\:(.+);',1,1,'i',1), 1, 40) <> '0000000000000000000000000000000000000000';
SPOOL OFF
-- EOF ---------------------------------------------------------------------
