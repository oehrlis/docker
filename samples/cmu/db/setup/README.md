This folder contains all files executed after the database instance is initially created. Currently only bash scripts (.sh) as well SQL scripts (.sql) are supported. 

| File                      | Purpose                                                                                   |
|---------------------------|-------------------------------------------------------------------------------------------|
|[00_setup_init.sh](00_setup_init.sh)| Initialization of environment variables. This file is also sourced in other bash scripts. |
|[01_create_scott.sql](01_create_scott.sql)| Wrapper script for ``utlsampl.sql`` to create the SCOTT schema                            |
|[02_create_tvd_hr.sql](02_create_tvd_hr.sql)| Script to create the TVD_HR schema. TVD_HR schema corresponds to Oracle's standard HR schema. The data has been adjusted so that it matches the example LDAP data of *trivadislabs.com* |
|[03_create_krb_os_conf.sh](03_create_krb_os_conf.sh)| Script to create the Kerberos configuration. Copy the keytab file, create a ``krb5.conf`` configuration file and adjust ``sqlnet.ora`` with Kerberos related parameter. |
|[04_create_krb_db_conf.sql](04_create_krb_db_conf.sql)| Configure the database for Kerberos. Reset *os_authent_prefix* to null, add a database user with Kerberos authentication and restart the database. |
|[05_create_cmu_os_conf.sh](05_create_cmu_os_conf.sh)| Script to create the CMU configuration. Generate a wallet password, upgrade the Oracle password file to 12.2, create a ``dsi.ora`` file and create an Oracle wallet with the Active Directory credentials and the root certificate. |
|[06_create_cmu_db_conf.sql](06_create_cmu_db_conf.sql)| Configure the database for CMU. Adjust the init.ora parameter *ldap_directory_access* and *ldap_directory_sysauth*, create a global shared  user *TVD_GLOBAL_USERS*, create global roles *MGMT_ROLE* and *RD_ROLE*, create a global private user ADAMS and create a global private user FLEMING with SYSDBA rights |
