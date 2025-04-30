# 🧪 Use Case 5: Rekey on HSM

This guide explains how to create a new master encryption key directly within the Hardware Security Module (HSM), ensuring that the key material never leaves the secure keystore.

> 📘 Prerequisites:
>
> - Database is configured for HSM-based TDE
> - Keystore is open and accessible (e.g., auto-login or password loaded)
> - *EXTERNAL STORE* for HSM password is configured. Otherwise the HSM password has to be specified.

## 🔄 Steps Overview

1. Open the HSM keystore (if not auto-login)
2. Check the currently active encryption key
3. Generate a new master encryption key in the HSM
4. Confirm the new key is active and backed up

## 🔓 Step 1: Open the HSM Keystore (if not auto-login)

If auto-login is not enabled, manually open the HSM keystore using the password from SEPS:

```sql
ADMINISTER KEY MANAGEMENT SET KEYSTORE OPEN IDENTIFIED BY EXTERNAL STORE;
```

## 🔍 Step 2: Check Current Encryption Key

Use the following query to review currently active encryption keys:

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

This will help you identify the current key in use before rekeying.

## 🔐 Step 3: Create a New Master Encryption Key

Use the following command to generate a new master key directly in the HSM:

```sql
ADMINISTER KEY MANAGEMENT SET KEY FORCE KEYSTORE IDENTIFIED BY EXTERNAL STORE WITH BACKUP USING 'new_mek_wallet';
```

> 💡 The keyword `EXTERNAL STORE` uses the password from the secure external keystore (SEPS).

## ❗ Important Note on Backups

> ⚠️ **Backup limitations with HSM-based keystores:**
>
> The following operations do **not work** with HSM:
>
> ```sql
> ADMINISTER KEY MANAGEMENT BACKUP KEYSTORE USING 'new_mek' FORCE KEYSTORE IDENTIFIED BY EXTERNAL STORE;
> ```
>
> Results in:
>
> ```text
> ORA-00600: internal error code, arguments: [kzckmbkup: invalid keystore location], [4], ...
> ```
>
> Export is also not supported:
>
> ```sql
> ADMINISTER KEY MANAGEMENT EXPORT KEYS WITH SECRET 'my_secret'
> TO '/tmp/TDE_export.exp'
> FORCE KEYSTORE IDENTIFIED BY EXTERNAL STORE;
> ```
>
> ✅ **Recommendation:**
> Backups must be performed directly using HSM tools. If you need a backup outside the HSM, consider reverse migration to a software keystore.

## ✅ Step 4: Confirm the New Key

Run the query again to confirm that a new key has been generated and activated:

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

Alternatively check TDE configuration using the script *ssenc_info.sql*

```sql
@/u01/config/scripts/demo/ssenc_info.sql
```

> ✅ The most recent entry should reflect the newly generated key in the HSM keystore.
