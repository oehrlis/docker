# TDEHSM01 - Oracle Test DB with TDE & HSM Integration

This project provides a containerized **Oracle Database 19c test environment** designed to evaluate and validate **Transparent Data Encryption (TDE)** with an **external Hardware Security Module (HSM)** using **Securosys Primus CloudHSM** via **PKCS#11**.

## 📌 Purpose

- Test Oracle TDE key management using an external HSM (Securosys Primus)
- Automate encryption, auditing, and security policy testing
- Provide reusable, isolated infrastructure for security and HSM experiments
- Facilitate development and reproducibility for HSM-secured database configurations

## 🧱 Folder Structure

```plaintext
.
├── bin/            # Utility scripts for validation and post-setup actions
├── config/         # Configuration files, setup scripts, HSM libs and wallet
│   ├── etc/        # sqlnet.ora, listener.ora, tnsnames.ora
│   ├── hsm/        # Securosys Primus config and PKCS#11 libraries
│   ├── scripts/    # Manual (interactive) scripts for testing and encryption
│   ├── setup/      # Scripts executed once after DB creation
│   └── startup/    # Scripts executed at every container startup
├── data/           # Oracle database files (mounted to /u01)
├── docker-compose.yml
└── README.md
```

## 📂 Key Mounts

| Host Path                   | Container Path             | Purpose                                  |
|-----------------------------|----------------------------|------------------------------------------|
| `./config`                  | `/u01/config`              | Main config and init scripts             |
| `./data/tdehsm01`           | `/u01`                     | Oracle DB home and data                  |
| `./config/hsm/primus.cfg`   | `/etc/primus/primus.cfg`   | Primus HSM configuration                 |
| `./config/hsm/.secrets.cfg` | `/etc/primus/.secrets.cfg` | HSM credential configuration             |

## 🚀 Getting Started

### ✅ 1. Check HSM Configuration Files

Make sure the HSM credentials and config files are present:

```bash
./bin/check_hsm_mounts.sh
```

### ▶️ 2. Start the Oracle DB Container

```bash
docker-compose up -d
```

### 📦 3. Install Securosys PKCS#11 Library in the Container

```bash
./bin/install_primus_rpm.sh
```

## ⚙️ Automation Layers

- `config/setup/`: Scripts run once after the container initializes. Used to configure TDE, auditing, users, and policies.
- `config/startup/`: Scripts run at every container start. Useful for checks, refreshes, or revalidation.
- `config/scripts/`: Manually executable helper scripts for encryption tests, schema prep, auditing, etc.

## 🔐 HSM Integration

The project is preconfigured to support **Securosys Primus HSM**:

- Libraries provided in `config/hsm/`
- `primus.cfg` and `.secrets.cfg` are automatically mounted in `/etc/primus`
- After startup, the PKCS#11 module can be used for:
  - TDE key creation and rotation
  - Oracle Wallet keystore using HSM backend

## 🧾 Requirements

- Docker and Docker Compose
- Access to Securosys CloudHSM credentials and partition config
- Oracle Docker image with 19.26.0.0 tag (or adjusted for your needs)

## 🛠 Troubleshooting

- Check logs in `docker logs tdehsm01`
- For SQL*Net/HSM issues, enable tracing in `sqlnet.ora` via `TRACE_LEVEL_CLIENT=SUPPORT`
- Use `pkcs11-tool` or `p11tool` to debug HSM access

---

## 📚 Reference

- [https://github.com/oehrlis/oci-sec-ws](https://github.com/oehrlis/oci-sec-ws)
- [Securosys CloudHSM](https://www.securosys.com/products/cloudhsm)
- Oracle Database TDE & PKCS#11 Documentation

## 📜 License

Apache License Version 2.0  
(c) Stefan Oehrli / OraDBA - Oracle Infrastructure and Security, Switzerland
