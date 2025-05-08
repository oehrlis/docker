# 🔐 Oracle TDE `ADMINISTER KEY MANAGEMENT` Command Reference

This reference provides a consolidated overview of the supported `ADMINISTER KEY MANAGEMENT` subcommands and clauses across different Oracle keystore types:

- Software Keystore (password or auto-login)
- HSM-based Keystore (PKCS#11 via external store)
- Oracle Key Vault (OKV)

Based on Oracle Database 19c documentation:
[https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/ADMINISTER-KEY-MANAGEMENT.html](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/ADMINISTER-KEY-MANAGEMENT.html)

## ✅ Supported Operations by Keystore Type

| Operation                                 | Software Keystore | HSM Keystore | OKV Keystore |
|-------------------------------------------|-------------------|--------------|--------------|
| `SET KEYSTORE OPEN`                       | ✅                 | ✅            | ✅            |
| `SET KEYSTORE CLOSE`                      | ✅                 | ✅            | ✅            |
| `SET ENCRYPTION KEY`                      | ✅                 | ✅            | ✅            |
| `SET ENCRYPTION KEY ... WITH BACKUP`      | ✅                 | ✅¹           | ✅¹           |
| `BACKUP KEYSTORE`                         | ✅                 | ❌²           | ❌²           |
| `EXPORT KEYS`                             | ✅                 | ❌²           | ❌²           |
| `MERGE KEYSTORE`                          | ✅                 | ❌            | ❌³   |
| `ALTER KEYSTORE PASSWORD`                 | ✅                 | ❌            | ❌            |
| `ADD SECRET TO LOCAL AUTO_LOGIN KEYSTORE` | ✅                 | ✅            | ✅            |
| `UPDATE SECRET`                           | ✅                 | ✅            | ✅            |

¹ Backup identifiers apply to key tagging within Oracle, but actual HSM/OKV backups are handled by external tooling.

² HSM and OKV keystores **do not** support `BACKUP` or `EXPORT` via SQL. These actions must be handled using:

- HSM vendor tools (e.g., Securosys, Thales, Luna)
- OKV management interface or CLI

## 🔎 Notes by Keystore Type

### 🔐 Software Keystore

- Stored locally as `ewallet.p12`, optionally with `cwallet.sso` (auto-login)
- Supports all `ADMINISTER KEY MANAGEMENT` operations
- Used commonly in on-prem and developer setups
- Supports export, merge, and manual password rotation

### 🛡 HSM Keystore (PKCS#11)

- Encryption keys are stored in the HSM — not accessible/exportable from Oracle
- Passwords for HSM access are stored in Secure External Password Store (SEPS)
- Use of `EXTERNAL STORE` clause is mandatory for authentication
- Backup/export is disabled in Oracle; use HSM-native backup facilities

### 🔑 Oracle Key Vault (OKV)

- Centralized key and wallet store for multiple databases
- Integrated using SEPS and the `EXTERNAL STORE` clause
- Key operations handled via OKV client and administrative tooling
- Oracle recommends OKV for multi-DB or regulatory environments

## 🔁 Reverse Migration Caveat

When using the `REVERSE MIGRATE` clause to move from HSM to a software keystore, Oracle does **not** transfer or export the actual master encryption key from the HSM. Instead:

- A **new master encryption key** is generated in the software keystore.
- All tablespace and column keys are **rewrapped** (re-encrypted) with the new software-based master key.
- The database performs a **key rotation implicitly**, visible in the alert log via `New MKID` and `Tablespace key rewrap done` messages.

> ⚠️ This ensures HSM-stored keys are never exposed or duplicated and complies with key custody boundaries.

## 🔧 Common SQL Examples

```sql
-- Open software keystore
ADMINISTER KEY MANAGEMENT SET KEYSTORE OPEN IDENTIFIED BY "<KeystorePassword>";

-- Open Software, HSM or OKV keystore using SEPS
ADMINISTER KEY MANAGEMENT SET KEYSTORE OPEN IDENTIFIED BY EXTERNAL STORE;

-- Create or rotate master encryption key
ADMINISTER KEY MANAGEMENT SET ENCRYPTION KEY IDENTIFIED BY EXTERNAL STORE WITH BACKUP USING 'initial_tag';

-- EXTERNAL STORE and add secret to SEPS to simplify key commands
ADMINISTER KEY MANAGEMENT ADD SECRET '<HSMPassword>' FOR CLIENT 'HSM_PASSWORD' TO LOCAL AUTO_LOGIN KEYSTORE '<wallet_root>/tde_seps';

## 📚 References

- 📘 Oracle SQL Language Reference 19c - [`ADMINISTER KEY MANAGEMENT`](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/ADMINISTER-KEY-MANAGEMENT.html)
- 📘 Oracle Database Security Guide 19c - Chapter on Transparent Data Encryption (TDE)
- 📘 Oracle Key Vault Administrator Guide
- 📘 Oracle Support (MOS) Notes:

  - [1228046.1 - TDE Wallet and Keystore Concepts](https://support.oracle.com/epmos/faces/DocumentDisplay?id=1228046.1)
  - [2331567.1 - Oracle TDE Integration with Hardware Security Module (HSM)](https://support.oracle.com/epmos/faces/DocumentDisplay?id=2331567.1)
  - [2482971.1 - Using Secure External Password Store (SEPS) with HSM or OKV](https://support.oracle.com/epmos/faces/DocumentDisplay?id=2482971.1)

> 🧠 Use this reference to design secure, compliant TDE implementations across environments and manage lifecycle operations safely.
