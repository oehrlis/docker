# Oracle Database Vault

This example shows how to setup and configure an Oracle Multitenant Database including Oracle Database Vault. The `docker-compose.yml` does include the following customization:

- Database services *dbv* based on an Oracle Docker image for Oracle 19.5.0.0. This can be customized to any Release update from 12c to 19c.
- Container name and hostname is set to *dbv*
- Define volume for database using bind mount of `${DOCKER_VOLUME_BASE}/dbv`
- Add bind mount to `./db` to add setup and configuration scripts.
- Create a container database with the following settings
  - Oracle SID *TDBV01*
  - Oracle default PDB *PDB0* plus a second PDB for DB vault *PDB1*
  - Setup database using customized *dbca* template `dbca19.0.0_custom.dbc.tmpl` see also [README.md](db/etc/README.md)
  - Add *SCOTT* and *TVD_HR* schema to *PDB1*.
  - Setup and configure a couple of default *DV_OWNER* and *DV_ACCTMGR* user.

The scripts to setup the database are located in [db/setup](db/setup/). The [README.md](db/setup/README.md) file in this folder provides a detailed overview about the different scripts.

## Run the Database Vault Use Case

Update the `docker-compose.yml` file and set the desired base image. Default is 19.5.0.0.

```bash
vi docker-compose.yml
```

Create a container **dbv** using `docker-compose`. This will also create an initial database *TDBV01*.

```bash
docker-compose up -d
```

Monitor the progress of database creation using `docker-compose`.

```bash
docker-compose logs -f
```

The database is ready when you see the following message in your docker logs.

```bash
---------------------------------------------------------------
 - DATABASE TDBV01 IS READY TO USE!
---------------------------------------------------------------
```

You now can shutdown and destroy the container using `docker-compose`. Database will remain since it is stored on a volume / bind-mount folder.

```bash
docker-compose down
```

## Customization

By default the volume will be created in the directory specified by the environment variable *DOCKER_VOLUME_BASE*. If the environment variable is not specified, it will use the default value from ``*.env`` which is the current path. Beside the usual changes e.g. container name, hostname, ports etc. you can configure how the DB itself will be created by specify several configuration parameter.

- **ORACLE_SID** Default Oracle SID. Usually it will default to the variable which has been specified during build. A custom SID can / should be specified. 
- **ORACLE_PDB** Default PDB name, if *CONTAINER* is set to `TRUE` (default `PDB1`)
- **CONTAINER** Flag to create a container or single tenant database. Default set to `FALSE`.
- **ORACLE_PWD** Custom admin password for common admin user like SYS and SYSTEM. If not specified a random password will be generated.
- **INSTANCE_INIT** Folder for customize setup and startup. The database create script will look for a folder `setup` during initial setup or `startup` during each container startup. All bash `.sh` scripts as well sql `.sql`  script will be executed. Make sure to add a sequence to keep the order of the scripts. In this use case we will set the *INSTANCE_INIT* to `/u01/config` which is mapped to the local [db](db) folder. `/u01/config`  
- **ORADBA_TEMPLATE_PREFIX** Prefix to use a custom dbca template or the general purpose default template. By default this variable is not set. In this case dbca will use the general purpose template with the starter database. If set to `custom_` dbca will use a custom template to create a fresh database. This will take longer since the database will be create from scratch.
