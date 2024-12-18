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
# Purpose....: Build script to build Oracle database Docker image with various options
# Notes......: Provides parameters for dry run, repository selection, builder, platforms, etc.
# Reference..: --
# License....: Apache License Version 2.0, January 2004 as shown
#              at http://www.apache.org/licenses/
# ----------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# ----------------------------------------------------------------------------

# - Customization ------------------------------------------------------------
DOCKER_USER=${DOCKER_USER:-"trivadis"}
DOCKER_REPO=${DOCKER_REPO:-"ora_db"}
BUILD_FLAG=${BUILD_FLAG:-""}
ORAREPO=${ORAREPO:-"orarepo"}
DOCKER_BASE_IMAGE=${DOCKER_BASE_IMAGE:-"oraclelinux:8"}
SCRIPT_NAME=$(basename $0)
BUILD_PLATFORMS=${BUILD_PLATFORMS:-"arm64,amd64"} # Default platforms if not set
VERBOSE=0
DRY_RUN=0
SOFTWARE_REPO=""
BUILDER="default"
SOFTWARE_SOURCE=""
DOCKER_BUILD_BASE="$(cd $(dirname $0)/.. 2>&1 >/dev/null; pwd -P)"
# - End of Customization -----------------------------------------------------

# - Functions ----------------------------------------------------------------
usage() {
    echo "Usage: $SCRIPT_NAME [options] <versions>"
    echo
    echo "Options:"
    echo "  -n                Dry run, simulate the build without running 'buildx'"
    echo "  -h                Display this help message"
    echo "  -l                List available Oracle versions"
    echo "  -s <repo>         Specify software repository"
    echo "  -S <path>         Provide local software repository path"
    echo "  -u <builder>      Specify buildx builder (default: 'default')"
    echo "  -v                Enable verbose mode"
    echo "  -p <platforms>    Specify platforms (e.g., 'arm64,amd64'). Default: both"
    echo
    echo "Examples:"
    echo "  $SCRIPT_NAME -p arm64 -s myrepo 19c_latest"
    echo "  $SCRIPT_NAME -n 21c"
    exit 1
}

list_versions() {
    echo "Available Oracle versions:"
    ls ${DOCKER_BUILD_BASE}/OracleDatabase/*/*.Dockerfile 2>/dev/null | \
        xargs -n1 basename | sed 's/\.Dockerfile//' | sort
    exit 0
}

copy_binaries() {
    for PLATFORM in $(echo $BUILD_PLATFORMS|sed s/\,/\ /g); do
        SOFTWARE_LIST=${DOCKER_BUILD_BASE}/OracleDatabase/${MAJOR_RELEASE}/software/${PLATFORM}/RU_${RU_VERSION}/oracle_package_names_${PLATFORM}
        DEST_DIR_BASE=${DOCKER_BUILD_BASE}/OracleDatabase/${MAJOR_RELEASE}/software/${PLATFORM}
        DEST_DIR_RU=${DEST_DIR_BASE}/RU_${RU_VERSION}

        if [ ! -f "$SOFTWARE_LIST" ]; then
            echo "ERROR: Software list file $SOFTWARE_LIST not found."
            exit 1
        fi

        source "$SOFTWARE_LIST"

        FILES_TO_COPY=("$DB_BASE_PKG" "$DB_PATCH_PKG" "$DB_OJVM_PKG" "$DB_OPATCH_PKG" "$DB_JDKPATCH_PKG" "$DB_PERLPATCH_PKG")

        echo "INFO: Copying binaries for platform ${PLATFORM} from $SOFTWARE_SOURCE"
        for FILE in "${FILES_TO_COPY[@]}"; do
            if [ -n "$FILE" ]; then
                if [ "$FILE" == "$DB_BASE_PKG" ]; then
                    DEST=$DEST_DIR_BASE
                else
                    DEST=$DEST_DIR_RU
                fi

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
    for PLATFORM in $(echo $BUILD_PLATFORMS|sed s/\,/\ /g); do
        echo "INFO: Cleaning up binaries after build."
        SOFTWARE_LIST=${DOCKER_BUILD_BASE}/OracleDatabase/${MAJOR_RELEASE}/software/${PLATFORM}/RU_${RU_VERSION}/oracle_package_names_${PLATFORM}
        DEST_DIR_BASE=${DOCKER_BUILD_BASE}/OracleDatabase/${MAJOR_RELEASE}/software/${PLATFORM}
        DEST_DIR_RU=${DEST_DIR_BASE}/RU_${RU_VERSION}

        if [ ! -f "$SOFTWARE_LIST" ]; then
            echo "ERROR: Software list file $SOFTWARE_LIST not found."
            exit 1
        fi

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
while getopts "nhls:S:u:vp:" opt; do
    case $opt in
        n) DRY_RUN=1 ;;
        h) usage ;;
        l) list_versions ;;
        s) SOFTWARE_REPO=$OPTARG ;;
        S) SOFTWARE_SOURCE=$OPTARG ;;
        u) BUILDER=$OPTARG ;;
        v) VERBOSE=1 ;;
        p) BUILD_PLATFORMS=$OPTARG ;;
        *) usage ;;
    esac
done
shift $((OPTIND - 1))

RELEASES="$@"

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
orarepo_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' orarepo 2>/dev/null)
ORAREPO=${ORAREPO:-${orarepo_ip}}
ORAREPO_FLAG="--add-host=orarepo:${ORAREPO}"

for BUILD_VERSION in $(echo $RELEASES | sed s/\,/\ /g); do
    DOCKER_FILE=$(ls ${DOCKER_BUILD_BASE}/OracleDatabase/*/*${BUILD_VERSION}.Dockerfile 2>/dev/null)

    MAJOR_RELEASE=$(echo ${DOCKER_FILE} | awk -F'/' '{print $(NF-1)}')
    RU_VERSION="${BUILD_VERSION}"

    if [ -f "$DOCKER_FILE" ]; then
        DOCKER_BUILD_DIR=$(dirname $DOCKER_FILE)
        echo "INFO: -----------------------------------------------------------------"
        echo "INFO: Building Docker images $BUILD_VERSION for platform $BUILD_PLATFORMS"
        echo "INFO: from Dockerfile => ${DOCKER_FILE}"
        echo "INFO: with base image => ${DOCKER_BASE_IMAGE}"
        echo "INFO: using build flags => ${BUILD_FLAG}"
        echo "INFO: as Docker TAG ${DOCKER_USER}/${DOCKER_REPO}"
        echo "INFO: ORAREPO             => ${ORAREPO}"
        echo "INFO: Builder             => ${BUILDER}"
        echo "INFO: Major Release       => ${MAJOR_RELEASE}"
        echo "INFO: -----------------------------------------------------------------"

        copy_binaries

        if [ $DRY_RUN -eq 0 ]; then
            time docker buildx build ${DOCKER_BUILD_DIR} ${BUILD_FLAG} --push \
                --build-arg "BASE_IMAGE=${DOCKER_BASE_IMAGE}" \
                --build-arg "ORAREPO=${ORAREPO}" \
                --tag ${DOCKER_USER}/${DOCKER_REPO}:${BUILD_VERSION} \
                --platform=${DOCKER_BUILD_PLATFORMS} \
                --file $DOCKER_FILE
            docker pull ${DOCKER_USER}/${DOCKER_REPO}:${BUILD_VERSION}
            docker tag ${DOCKER_USER}/${DOCKER_REPO}:${BUILD_VERSION} oracle/database:${BUILD_VERSION}
            docker buildx prune --force
        else
            echo "DRY RUN: docker buildx build ${DOCKER_BUILD_DIR} ${BUILD_FLAG} --push \
                --build-arg BASE_IMAGE=${DOCKER_BASE_IMAGE} \
                --build-arg ORAREPO=${ORAREPO} \
                --tag ${DOCKER_USER}/${DOCKER_REPO}:${BUILD_VERSION} \
                --platform=${DOCKER_BUILD_PLATFORMS} \
                --file $DOCKER_FILE"
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
