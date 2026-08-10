# Oracle Docker Build Repository

This repository provides a modular and automated framework to build **Oracle-related Docker images**, including:

- Oracle Database (19c, 23ai)
- Oracle Unified Directory (OUD)
- OUD Service Manager (OUDSM)
- Java-based containers
- OCI CLI container setups

> ⚠️ This is a **community-maintained project** by [OraDBA](https://www.oradba.ch). It is **not affiliated with Oracle Corporation**.  
> For official Oracle container builds, visit [oracle/docker-images](https://github.com/oracle/docker-images)

## 🧱 Repository Structure

```text

.
├── README.md              # This file
├── LICENSE
├── FAQ.md                 # Frequently asked questions

├── common/                # Shared build scripts (e.g., buildDB.sh)
│   ├── buildDB.sh
│   └── buildDBx\_arm64.sh

├── database/              # Oracle Database image builds
│   ├── 19/                # Oracle 19c builds
│   │   ├── docker/        # Base Dockerfile templates
│   │   ├── config/        # Setup/startup scripts
│   │   ├── software/      # Patches, ZIPs, metadata
│   │   ├── docker-compose.yml
│   │   └── README.md
│   ├── 23/                # Oracle 23ai builds
│   └── README.md

├── java/                  # Oracle Java-based containers
├── oud/                   # Oracle Unified Directory builds
├── oudsm/                 # Oracle Unified Directory Service Manager
├── oci-cli/               # OCI CLI in container

├── samples/               # Example environments and topologies
│   ├── single-instance/
│   ├── data-guard/
│   ├── tde/
│   ├── rman/
│   └── README.md

├── doc/                   # Markdown-based documentation
├── legacy/                # Older build structures kept for reference

```

## 🛠️ Features

- Multi-platform support for `amd64` and `arm64`
- Patch ZIP management and release metadata per RU
- Scripted and repeatable image builds
- Docker Compose setups for development, test, and HA scenarios
- Centralized and extensible documentation

## 🚀 Getting Started

Build an Oracle 19c image for `amd64`:

```bash
cd common
./buildDB.sh -r 19.27.0.0 -p amd64
```

Launch a container from a Compose example:

```bash
cd samples/single-instance
docker-compose up -d
```

## 📦 Patch and Metadata Layout

Example:

```text
database/19/software/amd64/RU_19.27.0.0/oracle_package_names_amd64
```

Each file defines which patch ZIPs to include for the specified release and platform.
Used by `buildDB.sh` to build the final image.

## 🤝 Contributing

- Fork and submit pull requests
- Use GitHub Issues for feedback, bugs, or enhancements
- All Oracle ACE and community contributions are welcome

## 🔐 License

Code is licensed under [Apache 2.0](LICENSE).
Oracle binaries must be obtained separately and used according to Oracle's license terms.
