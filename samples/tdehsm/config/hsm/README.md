# config/hsm

This folder contains the required binary files and the configuration for the HSM integration with Securosys Primus. As these files are not part of the Git repository, you must add them to this folder before setting up the container.

## Key Files

- `primus.cfg` → Must be mounted to `/etc/primus/primus.cfg`
- `.secrets.cfg` → Must be mounted to `/etc/primus/.secrets.cfg`
- `*.rpm` → PKCS#11 libraries for *x86_64* and *aarch64*
- `*_credentials_*.txt` → Credential files for HSM sandbox access

Use this folder to test HSM-backed TDE environments securely.
