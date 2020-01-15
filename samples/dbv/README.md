# Oracle Database Vault

This example shows how to setup and configure Oracle Database Vault in a multitenant/container database ([tdbv01](tdbv01/README.md)) or single tenant database ([tdbv02](tdbv02/README.md)). The `docker-compose.yml` does include both services with the following setup

- Database services *tdbv01* respectively *tdbv02* based on an Oracle Docker image for Oracle 19.5.0.0. This can be customized to any Release update from 12c up to 19c.
- Container name and hostname is set to the service name
- Define volume for database using bind mount of `${DOCKER_VOLUME_BASE}/dbv/tdbv01` respectively `${DOCKER_VOLUME_BASE}/dbv/tdbv02` 
- Add bind mount to the service configuration folder `./tdbv01` respectively `./tdbv02` to provide the setup and configuration scripts.
- Create a database with the following settings
  - Oracle SID *TDBV01* or rather *TDBV02*
  - Setup database using customized *dbca* template `dbca19.0.0_custom.dbc.tmpl` 
  - Add *SCOTT* and *TVD_HR* schemas.
  - Setup and configure a couple of default *DV_OWNER* and *DV_ACCTMGR* users.

The scripts to setup the database are located in [tdbv01/setup](tdbv01/setup/) respectively [tdbv02/setup](tdbv02/setup/). The README.md files in these folders do provide a detailed overview about the different scripts.

## Run the Database Vault Use Case with a Container Database

Update the `docker-compose.yml` file and set the desired base image. Default is 19.5.0.0.

```bash
vi docker-compose.yml
```

Create a container **dbv** using `docker-compose`. This will also create an initial database *TDBV01*.

```bash
docker-compose up -d tdbv01
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

User and Schemas created during database vault configuration:

- c##sec_admin
- c##sec_accts_admin
- c##dbv_acctmgr_root_backup
- c##dbv_owner_root_backup

You now can shutdown and destroy the container using `docker-compose`. Database will remain since it is stored on a volume / bind-mount folder.

```bash
docker-compose down
```

## Run the Database Vault Use Case with a regular Database

Update the `docker-compose.yml` file and set the desired base image. Default is 19.5.0.0.

```bash
vi docker-compose.yml
```

Create a container **dbv** using `docker-compose`. This will also create an initial database *TDBV01*.

```bash
docker-compose up -d tdbv02
```

Monitor the progress of database creation using `docker-compose`.

```bash
docker-compose logs -f
```

The database is ready when you see the following message in your docker logs.

```bash
---------------------------------------------------------------
 - DATABASE TDBV02 IS READY TO USE!
---------------------------------------------------------------
```

User and Schemas created during database vault configuration:

- sec_admin
- sec_accts_admin
- dbv_acctmgr_root_backup
- dbv_owner_root_backup

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
- **INSTANCE_INIT** Folder for customize setup and startup. The database create script will look for a folder `setup` during initial setup or `startup` during each container startup. All bash `.sh` scripts as well sql `.sql`  script will be executed. Make sure to add a sequence to keep the order of the scripts. In this use case we will set the *INSTANCE_INIT* to `/u01/config` which is mapped to the local [tdbv01](tdbv01) respectively [tdbv02](tdbv02) folder. `/u01/config`  
- **ORADBA_TEMPLATE_PREFIX** Prefix to use a custom dbca template or the general purpose default template. By default this variable is not set. In this case dbca will use the general purpose template with the starter database. If set to `custom_` dbca will use a custom template to create a fresh database. This will take longer since the database will be create from scratch.
