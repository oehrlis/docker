# 📘 TDE Use Case Documentation

This folder contains hands-on technical documentation for various Oracle TDE (Transparent Data Encryption) configurations supported in this project. Each use case is structured for DBAs and engineers to test, validate, or implement TDE scenarios both with software-based keystores and Hardware Security Modules (HSM).

## 📚 Available Use Cases

| Document                             | Description                                                    |
|--------------------------------------|----------------------------------------------------------------|
| `tde_software_keystore.md`           | Setup of a traditional file-based software keystore            |
| `tde_hsm_migration.md`               | Migration of TDE keys from software keystore to HSM            |
| `tde_hsm_rekey.md`                   | Creating a new master encryption key directly on the HSM       |
| `tde_hsm_reverse_migration.md`       | Migrating master keys from HSM back to software keystore       |

Each document includes:

- SQL and shell commands for copy/paste use
- Clear separation of configuration steps
- Notes and guidance for multi-node or RAC setups
- Suitable for demos, labs, or production readiness validation

> 🛠 These guides are meant to be modular, reusable, and extendable for other wallet scenarios.
