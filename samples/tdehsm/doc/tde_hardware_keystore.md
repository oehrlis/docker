# 🧪 Use Case 1B: Hardware Keystore

This guide explains how to configure Oracle Transparent Data Encryption (TDE) using a Hardware Security Module (HSM) as the primary keystore from the beginning. It is ideal for new deployments where enhanced key protection and centralized security management are required.

> 📘 Prerequisites:
>
> - HSM client library installed and accessible
> - PKCS#11 configuration tested and operational
> - HSM credentials available and verified

## 📖 Overview

This use case configures Oracle TDE to use an HSM-based keystore directly — without prior use of a software keystore. It includes wallet environment setup, PKCS#11 access configuration, external store for auto-login, and creating a master encryption key.

The following steps are performed:

- Define `WALLET_ROOT` and `EXTERNAL_KEYSTORE_CREDENTIAL_LOCATION`
- Restart the database to apply the parameter changes
- Configure TDE to use the HSM keystore and AES256 as the default encryption algorithm
- Store the HSM password securely using an external store (SEPS)
- Open the keystore using the password from SEPS
- Create the initial master encryption key
- Verify PKCS#11 library usage
- Restart database and reopen keystore if autologin is not configured
- Confirm wallet status and key presence

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

## ⚙️ Step 2: Configure TDE to Use HSM

Set the `TDE_CONFIGURATION` parameter and the default encryption algorithm.

```sql
ALTER SYSTEM SET tde_configuration = 'KEYSTORE_CONFIGURATION=HSM' SCOPE = BOTH;
ALTER SYSTEM SET "_tablespace_encryption_default_algorithm" = 'AES256' SCOPE = BOTH;
```

## ⚙️ Step 3: Create an EXTERNAL STORE for the HSM password

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

## 🔓 Step 4: Open the HSM Keystore

Open the keystore using the password from the external store:

```sql
ADMINISTER KEY MANAGEMENT SET KEYSTORE OPEN IDENTIFIED BY EXTERNAL STORE;
```

In the alert log you should see that the HSM PKCS#11 library is loaded:

```text
...
2025-05-07T06:17:05.186008+00:00
KZTDE: Attempting TDE operation in PDB#=0: ADMINISTER KEY MANAGEMENT ADD SECRET *
  FOR CLIENT 'HSM_PASSWORD'
  TO LOCAL AUTO_LOGIN KEYSTORE '/u00/app/oracle/admin/TDEHSM01/wallet/tde_seps'
2025-05-07T06:17:18.470975+00:00
KZTDE: Attempting TDE operation in PDB#=0: ADMINISTER KEY MANAGEMENT SET KEYSTORE OPEN IDENTIFIED BY EXTERNAL STORE
KZTDE:kzezthsm: Third-party HSM used with Oracle DB
KZTDE:kzezthsm: Manufacturer ID: Securosys SA                     and Library description: PKCS#11 Library
2025-05-07T06:17:35.893738+00:00
...
```

## 🔑 Step 5: Check Current Wallet Status

Check the current status of the hardware keystore

```sql
SET LINESIZE 160 PAGESIZE 200
COL wrl_type FOR A10
COL wrl_parameter FOR A50
COL status FOR A20
COL wallet_type FOR A20
COL wallet_order FOR A20
SELECT wrl_type, wrl_parameter, status, wallet_type,wallet_order FROM v$encryption_wallet;
```

The wallet status is now set to HSM and open without master encryption key. See the output of the query above:

```sql
WRL_TYPE   WRL_PARAMETER  STATUS             WALLET_TYPE      WALLET_ORDER
---------- -------------- ------------------ ---------------- --------------------
HSM                       OPEN_NO_MASTER_KEY HSM              SINGLE
```

## 🔑 Step 6: Create Initial Master Encryption Key

Create a master encryption key by using the *EXTERNAL STORE*. We can specify a backup whereby no backup will be configured.

```sql
ADMINISTER KEY MANAGEMENT SET ENCRYPTION KEY IDENTIFIED BY EXTERNAL STORE WITH BACKUP USING 'initial_hsm_key';
```

Now check the status once more to see if we have master encryption key.

```sql
SET LINESIZE 160 PAGESIZE 200
COL wrl_type FOR A10
COL wrl_parameter FOR A50
COL status FOR A20
COL wallet_type FOR A20
COL wallet_order FOR A20
SELECT wrl_type, wrl_parameter, status, wallet_type,wallet_order FROM v$encryption_wallet;
```

See the output of the query above:

```sql
WRL_TYPE   WRL_PARAMETER  STATUS             WALLET_TYPE      WALLET_ORDER
---------- -------------- ------------------ ---------------- --------------------
HSM                       OPEN               HSM              SINGLE
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

## 🧪 Step 7: Check PKCS#11 Library Registration

Verify if we have the corresponding library loaded. Below command is intend to be used directly from SQLPlus. Otherwise you would have to omit the host command.

```bash
host pmap $(pgrep -f ora_gen0_.*) | grep libprimusP11
```

> ✅ If the library appears in the memory map, it has been successfully loaded by the database process.

## 🔄 Step 8: Restart and Reopen Keystore (If Needed)

Restart the database to make sure the HSM keystore is now working as expected. As we do not have autologin configered the HSM based keystore does have to be opened manually.

```sql
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ADMINISTER KEY MANAGEMENT SET KEYSTORE OPEN IDENTIFIED BY EXTERNAL STORE;
ALTER DATABASE OPEN;
```

## ✅ Step 9: Final Verification

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

Check TDE configuration using the script *ssenc_info.sql*

```sql
@/u01/config/scripts/demo/ssenc_info.sql
```

> ✅ TDE is now active with the master encryption key securely managed by the HSM. Feel free to encrypt tablespaces and columns.
