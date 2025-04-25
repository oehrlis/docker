# 🧪 Use Case 2: Migrate to HSM with Auto-Login

This guide outlines how to migrate an existing TDE environment using a software keystore to a Hardware Security Module (HSM), including configuration of automatic keystore login.

> 📘 Prerequisites:
>
> - Existing master key in software keystore
> - HSM configured and accessible via PKCS#11
> - `sqlnet.ora` and `wallet_root` pointing to HSM interface

## 🔄 Steps Overview

1. Check PKCS#11 library installation and registration
2. Set wallet type to `HSM` in TDE configuration
3. Migrate keys from software to HSM
4. Enable auto-login for the HSM
5. Restart database
6. Verify wallet and key status

## 🔍 Step 1: Check PKCS#11 Library

Verify that the PKCS#11 module (e.g., Securosys Primus) is installed and accessible:

```bash
ls -l /opt/oracle/extapi/64/hsm/primus/2.3.4/libprimusP11.so
```

Check if the library has been successfully loaded by the Oracle process:
=> later
```bash
ps -ef | grep ora_gen0
pmap $(pgrep -f ora_gen0_.*) | grep -v " grep " | grep libprimusP11
```

> ✅ If the library appears in the memory map, it's been loaded correctly by the Oracle engine.

## ⚙️ Step 2: Configure TDE to Support Both HSM and Software

```sql
ALTER SYSTEM SET TDE_CONFIGURATION = 'KEYSTORE_CONFIGURATION=HSM|FILE';
```

startup force open or mount
open hsm
open db

## 🔐 Step 3: Migrate the Master Key to the HSM

```sql
ADMINISTER KEY MANAGEMENT SET ENCRYPTION KEY 
  IDENTIFIED BY "<HSMPassword>" 
  MIGRATE USING "<KeystorePassword>" 
  WITH BACKUP USING 'migrate_to_HSM';
```

Verify new key:

```sql
SELECT * FROM v$encryption_keys ORDER BY creation_time;
```

## 🔑 Step 4: Enable HSM Auto-Login via SEPS

```sql
ADMINISTER KEY MANAGEMENT ADD SECRET '<HSMPassword>' 
  FOR CLIENT 'HSM_PASSWORD' 
  TO LOCAL AUTO_LOGIN KEYSTORE '/u00/app/oracle/admin/TENC19/wallet/tde_seps';
```

ALTER SYSTEM SET TDE_CONFIGURATION = 'KEYSTORE_CONFIGURATION=FILE|HSM';
startup force;
ADMINISTER KEY MANAGEMENT ADD SECRET '<HSMPassword>' FOR CLIENT 'HSM_PASSWORD' FORCE KEYSTORE IDENTIFIED BY EXTERNAL STORE WITH BACKUP USING 'add_hsm_partition_password';
ALTER SYSTEM SET TDE_CONFIGURATION = 'KEYSTORE_CONFIGURATION=HSM|FILE';
startup force;

## 🔄 Step 5: Restart the Database

To finalize HSM activation and ensure proper wallet type detection:

```sql
SHUTDOWN IMMEDIATE;
STARTUP;
```

---

## 📋 Step 6: Verify Final Wallet and Key Status

```sql
SELECT * FROM v$encryption_wallet;
SELECT * FROM v$encryption_keys ORDER BY creation_time;
```

> ✅ You have now successfully migrated to HSM and enabled auto-login.
