# Folder: database

This folder contains the **Docker build scripts, configuration files, and software definitions** for building Oracle Database images across supported platforms and release versions.

## Purpose

To provide a flexible and automated way to:

* Build Docker images for Oracle Database (19c, 23ai, etc.)
* Use per-version configurations for image setup
* Customize behavior during DB creation and container startup
* Support x86\_64 and ARM64 architectures

## Folder Structure

```text
database/
├── 19.0.0.0/                     # Docker build for Oracle 19c
│   ├── 19.27.0.0.Dockerfile      # Optional release-specific Dockerfile
│   ├── Dockerfile                # Shared Dockerfile.base used with build script
│   ├── config/                  # Setup and startup scripts
│   │   ├── setup/
│   │   └── startup/
│   ├── docker-compose.yml       # Compose file to run container locally
│   └── software/                # Folder for patch package lists
├── 23.0.0.0/                     # Docker build for Oracle 23ai
├── ...
```

## Building Oracle Database Docker Images

Use the common [`buildDB.sh`](../common/buildDB.sh) script to build database images:

```bash
./common/buildDB.sh -r 19.27.0.0 -p amd64,arm64
```

Or to build all releases and platforms defined in the script:

```bash
./common/buildDB.sh
```

Each image uses a shared `Dockerfile` and release-specific metadata files in `software/<arch>/RU_<version>/oracle_package_names_<arch>`.

## Running Oracle Database in a Container

After building the image, start it with Docker Compose:

```bash
cd OracleDatabase/19.0.0.0
docker-compose up -d
```

Wait for the message:

```text
---------------------------------------------------------------
 - DATABASE <SID> IS READY TO USE!
---------------------------------------------------------------
```

## Customizing Database Setup

You can customize what happens *during setup* and *on container startup* using:

```text
config/
├── setup/   # Executed once during DB creation
└── startup/ # Executed on every container start
```

Both directories support `.sh` and `.sql` scripts and are executed in alphanumeric order.

## Configuration via Environment Variables

| Variable                 | Description                                                 |
| ------------------------ | ----------------------------------------------------------- |
| `ORACLE_SID`             | Database SID                                                |
| `ORACLE_PDB`             | Pluggable Database name                                     |
| `CONTAINER`              | `TRUE` to enable CDB/PDB setup, `FALSE` for single instance |
| `ORACLE_PWD`             | Admin password for SYS/SYSTEM (random if not provided)      |
| `INSTANCE_INIT`          | Folder path for custom setup/startup scripts                |
| `ORADBA_TEMPLATE_PREFIX` | Use `custom_` to enable custom DBCA templates               |
| `DEFAULT_DOMAIN`         | Default domain for database                                 |
| `TNS_ADMIN`              | Alternative TNS\_ADMIN directory                            |

## Known Issues

* Overlay driver on CentOS can trigger Docker bug [#25409](https://github.com/moby/moby/issues/25409). Use `btrfs` or `overlay2`.

## FAQ

See [FAQ.md](../FAQ.md) in the project root.

## License and Support

These images are not official Oracle images. They are provided by the OraDBA community and maintained independently. See the [Oracle Docker Images GitHub](https://github.com/oracle/docker-images) for official alternatives.

Oracle binaries must be downloaded manually and are subject to Oracle licensing terms.
