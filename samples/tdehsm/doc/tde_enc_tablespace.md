# 🧪 Use Case: Online encrypt Tablespaces

This guide explains how to create a new master encryption key directly within the Hardware Security Module (HSM), ensuring that the key material never leaves the secure keystore.

> 📘 Prerequisites:
>
> - Database is configured for TDE either using a software keystore or HSM-based
> - Keystore is open and accessible

## 🔄 Steps Overview

1. Online encrytion of the tablespace **USERS** and **AUDIT_DATA**. 
2. Verify TDE configuration and key.

## 🔑 Step 1: Online encrypt Tablespaces

Manual encrypt tablespace **USERS** and **AUDIT_DATA**.

```sql
ALTER TABLESPACE users ENCRYPTION ONLINE USING 'AES256' ENCRYPT;
ALTER TABLESPACE audit_data ENCRYPTION ONLINE USING 'AES256' ENCRYPT;
```

Optional use the script *15_encrypt_ts.sql*

```sql
@/u01/config/scripts/15_encrypt_ts.sql
```

## 🔑 Step 2: Check the TDE Configuration and Key

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

> ✅ At this point, TDE is active and tablespaces are encrypt. The loss of the key memory means **loss of data** in any case.
