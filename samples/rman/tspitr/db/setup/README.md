This folder contains all files executed after the database instance is initially created. Currently only bash scripts (.sh) as well SQL scripts (.sql) are supported. 

| File                                                   | Purpose                                  |
|--------------------------------------------------------|------------------------------------------|
| [00_prepare_env_pdbpitr.sh](00_prepare_env_pdbpitr.sh) | Script to prepare the PDB environment e.g TNSNAMES, PATH_PREFIX etc .       |
| [01_create_pdb_pdbpitr.sql](01_create_pdb_pdbpitr.sql) | Script to create the PDB *PDBPITR*.       |
| [02_create_scott_pdbpitr.sql](02_create_scott_pdbpitr.sql)   | Main script to create the SCHOTT schema in *PDBPITR*. |
| [03_create_tvd_hr_pdbpitr.sql](03_create_tvd_hr_pdbpitr.sql)   | Main script to create the SCHOTT schema in *PDBPITR*. |
