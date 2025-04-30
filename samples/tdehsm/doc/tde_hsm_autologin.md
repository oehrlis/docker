# 🧪 Use Case 4: Enable Auto-Login Functionality for HSM

This guide describes how to simulate auto-login functionality for an HSM by using an additional software keystore to store the HSM partition password.

> 📋 Note:
> Hardware Security Modules (HSM) themselves do not natively support auto-login. However, Oracle TDE allows similar behavior by storing the HSM password securely in an external software keystore.

> 📘 Prerequisites:
>
> - HSM configured and accessible
> - Database instance has HSM wallet open and operational

## 🔄 Steps Overview

1. Retrieve `wallet_root` from `v$parameter`
2. Create a new software keystore
3. Store software keystore password in the external store
4. Enable auto-login on the new software keystore
5. Temporarily change `TDE_CONFIGURATION` to `FILE|HSM`
6. Restart the database
7. Add HSM password secret to software keystore
8. Reset `TDE_CONFIGURATION` back to `HSM|FILE`
9. Restart the database
10. Verify final wallet and key status

## 🧾 Step 1: Get Wallet Root Directory

Determine admin directory and get the corresponding directory path as a *SQL\*Plus* variable for later use:

```sql
COLUMN wallet_root NEW_VALUE wallet_root NOPRINT
SELECT value AS wallet_root FROM v$parameter WHERE name = 'wallet_root';
```

## 🔧 Step 2: Create Software Keystore

Create the software keystore in the wallet root directory:

```sql
ADMINISTER KEY MANAGEMENT CREATE KEYSTORE '&wallet_root/tde' IDENTIFIED BY "<KeystorePassword>";
```

## 🔐 Step 3: Store Software Keystore Password in External Store (SEPS)

Create a secure external password store (SEPS) for the wallet password. This enables the execution of *ADMINISTER KEY MANAGEMENT* without a password or with the use of *EXTERNAL STORE* in the following

```sql
ADMINISTER KEY MANAGEMENT ADD SECRET '<KeystorePassword>' FOR CLIENT 'TDE_WALLET' TO LOCAL AUTO_LOGIN KEYSTORE '&wallet_root/tde_seps';
```

## 🔑 Step 4: Enable Auto-Login on the Software Keystore

Enable local auto-login for the software keystore:

```sql
ADMINISTER KEY MANAGEMENT CREATE LOCAL AUTO_LOGIN KEYSTORE FROM KEYSTORE '&wallet_root/tde' IDENTIFIED BY "<KeystorePassword>";
```

## ⚙️ Step 5: Temporarily Switch TDE Configuration

Change the *TDE_CONFIGURATION* parameter to cover the software keystore as well the HSM.

```sql
ALTER SYSTEM SET TDE_CONFIGURATION = 'KEYSTORE_CONFIGURATION=FILE|HSM' SCOPE=SPFILE;
```

## 🔄 Step 6: Restart the Database

Restart the database to make sure the software keystore is now the primary wallet. At this stage the HSM is not open. No master encryption keys are available, therefore one can not access encrypted data.

```sql
SHUTDOWN IMMEDIATE;
STARTUP;
```

## 🛠️ Step 7: Add HSM Password to Software Keystore

Add the HSM Password to the new software keystore. This will make sure, that it will be used when DB is restarted to open hardware keystore. We do use *FORCE KEYSTORE* as the software keystore is in autologin mode.

```sql
ADMINISTER KEY MANAGEMENT ADD SECRET '<HSMPassword>' FOR CLIENT 'HSM_PASSWORD' FORCE KEYSTORE IDENTIFIED BY EXTERNAL STORE WITH BACKUP USING 'add_hsm_partition_password';
```

## ⚙️ Step 8: Reset TDE Configuration

Set the *TDE_CONFIGURATION* parameter to cover the software keystore as well the HSM, but now make the HSM primary.

```sql
ALTER SYSTEM SET TDE_CONFIGURATION = 'KEYSTORE_CONFIGURATION=HSM|FILE' SCOPE=SPFILE;
```

## 🔄 Step 9: Restart the Database Again

Restart the database to make sure the hardware keystore is now the primary wallet. During restart the hardware keystore will be opened using the HSM password stored in the software keystore. As of now we have the autologin functionality. One can fully access encrypted data.

```sql
SHUTDOWN IMMEDIATE;
STARTUP;
```

## 📋 Step 10: Verify Final Wallet and Key Status

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

> ✅ The database should now auto-open the HSM keystore at startup without manually providing the password.