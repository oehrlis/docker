# Oracle Database Unified Audit

This example shows how to enable Unified Audit an Oracle database in a Docker Container. The persistent data (e.g. data files, config files etc.) is stored on an external volume. The startup script `01_check_unified_audit.sh` will check if Oracle Unified Audit is enabled if not it will stop the database, relink Oracle and start the database again. Some prerequisites and basic principles:

- `01_check_unified_audit.sh` does check if Oracle Unified Audit is enabled. If not it will stop the database, relink Oracle and start the database again
- Script can be put in the startup as well setup folder.
- Setup folder does provide a couple of additional Scripts

| File                                                   | Purpose                                          |
|--------------------------------------------------------|--------------------------------------------------|
| [01_check_unified_audit.sh](01_check_unified_audit.sh) | Script to check and enable unified audit.        |
| [02_create_scott_pdb1.sql](02_create_scott_pdb1.sql)   | Script to create the SCOTT schema.               |
| [03_create_tvd_hr_pdb1.sql](03_create_tvd_hr_pdb1.sql) | Main script to create the TVD_HR schema in PDB1. |
| [04_config_audit.sql](04_config_audit.sql)             | Script to config unified audit.                  |
| [05_clone_pdb1_pdb2.sql](05_clone_pdb1_pdb2.sql)       | Script to clone PDB1 to PDB2.                    |

## Run the Oracle Database Unified Audit Use Case

Update the `docker-compose.yml` file and set the desired base image. Default is 19.4.0.0.

```bash
vi docker-compose.yml
```

Create a container **tua190**, **tua180** or **tua122** using `docker-compose`. This will also create the corresponding database *TUA190*, *TUA180* respectively *TUA122*. It is important to specify the service when calling `docker-compose` otherwise all three container and databases will be created.

```bash
docker-compose up -d TUA190
```

Monitor the progress of database creation using `docker-compose`.

```bash
docker-compose logs -f
```

The database is ready when you see the following message in your docker logs.

```bash
---------------------------------------------------------------
 - DATABASE TUA190 IS READY TO USE!
---------------------------------------------------------------
```

You now can shutdown and destroy the container using `docker-compose`. Database will remain since it is stored on a voluem / bind-mount folder.

```bash
docker-compose down
```

Re-create the container **tua190** using `docker-compose`. The database *TUA190* will be reused. The run script `50_run_database.sh` will make sure make sure, that the scripts in the [startup](config/startup) folder are executed. This includes `01_check_unified_audit.sh`.

```bash
docker-compose up -d TUA190
```

Monitor the progress of database startup / datapach using `docker-compose`.

```bash
docker-compose logs -f
```

Connect to the database via Shell or SQLPlus and check your Oracle Audit Configuration.

## Customization

By default the volume will be created in the directory specified by the environment variable *DOCKER_VOLUME_BASE*. If the environment variable is not specified, it will use the default value from ``*.env`` which is the current path. Beside the usual changes e.g. container name, hostname, ports etc. you can configure how the DB itself will be created by specify several configuration parameter.

- **ORACLE_SID** Default Oracle SID. Usually it will default to the variable which has been specified during build. A custom SID can / should be specified. Default is either *TUA190*, *TUA180* or *TUA122*.
- **ORACLE_PDB** Default PDB name, if *CONTAINER* is set to `TRUE` (default `PDB1`)
- **CONTAINER** Flag to create a container or single tenant database. Default set to `FALSE`.
- **ORACLE_PWD** Custom admin password for common admin user like SYS and SYSTEM. If not specified a random password will be generated.
- **INSTANCE_INIT** Folder for customize setup and startup. The database create script will look for a folder `setup` during initial setup or `startup` during each container startup. All bash `.sh` scripts as well sql `.sql`  script will be executed. Make sure to add a sequence to keep the order of the scripts. In this use case we will set the *INSTANCE_INIT* to `/u01/config` which is mapped to the local [config](config) folder. `/u01/config`  
- **ORADBA_TEMPLATE_PREFIX** Prefix to use a custom dbca template or the general purpose default template. By default this variable is not set. In this case dbca will use the general purpose template with the starter database. If set to `custom_` dbca will use a custom template to create a fresh database. This will take longer since the database will be create from scratch.
