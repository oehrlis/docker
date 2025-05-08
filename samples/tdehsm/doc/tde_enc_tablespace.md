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

Verify if there are already encrypted tablespaces:

```sql
SELECT tablespace_name, encrypted FROM dba_tablespaces;
```

Manual encrypt tablespace **USERS** and **AUDIT_DATA**.

```sql
ALTER TABLESPACE users ENCRYPTION ONLINE USING 'AES256' ENCRYPT;
ALTER TABLESPACE audit_data ENCRYPTION ONLINE USING 'AES256' ENCRYPT;
```

Optional use the script *15_encrypt_ts.sql*

```sql
@/u01/config/scripts/15_encrypt_ts.sql
```

## 🔑 Step 2: New encrypt Tablespaces

Manual encrypt tablespace **USERS** and **AUDIT_DATA**.

```sql
CREATE TABLESPACE enc_aes192 DATAFILE '/u01/oradata/TDEHSM01/enc_aes19201TDEHSM01.dbf' 
SIZE 10M ENCRYPTION USING 'AES192' DEFAULT STORAGE (ENCRYPT); 
```

It is also possible to configure the database that all new tablespaces are encrypted. For this set the parameter *ENCRYPT_NEW_TABLESPACES* to **ALWAYS**. This way the tablespace will be transparently encrypted if the *ENCRYPTION … ENCRYPT* clause is not specified in the *CREATE TABLESPACE* statement.

```sql
ALTER SYSTEM SET encrypt_new_tablespaces = 'ALWAYS' SCOPE = BOTH;
```

Create a new tablespace *ENC_ALWAYS*.

```sql
CREATE TABLESPACE enc_always DATAFILE '/u01/oradata/TDEHSM01/enc_always01TDEHSM01.dbf' 
SIZE 10M; 
```

Verify if there are already encrypted tablespaces:

```sql
SELECT tablespace_name, encrypted FROM dba_tablespaces;
```

The default encryption algorithm can be controlled by setting the hidden parameter *_tablespace_encryption_default_algorithm*.

## 🔑 Step 3: Check the TDE Configuration and Key

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

Check TDE configuration using the script *ssenc_info.sql*

```sql
@/u01/config/scripts/demo/ssenc_info.sql
```

> ✅ At this point, TDE is active and tablespaces are encrypt. The loss of the key memory means **loss of data** in any case.
