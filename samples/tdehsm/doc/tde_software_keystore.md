# 🧪 Use Case 1: Software Keystore

This guide describes how to configure **Oracle TDE** using a standard **software keystore** (`ewallet.p12`). This setup is ideal for evaluation, local development, and as a foundation for migrating to an HSM-backed configuration.

> 📘 Prerequisites:
>
> - Database is **not yet** configured for TDE

## 🗂 Overview

- Uses `WALLET_ROOT` to define the keystore location (requires restart)
- Keystore is stored in the filesystem in the admin directory of the ORACLE_SID e.g. `$ORACLE_BASE/admin/$ORACLE_SID/wallet/tde/`
- Auto-login and credential store (SEPS) supported
- Master key must be created before encrypting any data

## 🔧 Step 1: Configure Wallet Root Parameters

Determine admin directory and get the corresponding directory path as a *SQL\*Plus* variable for later use:

```sql
CONN / AS SYSDBA
COLUMN admin_path NEW_VALUE admin_path NOPRINT
SELECT SUBSTR(value, 1, INSTR(value, '/', -1, 1) - 1) AS admin_path FROM v$parameter WHERE name = 'audit_file_dest';
```

Create the wallet folders below the admin directory using the same *SQL\*Plus* session as above:

```bash
host mkdir -p &admin_path/wallet
host mkdir -p &admin_path/wallet/backup
host mkdir -p &admin_path/wallet/tde
host mkdir -p &admin_path/wallet/tde_seps
```

Configure initialization parameters for TDE by setting `WALLET_ROOT` and `EXTERNAL_KEYSTORE_CREDENTIAL_LOCATION`:

```sql
ALTER SYSTEM SET wallet_root = '&admin_path/wallet' SCOPE = SPFILE;
ALTER SYSTEM SET external_keystore_credential_location = '&admin_path/wallet/tde_seps' SCOPE = SPFILE;
```

Restart the database to apply the parameter changes:

```sql
SHUTDOWN IMMEDIATE;
STARTUP;
```

## ⚙️ Step 2: Configure Keystore Parameters

Set the `TDE_CONFIGURATION` parameter and the default encryption algorithm.

```sql
ALTER SYSTEM SET tde_configuration = 'KEYSTORE_CONFIGURATION=FILE' SCOPE = BOTH;
ALTER SYSTEM SET "_tablespace_encryption_default_algorithm" = 'AES256' SCOPE = BOTH;
```

## 🔐 Step 3: Create the Software Keystore

Get the *WALLET_ROOT* into an *SQL\*Plus* variable for later use:

```sql
COLUMN wallet_root NEW_VALUE wallet_root NOPRINT
SELECT value AS wallet_root FROM v$parameter WHERE name = 'wallet_root';
```

### Create Keystore

Create the software keystore in the wallet root directory:

```sql
ADMINISTER KEY MANAGEMENT CREATE KEYSTORE '&wallet_root/tde' IDENTIFIED BY "<KeystorePassword>";
```

### Store Password in SEPS

Create a secure external password store (SEPS) for the wallet password. This enables the execution of *ADMINISTER KEY MANAGEMENT* without a password or with the use of *EXTERNAL STORE* in the following

```sql
ADMINISTER KEY MANAGEMENT ADD SECRET '<KeystorePassword>' FOR CLIENT 'TDE_WALLET' TO LOCAL AUTO_LOGIN KEYSTORE '&wallet_root/tde_seps';
```

### Open Keystore

Manually open the keystore. User either the *<KeystorePassword>* or the *EXTERNAL STORE*

```sql
ADMINISTER KEY MANAGEMENT SET KEYSTORE OPEN IDENTIFIED BY EXTERNAL STORE;
```

### Enable Auto-login

Enable local auto-login for the software keystore:

```sql
ADMINISTER KEY MANAGEMENT CREATE LOCAL AUTO_LOGIN KEYSTORE FROM KEYSTORE '&wallet_root/tde' IDENTIFIED BY EXTERNAL;
```

**Note:** Although *AUTOLOGIN LOCAL* has been set for the keystore, *PASSWORD*
is displayed in the 'v$encryption_wallet' view. The wallet type is only
displayed correctly after restarting the database.

At this stage we restart the database to make sure it is start using the Restart *AUTO_LOGIN* functionality. 

```sql
SHUTDOWN IMMEDIATE;
STARTUP;
```

## 🔑 Step 4: Create Master Encryption Key

Create a master encryption key by using the *EXTERNAL STORE*. As the keystore is configured using *AUTO_LOGIN* we also have to specify *FORCE KEYSTORE*.

```sql
ADMINISTER KEY MANAGEMENT SET ENCRYPTION KEY USING TAG 'initial' FORCE KEYSTORE IDENTIFIED BY EXTERNAL STORE WITH BACKUP USING 'initial_mek_backup';
```

## 🔑 Step 5: Check the TDE Configuration and Key

Check the current status of the software keystore

```sql
SET LINESIZE 160 PAGESIZE 200
COL wrl_type FOR A10
COL wrl_parameter FOR A50
COL status FOR A20
COL wallet_type FOR A20
SELECT wrl_type, wrl_parameter, status, wallet_type FROM v$encryption_wallet;
```

Check TDE configuration using the script *ssenc_info.sql*

```sql
@/u01/config/scripts/demo/ssenc_info.sql
```

> ✅ At this point, TDE is ready to encrypt tablespaces and columns.
