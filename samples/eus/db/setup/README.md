This folder contains all files executed after the database instance is initially created. Currently only bash scripts (.sh) as well SQL scripts (.sql) are supported. 

| File                      | Purpose                                                                                   |
|---------------------------|-------------------------------------------------------------------------------------------|
|[01_create_scott.sql](01_create_scott.sql)| Wrapper script for ``utlsampl.sql`` to create the SCOTT schema                            |
|[02_create_tvd_hr.sql](02_create_tvd_hr.sql)| Script to create the TVD_HR schema. TVD_HR schema corresponds to Oracle's standard HR schema. The data has been adjusted so that it matches the example LDAP data of *trivadislabs.com* |
|[03_eus_registration.sh](03_eus_registration.sh)| Script to register database in OUD instance using `dbca`. |
|[04_eus_config.sql](04_eus_config.sql)| Script to create the EUS schemas for global shared and private schemas. |
|[05_eus_mapping.sh](05_eus_mapping.sh)| Script to create the EUS mapping to different global shared and private schemas as well global roles.|
|[06_keystore_import_trustcert.sh](06_keystore_import_trustcert.sh)| Script to import the trust certificate into java keystore. |
