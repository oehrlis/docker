# Oracle 18.5.0.0 Database

A sample docker compose file to create an Oracle 18.4.0.0 database. The persistent data will be stored on an external volume. By default the volume will be created in the directory specified by the environment variable *DOCKER_VOLUME_BASE*. If the environment variable is not specified, it will use the default value from ``*.env`` which is the current path. Beside the usual changes e.g. container name, hostname, ports etc. you can configure how the DB itself will be created by specify several configuration parameter.

| Environment variable   | Value / Directories                            | Comment                                                                                                                                                                                                                                                                                                                                                       |
|------------------------|------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| ORACLE_SID             | ``TDB184S``                                    | Default Oracle SID. Usually it will default to the variable which has been specified during build. A custom SID can / should be specified.                                                                                                                                                                                                                    |
| ORACLE_PDB             | ``PDB1``                                       | Default PDB name.                                                                                                                                                                                                                                                                                                                                             |
| CONTAINER              | ``FALSE``                                      | Flag to create a container or single tenant database. Default set to false.                                                                                                                                                                                                                                                                                   |
| ORACLE_PWD             | n/a                                            | Custom admin password for common admin user like SYS and SYSTEM. If not specified a random password will be generated                                                                                                                                                                                                                                         |
| INSTANCE_INIT          | ``${ORACLE_BASE}/admin/${ORACLE_SID}/scripts`` | Folder for customize setup and startup. The database create script will look for a folder ``setup`` during initial setup or ``startup`` during each container startup. All bash ``.sh`` scripts as well sql ``.sql`` script will be executed. Make sure to add a sequence to keep the order of the scripts.                                                   |
| ORADBA_TEMPLATE_PREFIX | n/a                                            | Prefix to use a custom dbca template or the general purpose default template. By default this variable is not set. In this case dbca will use the general purpose template with the starter database. If set to ``custom_`` dbca will use a custom template to create a fresh database. This will take longer since the database will be create from scratch. |
| DEFAULT_DOMAIN         | ``domainname``                                 | Database default domain. If not specified the default domain will be used.                                                                                                                                                                                                                                                                                    |
| TNS_ADMIN              | ``${ORACLE_BASE}/network/admin``               | Alternative TNS_ADMIN environment variable.                                                                                                                                                                                                                                                                                                                   |
Create the container and start the database. The startup script will verify if there has been an Oracle database created in the volume. If there is no database a new database will be created based on the dbca templates.

```bash
docker-compose up -d
```

The database is ready when you see the following message in your docker logs.

```bash
---------------------------------------------------------------
 - DATABASE TDB184S IS READY TO USE!
---------------------------------------------------------------
```
