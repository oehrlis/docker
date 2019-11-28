# Setup Scripts

This folder contains all files executed after the database instance is initially created. Currently only bash scripts (.sh) as well SQL scripts (.sql) are supported. 

- [00_prepare_env_pdb1.sh](00_prepare_env_pdb1.sh) Script to add a tnsname entry for the PDB PDB1.
- [01_create_pdb_pdb1.sql](01_create_pdb_pdb1.sql) Create a PDB (pdb1) used for PDB DBV engineering.
- [02_create_scott_pdb1.sql](02_create_scott_pdb1.sql) Script to create the SCOTT schema in PDB.
- [03_create_tvd_hr_pdb1.sql](03_create_tvd_hr_pdb1.sql) Main script to create the TVD_HR schema in PDB incl EUS VPD.
- [04_status_registry.sql](04_status_registry.sql) Select status of dba_registry.
- [05_prepare_dbv_cdb.sql](05_prepare_dbv_cdb.sql) Prepare DBV in CDB.
- [06_prepare_dbv_pdb1.sql](06_prepare_dbv_pdb1.sql) Prepare DBV in PDB.
