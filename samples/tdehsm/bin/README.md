# bin/

This folder contains project utility scripts to support setup and runtime operations.

## 🔧 Scripts

- `check_hsm_mounts.sh`: Verifies presence of required HSM config files (primus.cfg, .secrets.cfg).
- `install_primus_rpm.sh`: Copies and installs the appropriate Securosys PKCS#11 RPM into the running Oracle container.

These scripts can be run from **any working directory** and will automatically resolve the base project path.

## 📦 Usage

```bash
# Check HSM config before startup
./bin/check_hsm_mounts.sh

# Start container from project root folder
docker-compose up -d

# Install HSM PKCS#11 library
./bin/install_primus_rpm.sh
