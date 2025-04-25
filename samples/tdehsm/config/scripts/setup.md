nid TARGET=sys/LAB42-Schulung DBNAME=TENC

alter system set db_name='TENC' scope=spfile;

System altered.

SQL> startup force mount;
ORACLE instance started.

Total System Global Area  805305464 bytes
Fixed Size		    8944760 bytes
Variable Size		  234881024 bytes
Database Buffers	  553648128 bytes
Redo Buffers		    7831552 bytes
Database mounted.
SQL> alter database open resetlogs;



connect target sys/LAB42-Schulung@TDEHSM01
connect auxiliary sys/LAB42-Schulung@TDEHSM02

run {
allocate channel eugen type disk;
allocate auxiliary channel hanni type disk;

duplicate target database for standby from active database;
}


ALTER SYSTEM SET STANDBY_FILE_MANAGEMENT=AUTO;


ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 GROUP 10 ('/u01/app/oracle/oradata/DB11G/standby_redo01.log') SIZE 50M;
ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 GROUP 11 ('/u01/app/oracle/oradata/DB11G/standby_redo02.log') SIZE 50M;
ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 GROUP 12 ('/u01/app/oracle/oradata/DB11G/standby_redo03.log') SIZE 50M;
ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 GROUP 13 ('/u01/app/oracle/oradata/DB11G/standby_redo04.log') SIZE 50M;

create configuration 'dg_tenc' as  primary database is 'TDEHSM01' connect identifier is tdehsm01;
add database 'TDEHSM02' as connect identifier is tdehsm02;
enable configuration;



<!-- markdownlint-disable MD041 -->
# Transparent Data Encryption Configuration

**Excerpt:** The *TDE Configuration* chapter provides a comprehensive overview
of *Oracle Transparent Data Encryption (TDE)*, including the essential steps
required for its configuration. It covers the setup of initialization parameters,
creation of the software keystore, and management of encryption keys, ensuring
secure data at rest within Oracle databases.

## About Transparent Data Encryption Configuration

*Oracle Transparent Data Encryption (TDE)* does not require any additional
installation since it is part of the *Oracle Enterprise Edition* installation.
However, several configuration steps are necessary before tablespaces or columns
can be encrypted. These steps include modifying the initialization parameters
`WALLET_ROOT` and `TDE_CONFIGURATION`, as well as creating a software keystore
and a master encryption key. Alternatively, an external keystore in
*Oracle Key Vault (OKV)* or a *Hardware Security Module (HSM)* can also be used.

The search order for the TDE keystore depends on how the instance initialization
parameters, `sqlnet.ora` parameters, or environment variables are set. The
`sqlnet.ora` parameter `ENCRYPTION_WALLET_LOCATION` is deprecated in Oracle 19c
and replaced by the initialization parameter `WALLET_ROOT`.

For a high-level overview of the entire TDE configuration process, including
roles and responsibilities, refer to the [Configuration at a Glance](#configuration-at-a-glance)
section later in this document. This section provides a concise summary of the
key steps involved in setting up and managing TDE.

Oracle Database retrieves the keystore by searching in these locations in the
following order:

1. The location set by the `WALLET_ROOT` instance initialization parameter
   when the *KEYSTORE_CONFIGURATION* attribute of the `TDE_CONFIGURATION`
   initialization parameter is set to *FILE*. Oracle recommends using this
   parameter to configure the keystore location.
2. If the *KEYSTORE_CONFIGURATION* attribute of the `TDE_CONFIGURATION`
   initialization parameter is not set to *FILE* or `WALLET_ROOT` is not set,
   then the location specified by the `WALLET_LOCATION` setting in
   the `sqlnet.ora` file.
3. If `WALLET_ROOT` and `WALLET_LOCATION` are not set, then the location specified
   by the `ENCRYPTION_WALLET_LOCATION` parameter (now deprecated in favor
   of `WALLET_ROOT`) in the `sqlnet.ora` file.
4. If none of these parameters are set, and if the `ORACLE_BASE` environment
5. variable is set, then the `$ORACLE_BASE/admin/db_unique_name/wallet`
   directory. If `ORACLE_BASE` is not set,
   then `$ORACLE_HOME/admin/db_unique_name/wallet`.

## TDE Administration User

TDE configuration and administration require `SYSKM` or `ADMINISTER KEY MANAGEMENT`
privileges. To ensure tasks are not solely dependent on `SYSDBA` or DBAs and to
maintain proper segregation of duties, a dedicated TDE administration user should
be created. This user will handle TDE-related tasks after the initial
configuration and migration.

For more details on the segregation of duty concept, refer to the
*Oracle Database Encryption - Solution and Concept Guide*.

### Steps to Create TDE Administration Role and User

1. **Create TDE Administration Role**

   Create the role `tde_admin` with the necessary privileges for TDE
   administration based on `SYSKM`:

   ```sql
   CREATE ROLE tde_admin;
   GRANT CREATE SESSION TO tde_admin;
   GRANT ADMINISTER KEY MANAGEMENT TO tde_admin;
   GRANT CREATE JOB TO tde_admin;
   GRANT SELECT ON gv_$wallet TO tde_admin;
   GRANT SELECT ON v_$wallet TO tde_admin;
   GRANT SELECT ON v_$encryption_wallet TO tde_admin;
   GRANT SELECT ON gv_$encryption_wallet TO tde_admin;
   GRANT SELECT ON v_$encrypted_tablespaces TO tde_admin;
   GRANT SELECT ON gv_$encrypted_tablespaces TO tde_admin;
   GRANT SELECT ON v_$database_key_info TO tde_admin;
   GRANT SELECT ON gv_$database_key_info TO tde_admin;
   GRANT SELECT ON v_$encryption_keys TO tde_admin;
   GRANT SELECT ON gv_$encryption_keys TO tde_admin;
   GRANT SELECT ON v_$client_secrets TO tde_admin;
   GRANT SELECT ON gv_$client_secrets TO tde_admin;
   GRANT SELECT ON dba_encrypted_columns TO tde_admin;
   GRANT SELECT ON v_$parameter TO tde_admin;
   GRANT SELECT ON gv_$parameter TO tde_admin;
   ```

2. **Create TDE Administration User**

   Create the TDE administration user `sec_admin` and assign the `tde_admin`
   role along with the `SYSKM` privilege:

   ```sql
   CREATE USER sec_admin NO AUTHENTICATION;
   GRANT tde_admin TO sec_admin;
   GRANT CREATE SESSION TO sec_admin;
   GRANT SYSKM TO sec_admin;
   ```

3. **Set Initial Password**

   Finally, set an initial password for the TDE administration user `sec_admin`:

```bash
echo "Set the password for sec_admin:"
${ORACLE_HOME}/bin/sqlplus -S -L /nolog <<EOFSQL
connect / as sysdba
ALTER USER sec_admin IDENTIFIED BY "$(cat $cda/etc/${ORACLE_SID}_password.txt)";
exit;
EOFSQL

```

::: note
**Note:** This setup ensures that TDE-related tasks are securely managed by a
dedicated user, adhering to the segregation of duties and reducing reliance on
high-privilege accounts like `SYSDBA`.
:::

## TDE Basis and Parameter Configuration

As recommended since Oracle 19c, the keystore location is set by the initialization
parameter `WALLET_ROOT`. This parameter requires a database restart. The following
tasks must be performed by the database administrator or a user with appropriate
privileges.

### Step 1: Set Up Wallet Directories and Parameters

1. **Get the admin directory as a SQL*Plus variable:**

   ```sql
   CONN / AS SYSDBA
   COLUMN admin_path NEW_VALUE admin_path NOPRINT

   SELECT
       substr(value, 1, instr(value, '/', - 1, 1) - 1) admin_path
   FROM
       v$parameter
   WHERE
       name = 'audit_file_dest';
   ```

2. **Create the wallet folders below the admin directory:**

   ```sql
   host mkdir -p &admin_path/wallet
   host mkdir -p &admin_path/wallet/backup
   host mkdir -p &admin_path/wallet/tde
   host mkdir -p &admin_path/wallet/tde_seps
   ```

3. **Set the `WALLET_ROOT` and `EXTERNAL_KEYSTORE_CREDENTIAL_LOCATION` parameters:**

   ```sql
   ALTER SYSTEM SET wallet_root='&admin_path/wallet' SCOPE=SPFILE;
   ALTER SYSTEM SET external_keystore_credential_location='&admin_path/wallet/tde_seps' SCOPE=SPFILE;
   ```

4. **Restart the database to apply the parameter settings:**

   ```sql
   STARTUP FORCE;
   ```

### Step 2: Set TDE Configuration Parameters

1. **Set the `TDE_CONFIGURATION` parameter and the default encryption algorithm:**

   ```sql
   ALTER SYSTEM SET tde_configuration='KEYSTORE_CONFIGURATION=FILE' SCOPE=BOTH;
   ALTER SYSTEM SET "_tablespace_encryption_default_algorithm" = "AES256" SCOPE=BOTH;
   ```

## Configuring the Software Keystore and Master Encryption Key

The keystore should be created only after the parameters have been configured.

::: note
**Note:** Always perform these actions on the open primary database instance. For
RAC setups, create the keystore on one instance and then copy it to others.
:::

### Step 1: Log in and Retrieve Wallet Root

1. **Log in as the TDE administrator and get the `WALLET_ROOT` parameter:**

   ```sql
   COLUMN wallet_root NEW_VALUE wallet_root NOPRINT

   SELECT value wallet_root FROM v$parameter WHERE name = 'wallet_root';
   ```

### Step 2: Create and Configure the Keystore

1. **Create the software keystore in the wallet root directory:**

   ```sql
   ADMINISTER KEY MANAGEMENT CREATE KEYSTORE '&wallet_root/tde' IDENTIFIED BY "<KeystorePassword>";
   ```

2. **Open the keystore:**

   ```sql
   ADMINISTER KEY MANAGEMENT SET KEYSTORE OPEN IDENTIFIED BY "<KeystorePassword>";
   ```

3. **Enable local auto-login for the software keystore:**

   ```sql
   ADMINISTER KEY MANAGEMENT CREATE LOCAL AUTO_LOGIN KEYSTORE FROM
   KEYSTORE '&wallet_root/tde' IDENTIFIED BY "<KeystorePassword>";
   ```

4. **Create a secure external password store for the wallet password:**

   ```sql
   ADMINISTER KEY MANAGEMENT ADD SECRET '<KeystorePassword>' FOR
   CLIENT 'TDE_WALLET' TO LOCAL AUTO_LOGIN KEYSTORE '&wallet_root/tde_seps';
   ```

5. **List the keystore information:**

   ```sql
   SET LINESIZE 160 PAGESIZE 200
   COL wrl_type FOR A10
   COL wrl_parameter FOR A50
   COL status FOR A20
   COL wallet_type FOR A20
   SELECT wrl_type,wrl_parameter,status,wallet_type FROM v$encryption_wallet;
   ```

::: note
**Note:** Although *AUTOLOGIN LOCAL* has been set for the keystore, only *PASSWORD*
is still displayed in the `v$encryption_wallet` view. The wallet type is only
displayed correctly after a database restart.
:::

### Step 3: Create Master Encryption Key

1. **Create a master encryption key:**

   ```sql
   ADMINISTER KEY MANAGEMENT SET ENCRYPTION KEY USING TAG 'initial' FORCE KEYSTORE
   IDENTIFIED BY "<KeystorePassword>" WITH BACKUP USING 'initial_key_backup';
   ```

2. **List keystore information again to confirm:**

   ```sql
   SET LINESIZE 160 PAGESIZE 200
   COL wrl_type FOR A10
   COL wrl_parameter FOR A50
   COL status FOR A20
   COL wallet_type FOR A20
   SELECT wrl_type,wrl_parameter,status,wallet_type FROM v$encryption_wallet;
   ```

::: note
**Note:** As soon as a master encryption key has been defined, you can start
encrypting tablespaces or columns using TDE.
:::

### Step 4: Handling an Existing Keystore on Standby, RAC, and MAA

If an existing keystore has been copied to the standby database, RAC instance,
or any other setup, follow these steps to properly configure and activate it:

1. **List the wallet information to ensure proper setup:**

   ```sql
   SET LINESIZE 160 PAGESIZE 200
   COL wrl_type FOR A10
   COL wrl_parameter FOR A50
   COL status FOR A20
   COL wallet_type FOR A20
   SELECT wrl_type,wrl_parameter,status,wallet_type FROM v$encryption_wallet;
   ```

alter system set events 'immediate trace name file_hdrs level 10';
oradebug setmypid; --require SYSDBA previliage, otherwise user will receive ORA-01031: insufficient privileges
oradebug tracefile_name --Find the generated TRACE file
/u01/app/oracle/product/11.2.0.3/dbhome_1/log/diag/rdbms/testdb/testdb/trace/testdb_ora_14751.trc
1) testdb_ora_14751.trc file contents: a simple a

2. **Log in as the TDE administrator and get the `WALLET_ROOT` parameter:**

   ```sql
   COLUMN wallet_root NEW_VALUE wallet_root NOPRINT

   SELECT value wallet_root FROM v$parameter WHERE name = 'wallet_root';
   ```

3. **Open the existing keystore:**

   ```sql
   ADMINISTER KEY MANAGEMENT SET KEYSTORE OPEN IDENTIFIED BY "<KeystorePassword>";
   ```

4. **Enable local auto-login for the software keystore:**

   ```sql
   ADMINISTER KEY MANAGEMENT CREATE LOCAL AUTO_LOGIN KEYSTORE FROM
   KEYSTORE '&wallet_root/tde' IDENTIFIED BY "<KeystorePassword>";
   ```

5. **Create a secure external password store for the wallet password:**

   ```sql
   ADMINISTER KEY MANAGEMENT ADD SECRET '<KeystorePassword>' FOR
   CLIENT 'TDE_WALLET' TO LOCAL AUTO_LOGIN KEYSTORE '&wallet_root/tde_seps';
   ```

6. **List the wallet information again to confirm proper configuration:**

   ```sql
   SELECT wrl_type,wrl_parameter,status,wallet_type FROM v$encryption_wallet;
   ```

## Configuration at a Glance

### Process Overview

1. **Initial Configuration by DBA**:
   - **Set Configuration Parameters**: The DBA configures essential parameters
    like `WALLET_ROOT` and `TDE_CONFIGURATION` on all relevant instances
    (primary, standby, RAC).
   - **Create Keystore**: The DBA creates the software keystore on the open
     primary database instance. For RAC setups, the keystore is created on one
     instance and then copied to others.
   - **Enable Local Auto-Login**: The DBA enables local auto-login for the
     keystore to facilitate day-to-day operations without requiring manual
     password entry.
   - **Database Restart**: The database is restarted to apply the changes and
     to ensure the keystore is correctly recognized.

2. **Handover to TDE Admin/Application Owner**:
   - **Reset Keystore Password**: After the initial configuration, the
     TDE Admin/Application Owner resets the keystore password to take ownership.
   - **Ongoing Responsibility**: The TDE Admin/Application Owner takes full
     responsibility for the TDE keys, including the wallet and master encryption
     key. This includes ensuring the keystore is regularly backed up and that
     the keystore password is securely stored and never lost.

3. **Operational Collaboration**:
   - **Involvement in Specific Operations**: The DBA must involve the
    TDE Admin/Application Owner in operational tasks that require explicit
    keystore access, such as full database restore, cloning, or other activities
    where auto-login is not sufficient.

### Configuration Details by Environment

- **Single Instance**:
  - Follow the standard process outlined above.
  - DBA handles initial configuration and hands over to the TDE Admin/Application
    Owner after enabling auto-login.

- **Data Guard / Standby**:
  - Configuration parameters are set separately for both the primary and standby databases.
  - The keystore is created on the open primary database and copied to the standby.
  - Ensure that the local auto-login is activated on all standby databases.
  - The TDE Admin/Application Owner assumes responsibility after configuration,
    ensuring synchronization and backups are maintained.

- **Real Application Clusters (RAC)**:
  - The DBA sets configuration parameters on each RAC instance.
  - The keystore is created on one RAC instance and then copied to all other instances.
  - Ensure that the local auto-login is activated on all instances.
  - The TDE Admin/Application Owner manages the keystore across the cluster,
    ensuring it is backed up and secure.

- **Maximum Availability Architecture (MAA) - RAC and Data Guard Combined**:
  - Combines the steps for RAC and Data Guard/Standby configurations.
  - The DBA ensures the keystore is properly distributed across all RAC nodes
    and standby databases.
  - Ensure that the local auto-login is activated on all instances and standby databases.
  - The TDE Admin/Application Owner is responsible for maintaining the keystore
    and its synchronization across this complex setup.

## Configuring the Hardware Keystore

To be documented.
