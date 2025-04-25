# config/

This folder contains all configuration files and automation scripts for the Oracle database container `TDEHSM01`.

It is mounted into the container at `/u01/config` and acts as the base path for:

- Initial database configuration (`INSTANCE_INIT`)
- Post-deployment automation (`setup/`)
- Runtime HSM integration (`hsm/`)
- Network configuration (`etc/`)
- Interactive or diagnostic scripts (`scripts/`)
- Per-startup tasks (`startup/`)

## 📁 Subfolders

| Folder     | Purpose                                                                 |
|------------|-------------------------------------------------------------------------|
| `etc/`     | SQL*Net configuration: `sqlnet.ora`, `listener.ora`, `tnsnames.ora`     |
| `hsm/`     | Contains Primus HSM configuration, credentials, and PKCS#11 libraries   |
| `scripts/` | Useful scripts for testing, encryption, audit, schema loading, etc.     |
| `setup/`   | Sequential scripts executed **once** post-container creation            |
| `startup/` | Sequential scripts executed at **every container startup**              |

## 🔐 HSM Notes

Ensure the following files are present in `config/hsm/`:

- `primus.cfg` → mounted to `/etc/primus/primus.cfg`
- `.secrets.cfg` → mounted to `/etc/primus/.secrets.cfg`

Refer to `bin/check_hsm_mounts.sh` to validate before starting the container.
