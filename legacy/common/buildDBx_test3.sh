#!/bin/bash
# ----------------------------------------------------------------------------
# Trivadis - Part of Accenture, Platform Factory - Transactional Data Platform
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ----------------------------------------------------------------------------
# Name.......: buildDBx.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2019.05.06
# Revision...: 2024.10.14 (Enhanced with additional functionality)
# Purpose....: Build script to build Oracle database Docker images for specified platforms
# Notes......: 
#              - Supports multi-platform builds (arm64, amd64) using Docker Buildx
#              - Copies necessary binaries for each platform before building
#              - Cleans up binaries after the build process
#              - Supports dry run mode to simulate the process without execution
# Reference..: --
# License....: Apache License Version 2.0, January 2004 as shown
#              at http://www.apache.org/licenses/
# ----------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# ----------------------------------------------------------------------------

# - Customization ------------------------------------------------------------
DOCKER_USER=${DOCKER_USER:-"trivadis"}           # Docker registry user
DOCKER_REPO=${DOCKER_REPO:-"ora_db"}             # Docker repository name
BUILD_FLAG=${BUILD_FLAG:-""}                     # Additional Docker build flags
ORAREPO=${ORAREPO:-"orarepo"}                   # ORAREPO DNS/IP
DOCKER_BASE_IMAGE=${DOCKER_BASE_IMAGE:-"oraclelinux:8"} # Base image for the Docker build
SCRIPT_NAME=$(basename $0)
BUILD_PLATFORMS=${BUILD_PLATFORMS:-"arm64,amd64"} # Default platforms for multi-arch builds
VERBOSE=0                                         # Verbose mode
DRY_RUN=0                                         # Dry run mode
SOFTWARE_SOURCE=""                               # Path to software binaries
DOCKER_BUILD_BASE="$(cd $(dirname $0)/.. 2>&1 >/dev/null; pwd -P)" # Base path for Docker builds

# - Functions ----------------------------------------------------------------
usage() {
    echo "Usage: $SCRIPT_NAME [options] <versions>"
    echo
    echo "Options:"
    echo "  -n                Dry run, simulate the build without running 'buildx'"
    echo "  -h                Display this help message"
    echo "  -l                List available Oracle versions"
    echo "  -S <path>         Provide local software repository path"
    echo "  -p <platforms>    Specify platforms (e.g., 'arm64,amd64'). Default: both"
    echo "  -v                Enable verbose mode"
    echo
    echo "Examples:"
    echo "  $SCRIPT_NAME -p arm64 -S /my/software/repo 19.25.0.0"
    echo "  $SCRIPT_NAME -n 21c"
    exit 1
}

list_versions() {
    echo "Available Oracle versions:"
    ls ${DOCKER_BUILD_BASE}/OracleDatabase/*/*.Dockerfile 2>/dev/null | \
        xargs -n1 basename | sed 's/\.Dockerfile//' | sort
    exit 0
}

normalize_platforms() {
    # Normalize BUILD_PLATFORMS and prefix each with 'linux/'
    DOCKER_BUILD_PLATFORMS=$(echo "$BUILD_PLATFORMS" | sed 's/[^,]*/linux\/&/g')
}

copy_binaries() {
    for PLATFORM in $(echo $BUILD_PLATFORMS | sed 's/,/ /g'); do
        # Derive paths for platform-specific software
        SOFTWARE_LIST=${DOCKER_BUILD_BASE}/OracleDatabase/${MAJOR_RELEASE}/software/${PLATFORM}/RU_${RU_VERSION}/oracle_package_names_${PLATFORM}
        DEST_DIR_BASE=${DOCKER_BUILD_BASE}/OracleDatabase/${MAJOR_RELEASE}/software/${PLATFORM}
        DEST_DIR_RU=${DEST_DIR_BASE}/RU_${RU_VERSION}

        if [ ! -f "$SOFTWARE_LIST" ]; then
            echo "ERROR: Software list file $SOFTWARE_LIST not found."
            exit 1
        fi

        source "$SOFTWARE_LIST"
        FILES_TO_COPY=($DB_BASE_PKG $DB_PATCH_PKG $DB_OJVM_PKG $DB_OPATCH_PKG $DB_JDKPATCH_PKG $DB_PERLPATCH_PKG)

        echo "INFO: Copying binaries for platform ${PLATFORM} from $SOFTWARE_SOURCE"
        for FILE in "${FILES_TO_COPY[@]}"; do
            if [ -n "$FILE" ]; then
                DEST=$([ "$FILE" == "$DB_BASE_PKG" ] && echo "$DEST_DIR_BASE" || echo "$DEST_DIR_RU")
                if [ ! -f "$SOFTWARE_SOURCE/$FILE" ]; then
                    echo "ERROR: File $SOFTWARE_SOURCE/$FILE not found."
                    exit 1
                fi
                if [ $DRY_RUN -eq 1 ]; then
                    echo "DRY RUN: cp $SOFTWARE_SOURCE/$FILE $DEST/"
                else
                    cp "$SOFTWARE_SOURCE/$FILE" "$DEST/"
                    echo "INFO: Copied $FILE to $DEST/"
                fi
            fi
        done
    done
}

cleanup_binaries() {
    for PLATFORM in $(echo $BUILD_PLATFORMS | sed 's/,/ /g'); do
        echo "INFO: Cleaning up binaries after build for platform $PLATFORM."
        SOFTWARE_LIST=${DOCKER_BUILD_BASE}/OracleDatabase/${MAJOR_RELEASE}/software/${PLATFORM}/RU_${RU_VERSION}/oracle_package_names_${PLATFORM}
        DEST_DIR_BASE=${DOCKER_BUILD_BASE}/OracleDatabase/${MAJOR_RELEASE}/software/${PLATFORM}
        DEST_DIR_RU=${DEST_DIR_BASE}/RU_${RU_VERSION}
        source "$SOFTWARE_LIST"
        FILES_TO_REMOVE=($DB_BASE_PKG $DB_PATCH_PKG $DB_OJVM_PKG $DB_OPATCH_PKG $DB_JDKPATCH_PKG $DB_PERLPATCH_PKG)
        for FILE in "${FILES_TO_REMOVE[@]}"; do
            if [ -n "$FILE" ]; then
                DEST=$([ "$FILE" == "$DB_BASE_PKG" ] && echo "$DEST_DIR_BASE" || echo "$DEST_DIR_RU")
                if [ $DRY_RUN -eq 1 ]; then
                    echo "DRY RUN: rm -f $DEST/$FILE"
                else
                    rm -f "$DEST/$FILE"
                    echo "INFO: Removed $FILE from $DEST/"
                fi
            fi
        done
    done
}

# - Parse Parameters --------------------------------------------------------
while getopts "nhlS:p:v" opt; do
    case $opt in
        n) DRY_RUN=1 ;;
        h) usage ;;
        l) list_versions ;;
        S) SOFTWARE_SOURCE=$OPTARG ;;
        p) BUILD_PLATFORMS=$OPTARG ;;
        v) VERBOSE=1 ;;
        *) usage ;;
    esac
done
shift $((OPTIND - 1))

BUILD_VERSION="$1"
if [ -z "$BUILD_VERSION" ]; then
    echo "ERROR: Build version not specified."
    usage
fi
if [ -z "$SOFTWARE_SOURCE" ]; then
    echo "ERROR: Local software repository path not specified. Use -S <path>."
    exit 1
fi

normalize_platforms

# - Main Build Logic --------------------------------------------------------
DOCKER_FILE=$(ls ${DOCKER_BUILD_BASE}/OracleDatabase/*/*${BUILD_VERSION}.Dockerfile 2>/dev/null)
MAJOR_RELEASE=$(echo ${DOCKER_FILE} | awk -F'/' '{print $(NF-1)}')
RU_VERSION=${BUILD_VERSION}

if [ -f "$DOCKER_FILE" ]; then
    echo "INFO: Building Docker images for platforms ${DOCKER_BUILD_PLATFORMS}"
    copy_binaries
    cleanup_binaries
else
    echo "ERROR: Dockerfile for build version $BUILD_VERSION not found."
    exit 1
fi

# - Exit --------------------------------------------------------------------
echo "INFO: Script execution completed."

# --- EOF -------------------------------------------------------------------
