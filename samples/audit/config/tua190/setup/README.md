This folder contains all files executed after the database instance is initially created. Currently only bash scripts (.sh) as well SQL scripts (.sql) are supported. 

| File                                                   | Purpose                                          |
|--------------------------------------------------------|--------------------------------------------------|
| [01_check_unified_audit.sh](01_check_unified_audit.sh) | Script to check and enable unified audit.        |
| [02_create_scott_pdb1.sql](02_create_scott_pdb1.sql)   | Script to create the SCOTT schema.               |
| [03_create_tvd_hr_pdb1.sql](03_create_tvd_hr_pdb1.sql) | Main script to create the TVD_HR schema in PDB1. |
| [04_config_audit.sql](04_config_audit.sql)             | Script to config unified audit.                  |
| [05_clone_pdb1_pdb2.sql](05_clone_pdb1_pdb2.sql)       | Script to clone PDB1 to PDB2.                    |
