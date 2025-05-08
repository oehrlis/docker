# 🧪 Use Case 6: Reverse Migration to Software Keystore

This guide describes how to reverse-migrate the TDE master encryption key from an HSM-based keystore back to a software keystore. This may be required for scenarios like decommissioning an HSM, testing, or fallback operations.
> ⚠️ Prerequisites:
>
> - Corresponding `WALLET_ROOT` and `TDE_CONFIGURATION` configuration
> - Both software and HSM keystores must be configured and accessible
> - Sufficient privileges (`SYSKM` or `SYSDBA`)

## 📖 Overview

Reverse migration does **not** copy the master encryption key from the HSM. Instead, Oracle:

* Creates a **new master encryption key** in the software keystore
* **Rewraps** all tablespace and column encryption keys using the new software-based key
* Performs a **full key rekey operation** internally

This ensures that the master key in the HSM is never exported or exposed.

> 📘 This process requires:
>
> * An accessible and configured software keystore (`ewallet.p12`)
> * Valid HSM and SEPS configuration (for reading the current key)

## 🔄 Steps Overview

1. Update TDE Configuration to allow FILE and HSM
2. Reverse migrate the encryption key from HSM to software keystore
3. Update TDE Configuration to FILE only
4. Restart the database
5. Verify wallet and encryption key status

## 🔧 Step 1: Update TDE Configuration

Allow use of both FILE and HSM-based keystores, whereby we change order back to software keystore as primary keystore:

```sql
ALTER SYSTEM SET TDE_CONFIGURATION = 'KEYSTORE_CONFIGURATION=FILE|HSM' SCOPE=BOTH;
```

## 🔁 Step 2: Reverse Migrate the Master Key to Software Keystore

Execute the reverse migration command:

```sql
ADMINISTER KEY MANAGEMENT SET ENCRYPTION KEY IDENTIFIED BY "<KeystorePassword>"
  REVERSE MIGRATE USING "<HSMPassword>"
  WITH BACKUP USING 'reverse_migrate_from_HSM';
```

> 🛡️ This does **not** transfer the HSM key. Instead, it creates a new master encryption key in the software wallet and rewraps existing keys with it.
>
> You will see in the alert log:
>
> * `Rev-Migrate keystore: New MKID:`
> * `Tablespace key rewrap done`
> * `Switching out all online logs for migrating from HSM to wallet.`

See an excerpt from the alert log:

```text
KZTDE: Attempting TDE operation in PDB#=0: ADMINISTER KEY MANAGEMENT SET ENCRYPTION KEY IDENTIFIED BY * REVERSE MIGRATE USING * WITH BACKUP USING *
KZTDE:kzezthsm: Third-party HSM used with Oracle DB
KZTDE:kzezthsm: Manufacturer ID: Securosys SA                    ???? and Library description: PKCS#11 Library                 ^B"????
KZTDE: Rev-Migrate keystore: New MKID: AXfZRyA8G0+Evyb5zoHzLt4AAAAAAAAAAAAAAAAAAAAAAAAAAAAA
2025-05-08T05:22:57.169816+00:00
KZTDE: Rev-Migrate keystore: Tablespace key rewrap done
2025-05-08T05:22:57.197880+00:00
KZTDE:Switching out all online logs for migrating from HSM to wallet.
2025-05-08T05:22:57.239389+00:00
```

## 🔄 Step 3: Update TDE Configuration

Change the TDE configuration to use only the software keystore:

```sql
ALTER SYSTEM SET TDE_CONFIGURATION='KEYSTORE_CONFIGURATION=FILE' SCOPE=SPFILE;
```

## 🔄 Step 4: Restart the Database Normally

Restart the database to make sure the Software keystore is now used.

```sql
SHUTDOWN IMMEDIATE;
STARTUP;
```

## 📋 Step 5: Verify Wallet and Encryption Keys

Check the current status of the software keystore

```sql
SET LINESIZE 160 PAGESIZE 200
COL wrl_type FOR A10
COL wrl_parameter FOR A50
COL status FOR A18
COL wallet_type FOR A16
COL wallet_order FOR A16
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

> ✅ At this point, TDE is fully managed via the software keystore.
