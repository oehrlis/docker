# Folder: samples

This folder contains **Docker Compose samples** and supporting configurations to demonstrate various Oracle Database features and advanced use cases. These examples are designed to complement the base Docker images under `OracleDatabase/`.

## 📁 Available Samples

| Folder      | Use Case Description                                                |
|-------------|----------------------------------------------------------------------|
| `audit`     | Configure and demonstrate Oracle auditing features                   |
| `cmu`       | Centrally Managed Users (CMU) and integration with external identity providers |
| `common`    | Shared assets or base configurations used across multiple samples    |
| `dbv`       | Oracle Database Vault setup and sample scenarios                     |
| `eus`       | Enterprise User Security (EUS) configuration samples                 |
| `obr`       | Oracle Backup and Recovery integration (tbd)                         |
| `orarepo`   | Setup for Oracle Yum/DNF repository mirroring or usage (tbd)         |
| `patch`     | Apply patches using AutoUpgrade or OPatch in Docker environments     |
| `pdb`       | Create and manage Pluggable Databases (PDB)                          |
| `rman`      | RMAN backup and recovery automation and testing                      |
| `tde`       | Transparent Data Encryption (TDE) configuration                      |
| `tdehsm`    | TDE with external HSM integration (e.g., with KMIP or PKCS#11)       |

## 🔧 How to Use

Each subfolder typically contains a `docker-compose.yml` file and optionally additional environment files or scripts.

To run a sample:

```bash
cd samples/<use_case>
docker-compose up -d
````

> 📝 Note: Some samples require pre-built database images and specific configuration (e.g., wallets, keys, external services).

## 📌 Notes

- Samples are built and tested using the corresponding Docker images from `OracleDatabase/`
- You are encouraged to customize or extend these for your testing or demonstrations
- Use `docker-compose logs -f` to monitor initialization logs

## 🚧 To Be Defined

- `obr` and `orarepo` need further clarification and documentation
- Feel free to contribute improvements or open issues to refine these examples
