# 🧪 Use Case 5: Clean Up HSM Partition Using `pkcs11-tool`

> ⚠️ **DANGER ZONE:** Deleting objects from an HSM partition can lead to permanent loss of TDE master keys or data if the keys are still in use. Ensure that keys are no longer associated with any active Oracle instance or backups before proceeding.

This guide explains how to list and clean up HSM-resident objects (e.g., secret keys and data objects) using `pkcs11-tool`.

## 🧾 Step 1: List Existing HSM Objects

Use the following command to inspect all stored objects:

```bash
pkcs11-tool \
  --module /opt/oracle/extapi/64/hsm/primus/2.3.4/libprimusP11.so \
  --login \
  --list-objects \
  --pin <HSMPassword>
```

Look for `type: data` and `type: secrkey` objects — especially those with long hexadecimal labels beginning with `ORACLE.SECURITY.KM.ENCRYPTION.`

## 🧽 Step 2: Delete Data Objects (By Label)

Use this command template to delete a `data` object:

```bash
pkcs11-tool \
  --module /opt/oracle/extapi/64/hsm/primus/2.3.4/libprimusP11.so \
  --login \
  --label 'DATA_OBJECT_SUPPORTED_IDEN' \
  --type data \
  --delete-object \
  --pin <HSMPassword>
```

Another example for an encrypted key data object:

```bash
pkcs11-tool \
  --module /opt/oracle/extapi/64/hsm/primus/2.3.4/libprimusP11.so \
  --login \
  --label 'ORACLE.SECURITY.KM.ENCRYPTION.30363641394237323144384330453446413242463941304537313038443344384133' \
  --type data \
  --delete-object \
  --pin <HSMPassword>
```

## 🔐 Step 3: Delete Secret Key Objects

```bash
pkcs11-tool \
  --module /opt/oracle/extapi/64/hsm/primus/2.3.4/libprimusP11.so \
  --pin <HSMPassword> \
  --delete-object \
  --label "ORACLE.SECURITY.KM.ENCRYPTION.30363641394237323144384330453446413242463941304537313038443344384133" \
  --type secrkey
```

## 🔁 Step 4: Re-List to Confirm Cleanup

After deletion, confirm the objects are removed:

```bash
pkcs11-tool \
  --module /opt/oracle/extapi/64/hsm/primus/2.3.4/libprimusP11.so \
  --login \
  --list-objects \
  --pin <HSMPassword>
```

> ✅ Only perform these actions when you're sure the keys are not in use and backups exist.

## 🧷 Notes

- You can extract object labels beforehand and script deletion based on matches.
- Some HSMs (e.g., Primus) allow secure wipe of partitions via their management CLI — preferred for full cleanup.
- Use consistent labeling/tagging during key generation to easily identify cleanup candidates.
