-- -----------------------------------------------------------------------------
-- Trivadis - Part of Accenture, Platform Factory - Transactional Data Platform
-- Saegereistrasse 29, 8152 Glattbrugg, Switzerland
-- -----------------------------------------------------------------------------
-- Name.......: load.sql
-- Author.....: Stefan Oehrli (oes) stefan.oehrli@accenture.com
-- Date.......: 2021.10.21
-- Revision...: 
-- Purpose....: Simple script to create some load on the DB
-- Notes......: --
-- Reference..: --
-- License....: Apache License Version 2.0, January 2004 as shown
--              at http://www.apache.org/licenses/
-- -----------------------------------------------------------------------------

UPDATE system.help SET seq=seq;
COMMIT;
UPDATE system.help SET seq=seq;
alter system switch LOGFILE;
COMMIT;
UPDATE system.help SET seq=seq;
COMMIT;
alter system switch LOGFILE;
UPDATE system.help SET seq=seq;
COMMIT;
UPDATE system.help SET seq=seq;
alter system switch LOGFILE;
COMMIT;
alter system switch LOGFILE;
-- --- EOF ---------------------------------------------------------------------