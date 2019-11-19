This folder contains all files executed after the database instance is initially created. Currently only bash scripts (.sh) as well SQL scripts (.sql) are supported. 

| File                                                   | Purpose                                  |
|--------------------------------------------------------|------------------------------------------|
| [01_check_unified_audit.sh](01_check_unified_audit.sh) | Script to create the SCOTT schema.       |
| [02_create_scott_pdb1.sql](02_create_scott_pdb1.sql)   | Main script to create the TVD_HR schema. |
