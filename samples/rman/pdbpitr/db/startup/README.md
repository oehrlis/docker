This folder contains all files executed after the database instance is started. Currently only bash scripts (.sh) as well SQL scripts (.sql) are supported. 

| File                                                                               | Purpose                                              |
|------------------------------------------------------------------------------------|------------------------------------------------------|
| [00_prepare_env_tspitr.sh](00_prepare_env_tspitr.sh)                               | Script to add a tnsname entry for the PDB TSPITR.    |
| [01_create_pdb_tspitr.sql](01_create_pdb_tspitr.sql)                               | Create a PDB (tspitr) used for PDB rman engineering. |
| [02_create_scott_tspitr.sql](02_create_scott_tspitr.sql)                           | Script to create the SCOTT schema in PDB.            |
| [10_cleanup_backups.sh](10_cleanup_backups.sh)                                     | RMAN remove backups from flash recovery area.        |
| [11_backup_database.sh](11_backup_database.sh)                                     | RMAN backup of database to flash recovery area.      |
| [20_create_some_load_tspitr.sql](20_create_some_load_tspitr.sql)                   | Script to create some load on scott.emp.             |
| [21_create_scott_tspitr_table_tspitr.sql](21_create_scott_tspitr_table_tspitr.sql) | Script to create a SCOTT TSPITR table.               |
| [22_backup_archivelogs.sh](22_backup_archivelogs.sh)                               | RMAN backup of archivelogs to flash recovery area.   |
| [23_screw_up_scott_tspitr.sql](23_screw_up_scott_tspitr.sql)                       | Script to screw up the SCOTT schema.                 |
| [30_execute_TSPITR_tspitr.sh](30_execute_TSPITR_tspitr.sh)                         | RMAN TSPITR for tablespace users.                    |
| [31_status_scott_tspitr.sql](31_status_scott_tspitr.sql)                           | Select status of SCOTT.emp.                          |
| [90_drop_pdb_tspitr.sql](90_drop_pdb_tspitr.sql)                                   | Drop PDB (tspitr) used for PDB security engineering. |