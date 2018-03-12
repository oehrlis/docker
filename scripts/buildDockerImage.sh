#!/bin/bash
# -----------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------------
# Name.......: buildDockerImage.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: 
# Date.......: 
# Revision...: 
# Purpose....: Build script for docker OUD images 
# Notes......: --
# Reference..: --
# License....: CDDL 1.0 + GPL 2.0
# -----------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# TODO.......:
# -----------------------------------------------------------------------------

# - Customization -----------------------------------------------------------
DOCKERID="oehrlis"
OUD_VERSION="12.2.1.3.0"
VERBOSE="FALSE"                                        # enable verbose mode
# - End of Customization ----------------------------------------------------

# - Default Values ----------------------------------------------------------
VERSION=1.0
DOAPPEND="TRUE"                                        # enable log file append
SCRIPT_NAME=$(basename $0)                             # Basename of the script
SCRIPT_DIR=$(dirname $0)
START_HEADER="START: Start of ${SCRIPT_NAME} (Version ${VERSION}) with $*"
ERROR=0
# - End of Default Values ---------------------------------------------------

# - Functions ---------------------------------------------------------------
# ---------------------------------------------------------------------------
# Purpose....: Display Usage
# ---------------------------------------------------------------------------
function Usage()
{
    VERBOSE="TRUE"
    DoMsg "INFO : Usage, ${SCRIPT_NAME} [-hv] [-t <TYPE>] [-o <DOCKER_BUILD_OPTION>]"
    DoMsg "INFO : "
    DoMsg "INFO :   -h                       Usage (this message)"
    DoMsg "INFO :   -v                       Enable verbose mode"
    DoMsg "INFO :   -t <TYPE>                OUD image and installation type to build. Possible types are:"
    DoMsg "INFO :                            OUD   : Standalone Oracle Unified Directory Server"
    DoMsg "INFO :                            OUDSM : Collocated Oracle Unified Directory Server."
    DoMsg "INFO :                            Default is type is OUD."
    DoMsg "INFO :   -o <DOCKER_BUILD_OPTION> Passes on Docker build option"
    DoMsg "INFO : "
    DoMsg "INFO : Logfile : ${LOGFILE}"

    if [ ${1} -gt 0 ]; then
        CleanAndQuit ${1} ${2}
    else
        VERBOSE="FALSE"
        CleanAndQuit 0
    fi
}

# ---------------------------------------------------------------------------
# Purpose....: Display Message with time stamp
# ---------------------------------------------------------------------------
function DoMsg()
{
    INPUT=${1%:*}                     # Take everything behinde
    case ${INPUT} in                  # Define a nice time stamp for ERR, END
        "END ")  TIME_STAMP=$(date "+%Y-%m-%d_%H:%M:%S");;
        "ERR ")  TIME_STAMP=$(date "+%n%Y-%m-%d_%H:%M:%S");;
        "START") TIME_STAMP=$(date "+%Y-%m-%d_%H:%M:%S");;
        "OK")    TIME_STAMP="";;
        "*")     TIME_STAMP="....................";;
    esac
    if [ "${VERBOSE}" = "TRUE" ]; then
        if [ "${DOAPPEND}" = "TRUE" ]; then
            echo "${TIME_STAMP}  ${1}" |tee -a ${LOGFILE}
        else
            echo "${TIME_STAMP}  ${1}"
        fi
        shift
        while [ "${1}" != "" ]; do
            if [ "${DOAPPEND}" = "TRUE" ]; then
                echo "               ${1}" |tee -a ${LOGFILE}
            else
                echo "               ${1}"
            fi
            shift
        done
    else
        if [ "${DOAPPEND}" = "TRUE" ]; then
            echo "${TIME_STAMP}  ${1}" >> ${LOGFILE}
        fi
        shift
        while [ "${1}" != "" ]; do
            if [ "${DOAPPEND}" = "TRUE" ]; then
                echo "               ${1}" >> ${LOGFILE}
            fi
            shift
        done
    fi
}

# ---------------------------------------------------------------------------
# Purpose....: Clean up before exit
# ---------------------------------------------------------------------------
function CleanAndQuit()
{
    if [ ${1} -gt 0 ]; then
        VERBOSE="TRUE"
    fi
    case ${1} in
        0)  DoMsg "END  : of ${SCRIPT_NAME}";;
        1)  DoMsg "ERR  : Exit Code ${1}. Wrong amount of arguments. See usage for correct one.";;
        2)  DoMsg "ERR  : Exit Code ${1}. Wrong arguments (${2}). See usage for correct one.";;
        3)  DoMsg "ERR  : Exit Code ${1}. Missing mandatory argument ${2}. See usage for correct one.";;
        20) DoMsg "ERR  : Exit Code ${1}. Image type ${2} is unknown. See usage for correct one.";;
        21) DoMsg "ERR  : Exit Code ${1}. There was an error building the image.";;
        99) DoMsg "INFO : Just wanna say hallo.";;
        ?)  DoMsg "ERR  : Exit Code ${1}. Unknown Error.";;
    esac
    exit ${1}
}
# - EOF Functions -----------------------------------------------------------

# - Initialization ----------------------------------------------------------
# Set LOG_BASE to script directory if not defined
if [ -z ${LOG_BASE+x} ]; then
    export LOG_BASE=${SCRIPT_DIR}
    # OK now check if writeable if not set it to /tmp
    if [ ! -w ${LOG_BASE} ]; then
        export LOG_BASE="/tmp"
    fi
fi

LOGFILE="${LOG_BASE}/$(basename ${SCRIPT_NAME} .sh).log"
touch ${LOGFILE} 2>/dev/null
if [ $? -eq 0 ] && [ -w "${LOGFILE}" ]; then
    DOAPPEND="TRUE"
else
    CleanAndQuit 11 ${LOGFILE} # Define a clean exit
fi

# - Main --------------------------------------------------------------------
DoMsg "${START_HEADER}"
if [ $# -lt 1 ]; then
    Usage 1
fi

# usage and getopts
DoMsg "INFO : processing commandline parameter"
while getopts "hvt:o:E:" arg; do
    case $arg in
      h) Usage 0;;
      v) VERBOSE="TRUE";;
      t) IMAGE_TYPE="${OPTARG}";;
      o) DOCKEROPS="$OPTARG";;
      E) CleanAndQuit "${OPTARG}";;
      ?) Usage 2 $*;;
    esac
done

# check image type
if [ -z ${IMAGE_TYPE+x} ]; then
    DoMsg "WARN : Image type not defined, use default value OUD."
    IMAGE_TYPE="OUD"
fi

# change image typ to lower case
IMAGE_TYPE=$(echo ${IMAGE_TYPE} | tr [:upper:] [:lower:])
# OUD Image Name
#IMAGE_NAME="${DOCKERID}/${IMAGE_TYPE}:${OUD_VERSION}"
IMAGE_NAME="${DOCKERID}/${IMAGE_TYPE}"
DOCKERFILE="${SCRIPT_DIR}/../Dockerfile.${IMAGE_TYPE}"
DOCKERDIR="${SCRIPT_DIR}/.."
# identify which image to build
if [ "${IMAGE_TYPE}" = "oud" ] || [ "${IMAGE_TYPE}" = "oudsm" ]; then
    DoMsg "INFO : Image type ${IMAGE_TYPE} selected. Build docker image with standalone OUD."
    BUILD_START=$(date '+%s')
    #docker build --force-rm=true --no-cache=true $DOCKEROPS -t $IMAGE_NAME -f ${DOCKERFILE} ${DOCKERDIR} || CleanAndQuit 21
    docker build $DOCKEROPS -t $IMAGE_NAME -f ${DOCKERFILE} ${DOCKERDIR} || CleanAndQuit 21
    BUILD_END=$(date '+%s')
    BUILD_ELAPSED=$(expr $BUILD_END - $BUILD_START)
else
    DoMsg "INFO : Image type not defined, use default value OUD."
    CleanAndQuit 20 ${IMAGE_TYPE}
fi

DoMsg "INFO : Oracle Unified Directory Docker Image for ${IMAGE_TYPE} is ready"
DoMsg "INFO : Build completed in $BUILD_ELAPSED seconds."
CleanAndQuit 0
# --- EOF -------------------------------------------------------------------