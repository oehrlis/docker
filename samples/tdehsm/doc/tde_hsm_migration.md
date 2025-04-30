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
4. Create an EXTERNAL STORE for the HSM password
5. Restart database
6. Verify wallet and key status

## 🔍 Step 1: Check PKCS#11 Library

Verify that the PKCS#11 module (e.g., Securosys Primus) is installed and accessible:

```bash
ls -l /opt/oracle/extapi/64/hsm/primus/2.3.4/libprimusP11.so
```

## ⚙️ Step 2: Configure TDE to Support Both HSM and Software

Change the *TDE_CONFIGURATION* parameter to cover the software keystore as well the HSM, whereby we will use HSM as first keystore.

```sql
ALTER SYSTEM SET TDE_CONFIGURATION = 'KEYSTORE_CONFIGURATION=HSM|FILE' SCOPE=BOTH;
```

## 🔐 Step 3: Migrate the Master Key to the HSM

Now migrate the current master encryption key from software keystore to the HSM.

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

## ⚙️ Step 4: Create an EXTERNAL STORE for the HSM password

Determine admin directory and get the corresponding directory path as a *SQL\*Plus* variable for later use:

```sql
COLUMN wallet_root NEW_VALUE wallet_root NOPRINT
SELECT value AS wallet_root FROM v$parameter WHERE name = 'wallet_root';
```

Create an *EXTERNAL STORE* for the HSM password

```sql
ADMINISTER KEY MANAGEMENT ADD SECRET '<HSMPassword>' 
  FOR CLIENT 'HSM_PASSWORD' 
  TO LOCAL AUTO_LOGIN KEYSTORE '&wallet_root/tde_seps';
```

## 🔄 Step 5: Restart the Database

Restart the database to make sure the HS keystore is now the primary wallet. As we do not have autologin configred the HSM based keystore does have to be opened manually.

```sql
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ADMINISTER KEY MANAGEMENT SET KEYSTORE OPEN IDENTIFIED BY EXTERNAL STORE;
ALTER DATABASE OPEN;
```

## 📋 Step 6: Verify Final Wallet and Key Status

Check if the library has been successfully loaded by the Oracle process:

```bash
host pmap $(pgrep -f ora_gen0_.*) | grep -v " grep " | grep libprimusP11
```

> ✅ If the library appears in the memory map, it's been loaded correctly by the Oracle engine.

Check the current status of the software keystore

```sql
SET LINESIZE 160 PAGESIZE 200
COL wrl_type FOR A10
COL wrl_parameter FOR A50
COL status FOR A20
COL wallet_type FOR A20
COL wallet_order FOR A20
SELECT wrl_type, wrl_parameter, status, wallet_type,wallet_order FROM v$encryption_wallet;
```

Check the status of encryption keys:

```sql
SET LINESIZE 160 PAGESIZE 200
ALTER SESSION SET nls_timestamp_tz_format="DD.MM.YYYY HH24:MI:SS";
COL key_id FOR A52
COL tag FOR A10
COL creation_time FOR A19
COL activation_time FOR A19
COL creator FOR A10
COL user FOR A10
COL key_use FOR A7
COL creator_dbname FOR A10
COL backed_up FOR A8

SELECT key_id, tag, creation_time, activation_time, creator, user, key_use, backed_up, creator_dbname FROM v$encryption_keys;
```

Check TDE configuration using the script *ssenc_info.sql*

```sql
@/u01/config/scripts/demo/ssenc_info.sql
```

> ✅ You have now successfully migrated to HSM.
