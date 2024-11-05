#!/bin/bash
# ------------------------------------------------------------------------------
# Trivadis - Part of Accenture, Platform Factory - Transactional Data Platform
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ------------------------------------------------------------------------------
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
# ------------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# ------------------------------------------------------------------------------

# - Customization --------------------------------------------------------------
DOCKER_USER=${DOCKER_USER:-"trivadis"}
DOCKER_REPO=${DOCKER_REPO:-"ora_db"}
BUILD_FLAG=${BUILD_FLAG:-""}
ORAREPO=${ORAREPO:-"orarepo"}
DOCKER_BASE_IMAGE=${DOCKER_BASE_IMAGE:-"oraclelinux:8"}
SCRIPT_NAME=$(basename $0)
BUILD_PLATFORMS="linux/arm64,linux/amd64" # Default platforms
VERBOSE=0
DRY_RUN=0
SOFTWARE_REPO=""
BUILDER="default"
# - End of Customization -------------------------------------------------------

# - Functions ------------------------------------------------------------------
usage() {
    echo "Usage: $SCRIPT_NAME [options] <versions>"
    echo
    echo "Options:"
    echo "  -n                Dry run, simulate the build without running 'buildx'"
    echo "  -h                Display this help message"
    echo "  -l                List available Oracle versions"
    echo "  -s <repo>         Specify software repository"
    echo "  -u <builder>      Specify buildx builder (default: 'default')"
    echo "  -v                Enable verbose mode"
    echo "  -p <platforms>     Specify platforms (e.g., 'arm64,amd64'). Default: both"
    echo
    echo "Examples:"
    echo "  $SCRIPT_NAME -p arm64 -s myrepo 19c_latest"
    echo "  $SCRIPT_NAME -n 21c"
    exit 1
}

list_versions() {
    echo "Available Oracle versions:"
    for i in $(ls ${DOCKER_BUILD_BASE}/OracleDatabase/*/*Dockerfile); do
        version=$(basename $(dirname $i))
        echo "  $version"
    done
    exit 0
}

# - Parse Command-Line Parameters ----------------------------------------------
while getopts "nhls:u:vp:" opt; do
    case $opt in
        n) DRY_RUN=1 ;;
        h) usage ;;
        l) list_versions ;;
        s) SOFTWARE_REPO=$OPTARG ;;
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

# - Verbose Mode ---------------------------------------------------------------
if [ $VERBOSE -eq 1 ]; then
    set -x
fi

# - Dry Run Check --------------------------------------------------------------
if [ $DRY_RUN -eq 1 ]; then
    echo "INFO: Dry run mode enabled. No actual build will be performed."
fi

# - Main Build Logic -----------------------------------------------------------
DOCKER_BUILD_BASE="$(cd $(dirname $0)/.. 2>&1 >/dev/null; pwd -P)"
orarepo_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' orarepo 2>/dev/null)
ORAREPO=${ORAREPO:-${orarepo_ip}}
ORAREPO_FLAG="--add-host=orarepo:${ORAREPO}"

for BUILD_VERSION in $(echo $RELEASES | sed s/\,/\ /g); do
    DOCKER_FILE=$(ls ${DOCKER_BUILD_BASE}/OracleDatabase/*/*${BUILD_VERSION}.Dockerfile 2>/dev/null)

    if [ -f "$DOCKER_FILE" ]; then
        DOCKER_BUILD_DIR=$(dirname $DOCKER_FILE)
        cd ${DOCKER_BUILD_DIR}
        echo "INFO: -----------------------------------------------------------------"
        echo "INFO: Building Docker images $BUILD_VERSION for platform $BUILD_PLATFORMS"
        echo "INFO: from Dockerfile => ${DOCKER_FILE}"
        echo "INFO: with base image => ${DOCKER_BASE_IMAGE}"
        echo "INFO: using build flags => ${BUILD_FLAG}"
        echo "INFO: as Docker TAG ${DOCKER_USER}/${DOCKER_REPO}"
        echo "INFO: ORAREPO => ${ORAREPO}"
        echo "INFO: Builder => ${BUILDER}"
        echo "INFO: -----------------------------------------------------------------"

        if [ $DRY_RUN -eq 0 ]; then
            time docker buildx build ${DOCKER_BUILD_DIR} ${BUILD_FLAG} --push \
                --build-arg "BASE_IMAGE=${DOCKER_BASE_IMAGE}" \
                --build-arg "ORAREPO=${ORAREPO}" \
                --tag ${DOCKER_USER}/${DOCKER_REPO}:${BUILD_VERSION} \
                --platform=${BUILD_PLATFORMS} \
                --file $DOCKER_FILE
            docker pull ${DOCKER_USER}/${DOCKER_REPO}:${BUILD_VERSION}
            docker tag ${DOCKER_USER}/${DOCKER_REPO}:${BUILD_VERSION} oracle/database:${BUILD_VERSION}
            docker buildx prune --force
        else
            echo "INFO: Skipping build due to dry run."
        fi
        cd -
    else
        echo "WARN: Dockerfile $DOCKER_FILE not found for $BUILD_VERSION"
    fi
done

# - Cleanup and Exit -----------------------------------------------------------
set +x
echo "INFO: Script execution completed."

# --- EOF --------------------------------------------------------------
