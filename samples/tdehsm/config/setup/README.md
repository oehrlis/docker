# config/setup

This folder contains **automated setup scripts** that are executed **once**, right after the container is initialized.

- Scripts are executed in ascending numeric order (e.g., `00_`, `01_`, ...)
- They configure TDE, auditing, schema users, VPD policies, and more
- This folder is mounted into the container as `/u01/config`
