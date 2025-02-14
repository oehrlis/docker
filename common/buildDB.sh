#!/bin/bash
# ----------------------------------------------------------------------------
# Trivadis - Part of Accenture, Platform Factory - Transactional Data Platform
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ----------------------------------------------------------------------------
# Name.......: buildDB.sh 
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
DOCKER_USER=${DOCKER_USER:-"trivadis"}                  # Docker registry user
DOCKER_REPO=${DOCKER_REPO:-"ora_db"}                    # Docker repository name
DOCKER_BASE_IMAGE=${DOCKER_BASE_IMAGE:-"oraclelinux:8"} # Base image for the Docker build
SCRIPT_NAME=$(basename $0)
BUILD_PLATFORMS=${BUILD_PLATFORMS:-"arm64,amd64"}       # Default platforms for multi-arch builds
VERBOSE=0                                               # Verbose mode
DRY_RUN=0                                               # Dry run mode
SOFTWARE_REPO=""
BUILDER="default"
LOCAL_REPO="pull"
declare -a BUILD_OPTS
RELEASES=""
SOFTWARE_SOURCE=""                                      # Path to software binaries
DOCKER_BUILD_BASE="$(cd $(dirname $0)/.. 2>&1 >/dev/null; pwd -P)" # Base path for Docker builds
# - End of Customization -----------------------------------------------------

# - Functions ----------------------------------------------------------------

# Function: usage
# Description: Display usage help message and exit
usage() {
    echo "Usage: $SCRIPT_NAME [options]"
    echo
    echo "Options:"
    echo "  -n                      Dry run, simulate the build without running 'buildx'"
    echo "  -h                      Display this help message"
    echo "  -l                      List available Oracle versions"
    echo "  -s <repo>               Specify software repository"
    echo "  -S <path>               Provide local software repository path"
    echo "  -u <builder>            Specify buildx builder (default: '${BUILDER}')"
    echo "  -o <build options>      Specify build options (default: '${BUILD_OPTS[@]}')"
    echo "  -U <Docker User>        Specify Docker User (default: '${DOCKER_USER}')"
    echo "  -R <Docker Repository>  Specify Docker Repository (default: '${DOCKER_REPO}')"
    echo "  -v                      Enable verbose mode"
    echo "  -r <releases>           Oracle releases to build"
    echo "  -i <pull>               Pull image to local repository e.g. 'pull' (default: '${LOCAL_REPO}')"
    echo "  -p <platforms>          Specify platforms (e.g., 'arm64,amd64'). Default: both"
    echo
    echo "Examples:"
    echo "  $SCRIPT_NAME -p arm64 -s myrepo 19c_latest"
    echo "  $SCRIPT_NAME -n 21c"
    exit 1
}

# Function: list_versions
# Description: List available Oracle database versions based on Dockerfiles
list_versions() {
    echo "Available Oracle versions:"
    ls ${DOCKER_BUILD_BASE}/OracleDatabase/*/*.Dockerfile 2>/dev/null | \
        xargs -n1 basename | sed 's/\.Dockerfile//' | sort
    exit 0
}

# Function: copy_binaries
# Description: Copy necessary Oracle binaries for each platform to the build directory
copy_binaries() {
    for PLATFORM in $(echo $BUILD_PLATFORMS|sed s/\,/\ /g); do
        # Derive paths for platform-specific software
        SOFTWARE_LIST=${DOCKER_BUILD_BASE}/OracleDatabase/${MAJOR_RELEASE}/software/${PLATFORM}/RU_${RU_VERSION}/oracle_package_names_${PLATFORM}
        DEST_DIR_BASE=${DOCKER_BUILD_BASE}/OracleDatabase/${MAJOR_RELEASE}/software/${PLATFORM}
        DEST_DIR_RU=${DEST_DIR_BASE}/RU_${RU_VERSION}

        # Validate software list
        if [ ! -f "$SOFTWARE_LIST" ]; then
            echo "ERROR: Software list file $SOFTWARE_LIST not found."
            exit 1
        fi

        # Load software file list
        source "$SOFTWARE_LIST"

        # Files to copy for each platform
        FILES_TO_COPY=("$DB_BASE_PKG" "$DB_PATCH_PKG" "$DB_OJVM_PKG" "$DB_OPATCH_PKG" "$DB_JDKPATCH_PKG" "$DB_PERLPATCH_PKG")

        echo "INFO: Copying binaries for platform ${PLATFORM} from $SOFTWARE_SOURCE"
        for FILE in "${FILES_TO_COPY[@]}"; do
            if [ -n "$FILE" ]; then
                if [ "$FILE" == "$DB_BASE_PKG" ]; then
                    DEST=$DEST_DIR_BASE
                else
                    DEST=$DEST_DIR_RU
                fi

                # Validate file existence
                if [ ! -f "$SOFTWARE_SOURCE/$FILE" ]; then
                    echo "ERROR: File $SOFTWARE_SOURCE/$FILE not found."
                    exit 1
                fi

                # Copy file
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

# Function: cleanup_binaries
# Description: Clean up copied binaries after the build process
cleanup_binaries() {
    for PLATFORM in $(echo $BUILD_PLATFORMS|sed s/\,/\ /g); do
        echo "INFO: Cleaning up binaries after build."
        SOFTWARE_LIST=${DOCKER_BUILD_BASE}/OracleDatabase/${MAJOR_RELEASE}/software/${PLATFORM}/RU_${RU_VERSION}/oracle_package_names_${PLATFORM}
        DEST_DIR_BASE=${DOCKER_BUILD_BASE}/OracleDatabase/${MAJOR_RELEASE}/software/${PLATFORM}
        DEST_DIR_RU=${DEST_DIR_BASE}/RU_${RU_VERSION}

        # Validate software list
        if [ ! -f "$SOFTWARE_LIST" ]; then
            echo "ERROR: Software list file $SOFTWARE_LIST not found."
            exit 1
        fi

        # Remove copied files
        source "$SOFTWARE_LIST"
        FILES_TO_REMOVE=("$DB_BASE_PKG" "$DB_PATCH_PKG" "$DB_OJVM_PKG" "$DB_OPATCH_PKG" "$DB_JDKPATCH_PKG" "$DB_PERLPATCH_PKG")
        for FILE in "${FILES_TO_REMOVE[@]}"; do
            if [ -n "$FILE" ]; then
                if [ "$FILE" == "$DB_BASE_PKG" ]; then
                    DEST=$DEST_DIR_BASE
                else
                    DEST=$DEST_DIR_RU
                fi

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

# - Parse Command-Line Parameters --------------------------------------------
while getopts "nhls:S:o:r:u:U:R:i:vp:" opt; do
    case $opt in
        n) DRY_RUN=1 ;;                     # Enable dry run
        h) usage ;;                         # Show usage
        l) list_versions ;;                 # List Oracle versions
        s) SOFTWARE_REPO=$OPTARG ;;         # Specify software repository
        S) SOFTWARE_SOURCE=$OPTARG ;;       # Specify local software source path
        u) BUILDER=$OPTARG ;;               # Specify builder
        U) DOCKER_USER=$OPTARG ;;           # Specify docker user
        R) DOCKER_REPO=$OPTARG ;;           # Specify docker repository
        v) VERBOSE=1 ;;                     # Enable verbose mode
        o) eval "BUILD_OPTS=(${OPTARG})";;  # Build Option
        r) RELEASES=$OPTARG ;;              # Oracle Releases
        i) LOCAL_REPO=$OPTARG ;;            # Oracle local
        p) BUILD_PLATFORMS=$OPTARG ;;       # Specify platforms to build for
        *) usage ;;
    esac
done
shift $((OPTIND - 1))

# Validate parameters
if [ -z "$RELEASES" ]; then
    echo "ERROR: No Oracle versions specified."
    usage
fi

if [ -z "$SOFTWARE_SOURCE" ]; then
    echo "ERROR: Local software repository path not specified. Use -S <path>."
    exit 1
fi

DOCKER_BUILD_PLATFORMS=$(echo "$BUILD_PLATFORMS" | sed 's/[^,]*/linux\/&/g')

# - Verbose Mode -------------------------------------------------------------
if [ $VERBOSE -eq 1 ]; then
    set -x
fi

# - Dry Run Check ------------------------------------------------------------
if [ $DRY_RUN -eq 1 ]; then
    echo "INFO: Dry run mode enabled. No actual build will be performed."
fi

# - Main Build Logic ---------------------------------------------------------
BUILD_OPTS=("--build-arg" "BASE_IMAGE=${DOCKER_BASE_IMAGE}" "${BUILD_OPTS[@]}")
for BUILD_VERSION in $(echo $RELEASES | sed s/\,/\ /g); do
    DOCKER_FILE=$(ls ${DOCKER_BUILD_BASE}/OracleDatabase/*/*${BUILD_VERSION}.Dockerfile 2>/dev/null)
    echo "DOCKER_FILE=> $DOCKER_FILE"
    MAJOR_RELEASE=$(echo ${DOCKER_FILE} | awk -F'/' '{print $(NF-1)}')
    RU_VERSION="${BUILD_VERSION}"

    if [ -f "$DOCKER_FILE" ]; then
        DOCKER_BUILD_DIR=$(dirname $DOCKER_FILE)
        echo "INFO: -----------------------------------------------------------------"
        echo "INFO: Building Docker images $BUILD_VERSION for platform $BUILD_PLATFORMS"
        echo "INFO: Dockerfile          => ${DOCKER_FILE}"
        echo "INFO: Base image          => ${DOCKER_BASE_IMAGE}"
        echo "INFO: Docker TAG          => ${DOCKER_USER}/${DOCKER_REPO}"
        echo "INFO: Software Repository => ${SOFTWARE_REPO:-n/a}"
        echo "INFO: Software Source     => ${SOFTWARE_SOURCE}"
        echo "INFO: Builder             => ${BUILDER}"
        echo "INFO: Build Options       => ${BUILD_OPTS[@]}"
        echo "INFO: Major Release       => ${MAJOR_RELEASE}"
        echo "INFO: Release Update      => ${RU_VERSION}"
        echo "INFO: -----------------------------------------------------------------"

        copy_binaries

        if [ $DRY_RUN -eq 0 ]; then
            time docker buildx build ${DOCKER_BUILD_DIR} --push \
                "${BUILD_OPTS[@]}" \
                --tag ${DOCKER_USER}/${DOCKER_REPO}:${BUILD_VERSION} \
                --platform=${DOCKER_BUILD_PLATFORMS} \
                --file $DOCKER_FILE
            if [[ "$(echo "$LOCAL_REPO" | tr '[:upper:]' '[:lower:]')" == "pull" ]]; then
                docker pull ${DOCKER_USER}/${DOCKER_REPO}:${BUILD_VERSION}
                docker tag ${DOCKER_USER}/${DOCKER_REPO}:${BUILD_VERSION} oracle/database:${BUILD_VERSION}
            fi
            docker buildx prune --force
        else
            echo "DRY RUN: docker buildx build ${DOCKER_BUILD_DIR} --push \
                ${BUILD_OPTS[@]} \
                --tag ${DOCKER_USER}/${DOCKER_REPO}:${BUILD_VERSION} \
                --platform=${DOCKER_BUILD_PLATFORMS} \
                --file $DOCKER_FILE"
            if [[ "$(echo "$LOCAL_REPO" | tr '[:upper:]' '[:lower:]')" == "pull" ]]; then
                echo "DRY RUN: docker pull ${DOCKER_USER}/${DOCKER_REPO}:${BUILD_VERSION}"
                echo "DRY RUN: docker tag ${DOCKER_USER}/${DOCKER_REPO}:${BUILD_VERSION} oracle/database:${BUILD_VERSION}"
            fi
            echo "DRY RUN: docker buildx prune --force"
        fi

        cleanup_binaries
    else
        echo "WARN: Dockerfile $DOCKER_FILE not found for $BUILD_VERSION"
    fi

done

# - Cleanup and Exit ---------------------------------------------------------
set +x
echo "INFO: Script execution completed."

# --- EOF --------------------------------------------------------------------
