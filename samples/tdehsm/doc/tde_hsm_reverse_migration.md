## 🧪 Use Case 4: Reverse Migration to Software Keystore

This guide describes how to safely migrate the TDE master encryption key from an HSM-based keystore back to a software-based keystore (wallet). This can be required in case of HSM decommissioning, platform migration, or test-to-dev transfer.

> ⚠️ Prerequisites:
> - Both software and HSM keystores must be configured and accessible
> - Sufficient privileges (`SYSKM` or `SYSDBA`)

### 🔄 Steps Overview

1. Ensure `wallet_root` and keystore parameters are properly set
2. Open both HSM and software keystores
3. Export key from HSM and import into software keystore
4. Set software keystore as active
5. Restart and verify new wallet

_Detailed SQL and shell instructions will be provided._
