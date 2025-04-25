# config/shared

This folder contains runtime network and Oracle Net configuration files.

- `sqlnet.ora`: Used to define the wallet or HSM PKCS#11 library.
- `listener.ora`: Optional listener customization.
- `tnsnames.ora`: Optional TNS entries for local resolution.

This directory is available in the container via mount of `/u01/config` .
