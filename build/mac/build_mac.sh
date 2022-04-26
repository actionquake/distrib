#!/bin/bash

RAW_ARCH=$1
PACKAGE_TYPE=$2
CURRENT_DIR=$(pwd)

if [[ -z ${RAW_ARCH} || -z ${PACKAGE_TYPE} ]]
then
    echo "How to use this script:"
    echo "./build_mac.sh [intel|m1] [standalone|steam]"
    echo "The first argument for building for intel or m1 processors"
    echo "The second argument for building standalone or Steam packages"
    echo "Re-run with the appropriate arguments"
    exit 1
fi

ARCH=$(echo ${RAW_ARCH} | tr '[:upper:]' '[:lower:]')
if [[ ${ARCH} -ne "intel" || ${ARCH} -ne "m1" ]]
then
    echo "First argument must be one of [intel | m1]"
    exit 1
fi

PACKAGE_TYPE=$(echo ${PACKAGE_TYPE} | tr '[:upper:]' '[:lower:]')
if [[ ${PACKAGE_TYPE} -ne "standalone" || ${PACKAGE_TYPE} -ne "steam" ]]
then
    echo "Second argument must be one of [standalone | steam]"
    exit 1
fi

echo "Building for ${ARCH}"
echo "Package typing is ${PACKAGE_TYPE}"
echo "Current dir is ${CURRENT_DIR}"
echo "Proceeding with build..."

Q2PRO_DIR="q2pro"
## Cleanup /tmp/q2pro
rm -rf ${Q2PRO_DIR}

## Clone repository
git clone https://github.com/skullernet/q2pro.git ${Q2PRO_DIR}

## Build using standard config file unless 'steam' is second argument to script, then use the steam config
if [[ ${PACKAGE_TYPE} = "standalone" ]]
then
    cp config_mac_${ARCH} ${Q2PRO_DIR}/config_mac
elif [[ ${PACKAGE_TYPE} = "steam" ]]
then
    cp config_mac_${ARCH}_steam ${Q2PRO_DIR}/config_mac
else
    echo "You somehow got this far without specifying a package type, well done.  Exiting"
    exit 1
fi

echo "Copying build config file for ${ARCH} ${PACKAGE_TYPE} successful"

## Apple Silicon M1 needs a special Makefile
if [[ ${ARCH} = "m1" ]]; then
    cp aq2tng_Makefile_mac_m1 ${Q2PRO_DIR}/Makefile
    echo "Copying m1 Makefile successful"
fi

## Patch system.c patch file to make Mac paths work
cp mac_dirpath.patch ${Q2PRO_DIR}/src/unix/
cd ${Q2PRO_DIR}/src/unix
patch < mac_dirpath.patch
cd ../../../

## Build the binaries
cd ${Q2PRO_DIR} || return
export CONFIG_FILE=config_mac;export PKG_CONFIG_PATH="/usr/local/Cellar/openal-soft/1.21.1/lib/pkgconfig/";make -j2 V=1
build_exitcode=$?


## Copy files in preparation for the build step
if [[ ${build_exitcode} -eq 0 ]]; then
    echo "Build successful!  Copying relevant files"
    cp ${CURRENT_DIR}/${Q2PRO_DIR}/q2pro ${CURRENT_DIR}/q2probuilds/${ARCH}/q2pro_${PACKAGE_TYPE}
    cp ${CURRENT_DIR}/${Q2PRO_DIR}/q2proded ${CURRENT_DIR}/q2probuilds/${ARCH}/q2proded_${PACKAGE_TYPE}
    cp ${CURRENT_DIR}/${Q2PRO_DIR}/game*.so ${CURRENT_DIR}/q2probuilds/${ARCH}
else
    echo "Error occurred during build step: Copying q2pro files"
    echo "Exiting script!"
    exit 1
fi

## Cleanup task
rm -rf ${CURRENT_DIR}/q2pro

echo "Script complete for ${ARCH} ${PACKAGE_TYPE}"