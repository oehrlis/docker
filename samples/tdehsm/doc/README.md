# 📘 TDE Use Case Documentation

This folder contains hands-on technical documentation for various Oracle TDE (Transparent Data Encryption) configurations supported in this project. Each use case is structured for DBAs and engineers to test, validate, or implement TDE scenarios both with software-based keystores and Hardware Security Modules (HSM).

## 📚 Available Use Cases

| Document                                                                      | Description                                                                          |
|-------------------------------------------------------------------------------|--------------------------------------------------------------------------------------|
| [1. Software Keystore](tde_software_keystore.md)                          | Setup of a traditional file-based software keystore                                  |
| [2. Migrate to HSM with Auto-Login](tde_hsm_migration.md)                 | Migration of TDE keys from software keystore to HSM                                  |
| [3. Oline encrypt Tablespaces](tde_enc_tablespace.md)                     | Online encrypt Tablespaces                                                           |
| [4. Enable Auto-Login Functionality for HSM](tde_hsm_autologin.md)        | Enable auto-login for HSM by storing the partition password in a local SEPS keystore |
| [5. Rekey on HSM](tde_hsm_rekey.md)                                       | Creating a new master encryption key directly on the HSM                             |
| [6. Reverse Migration to Software Keystore](tde_hsm_reverse_migration.md) | Migrating master keys from HSM back to software keystore                             |
| [7. Clean Up HSM Partition](tde_hsm_cleanup.md)                           | Clean up unused keys and data objects from HSM partitions using `pkcs11-tool`        |

Each document includes:

- SQL and shell commands for copy/paste use
- Clear separation of configuration steps
- Notes and guidance for RAC/multi-instance and production scenarios
- Warnings about destructive actions or irreversible changes

> 🛠 These guides are meant to be modular, reusable, and extendable for other wallet scenarios.
