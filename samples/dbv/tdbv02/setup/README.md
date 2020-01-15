# Setup Scripts

This folder contains all files executed after the database instance is initially created. Currently only bash scripts (.sh) as well SQL scripts (.sql) are supported. 

- [02_create_scott.sql](02_create_scott.sql) Script to create the SCOTT schema in PDB.
- [03_create_tvd_hr.sql](03_create_tvd_hr.sql) Main script to create the TVD_HR schema in PDB incl EUS VPD.
- [04_status_registry.sql](04_status_registry.sql) Select status of dba_registry.
- [05_prepare_dbv.sql](05_prepare_dbv.sql) Prepare DBV configuration.
