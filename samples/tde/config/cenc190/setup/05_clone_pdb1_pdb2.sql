----------------------------------------------------------------------------
-- OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
----------------------------------------------------------------------------
--  Name......: 05_clone_pdb1_pdb2.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
--  Editor....: Stefan Oehrli
--  Date......: 2019.03.18
--  Revision..:  
--  Purpose...: Script to clone PDB1 to PDB2
--  Notes.....:  
--  Reference.: SYS (or grant manually to a DBA)
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------
-- set the current
--ALTER PLUGGABLE DATABASE pdb1 CLOSE;

CREATE PLUGGABLE DATABASE pdb2 FROM pdb1
  FILE_NAME_CONVERT=('PDB1','PDB2','pdb1','pdb2');

--ALTER PLUGGABLE DATABASE pdb1 OPEN READ WRITE;
ALTER PLUGGABLE DATABASE pdb2 OPEN READ WRITE;

--ALTER PLUGGABLE DATABASE pdb1 SAVE STATE;
ALTER PLUGGABLE DATABASE pdb2 SAVE STATE;
-- EOF ---------------------------------------------------------------------