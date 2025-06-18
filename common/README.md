# Folder: common

This folder contains **shared scripts and resources** used across multiple Oracle Docker image builds. These scripts help standardize how images are created and configured across platforms and Oracle versions.

## Included Scripts

### `buildDB.sh`

Builds Oracle Database Docker images for one or more releases and platforms.

**Usage:**

```bash
./buildDB.sh -r 19.27.0.0,23.5.0.0 -p amd64,arm64
```

**Parameters:**

* `-r <releases>`  Comma-separated list of Oracle release tags (e.g., `19.27.0.0`)
* `-p <platforms>`  Comma-separated list of target platforms (default: both `amd64` and `arm64`)

If no release is specified, the script lists supported versions.

### `buildDBx_arm64.sh`

Optional ARM-specific wrapper for `buildDB.sh` to simplify builds on M1/M2 Macs or ARM servers.

## Notes

* These scripts rely on the structured layout of `OracleDatabase/<version>/software/<arch>/RU_<version>/` for patch and base package info.
* The actual Dockerfile used is version-independent; image metadata is injected using `ARG` parameters.

## See Also

* `OracleDatabase/README.md` for structure and usage of database build folders.
* `doc/database_builds.md` (to be added) for the full documentation on building Oracle DB images.

Feel free to extend or customize the build logic to suit additional use cases.
