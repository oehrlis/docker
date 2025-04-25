#!/bin/bash
# ------------------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# ------------------------------------------------------------------------------
# Name.......: 10_check_oudbase.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
# Date.......: 2025.01.17
# Version....: v1.0.0
# Purpose....: Start configuration for tencs1 and set lock file to "running"
# Notes......: This script initializes the configuration for tencs1
# Reference..: --
# License....: Apache License Version 2.0
# ------------------------------------------------------------------------------
# Modified...:
# see git revision history with git log for more information on changes
# ------------------------------------------------------------------------------

# - Customization --------------------------------------------------------------
# - just add/update any kind of customized environment variable here

# - End of Customization -------------------------------------------------------

# - Default Values -------------------------------------------------------------
# Extract the expected host name from the script file name
SCRIPT_NAME=$(basename "$0")
# - EOF Default Values ---------------------------------------------------------

# - Functions ------------------------------------------------------------------
# ------------------------------------------------------------------------------
# Purpose....: Download and install OraDBA Scripts from GitHub
# ------------------------------------------------------------------------------
install_oradba() {
    # Download and install the new version
    export GITHUB_URL="https://codeload.github.com/oehrlis/oradba/zip/master"
    export ORADBA_PKG="oradba.zip"
    DOWNLOAD="/tmp/oradba_download"
    
    echo "INFO: Get OraDBA scripts"
    mkdir -p ${DOWNLOAD}                                    # create download folder
    curl -Lf ${GITHUB_URL} -o ${DOWNLOAD}/${ORADBA_PKG}
    
    # Unzip the package
    unzip ${DOWNLOAD}/${ORADBA_PKG} -d ${ORACLE_BASE}/local/
    mv ${ORACLE_BASE}/local/oradba-master ${ORACLE_BASE}/local/oradba           # get rid of master folder
    mv ${ORACLE_BASE}/local/oradba/README.md ${ORACLE_BASE}/local/oradba/doc    # move documentation
    rm ${ORACLE_BASE}/local/oradba/.gitignore   
    
    # Clean up
    rm -rf ${DOWNLOAD}
}
# - EOF Functions --------------------------------------------------------------

# Check if oudbase is installed and compare versions
if [[ -d "$ORACLE_BASE/local/oradba" ]]; then
    LOCAL_VERSION=$(cat "$ORACLE_BASE/local/oradba/VERSION")
    GITHUB_VERSION=$(curl -s https://raw.githubusercontent.com/oehrlis/oradba/refs/heads/master/VERSION)
    
    if [[ "$LOCAL_VERSION" == "$GITHUB_VERSION" ]]; then
        echo "INFO: OraDBA is up to date. Version: $LOCAL_VERSION"
    else
        echo "INFO: OraDBA version mismatch. Local: $LOCAL_VERSION, GitHub: $GITHUB_VERSION"
        echo "INFO: Updating OraDBA from GitHub..."
        
        # Remove the old version
        rm -rf "$ORACLE_BASE/local/oradba"
        
        # Install the new version
        install_oradba
        
        echo "INFO: OraDBA updated successfully to version $GITHUB_VERSION."
    fi
else
    echo "INFO: OraDBA is not installed. Installing from GitHub..."
    # Install the new version
    install_oradba
    
    echo "INFO: OraDBA installed successfully."
fi
# - EOF ------------------------------------------------------------------------