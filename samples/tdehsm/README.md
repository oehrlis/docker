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
│   ├── shared/     # shared files for different use cases
│   ├── setup/      # Scripts executed once after DB creation
│   └── startup/    # Scripts executed at every container startup
├── data/           # Oracle database files (mounted to /u01)
├── docker-compose.yml
└── README.md
```

## 📂 Key Mounts

| Host Path                   | Container Path             | Purpose                      |
|-----------------------------|----------------------------|------------------------------|
| `./config`                  | `/u01/config`              | Main config and init scripts |
| `./data/tdehsm01`           | `/u01`                     | Oracle DB home and data      |
| `./config/hsm/primus.cfg`   | `/etc/primus/primus.cfg`   | Primus HSM configuration     |
| `./config/hsm/.secrets.cfg` | `/etc/primus/.secrets.cfg` | HSM credential configuration |

## 🧾 Requirements

- Docker and Docker Compose
- Access to Securosys CloudHSM credentials and partition config
- Oracle Docker image with 19.26.0.0 tag (or adjusted for your needs)

## 🚀 Getting Started

### ✅ 1. Check HSM Configuration Files

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

### 🔍 4. Monitor Startup Logs

To follow the container logs and verify successful startup:

```bash
docker-compose logs -f
```

The container is fully ready when you see the following message:

```
tdehsm01  |  ---------------------------------------------------------------
tdehsm01  |  - DATABASE TENC19 IS READY TO USE!
tdehsm01  |  ---------------------------------------------------------------
```

## 🔐 HSM Integration

- Libraries provided in `config/hsm/`
- `primus.cfg` and `.secrets.cfg` are automatically mounted into `/etc/primus`
- After startup, the PKCS#11 module can be used for:
  - TDE key creation and rotation
  - Wallet operations using HSM as keystore backend

## ⚙️ Automation Layers

- `config/setup/`: Scripts run once after container creation
- `config/startup/`: Scripts run every time the container starts
- `config/scripts/`: Manually executed scripts for additional TDE tasks and testing

## 🧪 TDE Use Case Documentation

This test environment supports the evaluation of different TDE configurations:

### 🔸 1. File-Based Wallet (default)
- Uses a standard `ewallet.p12` file (fallback)
- Configure via `ENCRYPTION_WALLET_LOCATION` in `sqlnet.ora`
- Useful for comparing baseline vs HSM-backed setup

### 🔸 2. HSM-Backed Wallet via PKCS#11
- Uses `Securosys Primus PKCS#11` interface
- Configuration:
  - Mount `primus.cfg` and `.secrets.cfg`
  - Adjust `sqlnet.ora` with `ENCRYPTION_KEYSTORE_TYPE = HSM` and `ENCRYPTION_KEYSTORE_LOCATION = PKCS11`
- Execute TDE setup via `config/scripts/14_config_tde.sh`

### 🔸 3. Dual Keystore (Hybrid) [Optional Advanced]
- Combine software and HSM keystores for layered security
- Requires Wallet Manager or CLI key transfer operations

> 📘 Each test case can be configured interactively using scripts in `config/scripts/`, or by modifying the automation logic in `config/setup/`.

## 🛠 Troubleshooting

- Check logs in `docker logs tdehsm01`
- For SQL*Net/HSM issues, enable tracing in `sqlnet.ora` via `TRACE_LEVEL_CLIENT=SUPPORT`
- Use `pkcs11-tool` or `p11tool` to debug HSM access

## 📚 Reference

- [https://github.com/oehrlis/docker](https://github.com/oehrlis/docker)
- [Securosys CloudHSM](https://www.securosys.com/products/cloudhsm)
- Oracle Database TDE & PKCS#11 Documentation

## 📜 License

Apache License Version 2.0  
(c) Stefan Oehrli / OraDBA - Oracle Infrastructure and Security, Switzerland
