This folder contains all files executed after the OUD instance is initially created. Currently only bash scripts (.sh) LDIF files (.ldif) as well dsconfig batch files (.conf) are supported.


| File                                                               | Purpose                                                                                                      |
|--------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------|
| [00_init_environment](00_init_environment)                         | File for setting the instance-specific environment. The setup scripts are based on the OUD Base environment. |
| [01_create_eus_instance.sh](01_create_eus_instance.sh)             | Script to create the OUD instance with EUS context using oud-setup.                                          |
| [02_config_basedn.sh](02_config_basedn.sh)                         | Wrapper script to configure base DN and add ou's for users and groups.                                       |
| [02_config_basedn.ldif](02_config_basedn.ldif)                     | LDIF file loaded by wrapper script `02_config_basedn.sh`.                                                    |
| [03_config_eus_realm.sh](03_config_eus_realm.sh)                   | Wrapper script to configure EUS realm to the OUD instance.                                                   |
| [03_config_eus_realm.ldif](03_config_eus_realm.ldif)               | LDIF file loaded by wrapper script `03_config_eus_realm.sh`.                                                 |
| [04_config_oud.sh](04_config_oud.sh)                               | Wrapper script to configure the OUD instance.                                                                |
| [04_config_oud.conf](04_config_oud.conf)                           | dsconfig batch file loaded by wrapper script `04_config_oud.sh`.                                             |
| [05_update_directory_manager.sh](05_update_directory_manager.sh)   | Adjust cn=Directory Manager to use new password storage scheme                                               |
| [06_create_root_users.sh](06_create_root_users.sh)                 | Wrapper script to create additional root user.                                                               |
| [06_create_root_users.conf](06_create_root_users.conf)             | dsconfig batch file loaded by wrapper script `06_create_root_users.sh`.                                      |
| [06_create_root_users.ldif](06_create_root_users.ldif)             | LDIF file loaded by wrapper script `06_create_root_users.sh`.                                                |
| [07_create_eusadmin_users.sh](07_create_eusadmin_users.sh)         | Script to create EUS Context Admin according to MOS Note 1996363.1.                                          |
| [08_create_demo_users.sh](08_create_demo_users.sh)                 | Wrapper script to create a couple of users and groups.                                                       |
| [08_create_demo_users.ldif](08_create_demo_users.ldif)             | LDIF file loaded by wrapper script `08_create_demo_users.sh`.                                                |
| [09_migrate_keystore.sh](09_migrate_keystore.sh)                   | Script to migrate the java keystore to PKCS12                                                                |
| [10_export_trustcert_keystore.sh](10_export_trustcert_keystore.sh) | Script to export the java keystore to PKCS12                                                                 |
| [11_create_eus_ou_tree.conf](11_create_eus_ou_tree.conf)           | dsconfig batch file loaded by wrapper script `11_create_eus_ou_tree.sh`.                                     |
| [11_create_eus_ou_tree.ldif](11_create_eus_ou_tree.ldif)           | LDIF file loaded by wrapper script `03_config_eus_realm.sh`.                                                 |
| [11_create_eus_ou_tree.sh](11_create_eus_ou_tree.sh)               | Script to create additional root user.                                                                       |
