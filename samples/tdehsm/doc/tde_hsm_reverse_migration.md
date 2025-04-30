# 🧪 Use Case 6: Reverse Migration to Software Keystore

This guide describes how to safely migrate the TDE master encryption key from an HSM-based keystore back to a software-based keystore (wallet). This can be required in case of HSM decommissioning, platform migration, or test-to-dev transfer.

> ⚠️ Prerequisites:
>
> - Both software and HSM keystores must be configured and accessible
> - Sufficient privileges (`SYSKM` or `SYSDBA`)

## 🔄 Steps Overview

1. Switch `TDE_CONFIGURATION` to allow FILE|HSM
2. Restart the database and mount
3. Reverse migrate the encryption key from HSM to software keystore
4. Set `TDE_CONFIGURATION` to FILE only
5. Restart the database
6. Verify wallet and encryption key status

## 🔧 Step 1: Temporarily Enable Dual Keystore Mode

Allow use of both FILE and HSM-based keystores, whereby we change order back to software keystore as primary keystore:

```sql
ALTER SYSTEM SET TDE_CONFIGURATION = 'KEYSTORE_CONFIGURATION=FILE|HSM' SCOPE=SPFILE;
```

## 🔄 Step 2: Restart the Database in MOUNT Mode

Restart the database to make sure the Software keystore is now the primary wallet.

```sql
SHUTDOWN IMMEDIATE;
STARTUP;
```

## 🔁 Step 3: Reverse Migrate the Master Key to Software Keystore

```sql
ADMINISTER KEY MANAGEMENT SET ENCRYPTION KEY IDENTIFIED BY "<KeystorePassword>" REVERSE MIGRATE USING "<HSMPassword>"
WITH BACKUP USING 'reverce_migrate_from_HSM';
```

> 🛡️ This will copy the current master encryption key from the HSM to the software keystore.

## ⚙️ Step 4: Switch to Software Keystore Only

After successful migration, restrict usage to the software wallet:

```sql
ALTER SYSTEM SET TDE_CONFIGURATION = 'KEYSTORE_CONFIGURATION=FILE' SCOPE=SPFILE;
```

## 🔄 Step 5: Restart the Database Normally

Restart the database to make sure the Software keystore is now used.

```sql
SHUTDOWN IMMEDIATE;
STARTUP;
```

## 📋 Step 6: Verify Wallet and Encryption Keys

Check the current status of the software keystore

```sql
SET LINESIZE 160 PAGESIZE 200
COL wrl_type FOR A10
COL wrl_parameter FOR A50
COL status FOR A20
COL wallet_type FOR A20
SELECT wrl_type, wrl_parameter, status, wallet_type FROM v$encryption_wallet;
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


> ✅ TDE is now fully backed by a software keystore. The HSM is no longer required for key access.