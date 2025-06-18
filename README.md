# Docker Automation for Oracle Products

This repository provides **unofficial Docker-based automation** for Oracle software, focusing on Oracle Database. It includes build scripts, patch automation, configuration templates, and Docker Compose examples to streamline image creation, patching, and testing across multiple platforms.

This project is maintained by [OraDBA](https://www.oradba.ch) and is not affiliated with Oracle Corporation. For official Oracle Docker images, refer to [oracle/docker-images](https://github.com/oracle/docker-images).

## Supported Oracle Components

- Oracle Database (multi-version, multi-platform builds)
- Oracle Unified Directory (OUD) and Directory Services Manager (OUDSM)
- Oracle Java Runtime
- Oracle Cloud Infrastructure CLI in a Docker environment
- Sample environments using Docker Compose

## Key Features

- Patch automation using Oracle AutoUpgrade
- Platform-aware Docker builds for x86\_64 and ARM
- Structured configuration per version and platform
- Sample setups for Data Guard, TLS, and single-instance deployments
- Clean separation of software, config, and logic

## Repository Structure

| Folder            | Description                                           |
| ----------------- | ----------------------------------------------------- |
| `OracleDatabase/` | Oracle Database builds, patch metadata, Compose files |
| `OracleOUD/`      | Oracle Unified Directory container setup              |
| `OracleOUDSM/`    | Oracle Directory Services Manager setup               |
| `OracleJava/`     | Oracle Java runtime configuration                     |
| `oci-cli/`        | Docker-based Oracle Cloud CLI environment             |
| `samples/`        | Docker Compose setups (e.g., Data Guard, TLS)         |
| `common/`         | Shared logic/scripts like `buildDB.sh`, `.env` files  |
| `doc/`            | Markdown-based documentation and diagrams             |
| `legacy/`         | Deprecated or archived builds                         |
| `FAQ.md`          | Frequently asked questions                            |
| `LICENSE`         | Apache 2.0 License                                    |

Each folder includes a `README.md` with more detailed information.

## Oracle Software Licensing

Due to Oracle licensing, no prebuilt images or binaries are provided. You must manually download Oracle software and accept the license terms before using it in a containerized environment.

## Support

This repository is provided as-is. For community support, open a GitHub issue. For product-related support, refer to Oracle My Support.
