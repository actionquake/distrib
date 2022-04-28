#!/bin/bash

RAW_ARCH=$1
CURRENT_DIR=$(pwd)

if [[ -z ${RAW_ARCH} ]]
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

echo "Building for ${ARCH}"
echo "Current dir is ${CURRENT_DIR}"
echo "Proceeding with build..."

Q2PRO_DIR="q2pro"
## Cleanup /tmp/q2pro
rm -rf ${Q2PRO_DIR}

## Clone repository, copy config file
git clone https://github.com/skullernet/q2pro.git ${Q2PRO_DIR}
cp config_mac_${ARCH} ${Q2PRO_DIR}/config_mac

## Apple Silicon M1 needs a special Makefile
#if [[ ${ARCH} = "m1" ]]; then
#    cp aq2tng_Makefile_mac_m1 ${Q2PRO_DIR}/Makefile
#    echo "Copying m1 Makefile successful"
#fi

## Patch system.c patch file to make Mac paths work
cp mac_dirpath.patch ${Q2PRO_DIR}/src/unix/
cd ${Q2PRO_DIR}/src/unix
patch < mac_dirpath.patch
cd ../../../

## Build the q2pro binaries
cd ${Q2PRO_DIR} || return
export CONFIG_FILE=config_mac;export PKG_CONFIG_PATH="/usr/local/Cellar/openal-soft/1.21.1/lib/pkgconfig/";make -j2 V=1
build_exitcode=$?

## Copy files in preparation for the build step
if [[ ${build_exitcode} -eq 0 ]]; then
    echo "Q2Pro build successful!  Copying relevant files"
    cp ${CURRENT_DIR}/${Q2PRO_DIR}/q2pro ${CURRENT_DIR}/q2probuilds/${ARCH}/q2pro
    cp ${CURRENT_DIR}/${Q2PRO_DIR}/q2proded ${CURRENT_DIR}/q2probuilds/${ARCH}/q2proded
else
    echo "Error occurred during build step: Copying q2pro files"
    echo "Exiting script!"
    exit 1
fi

## Cleanup task
rm -rf ${CURRENT_DIR}/q2pro

## Generate dylib mappings
cd ${CURRENT_DIR}
mkdir -p q2probuilds/${ARCH}/lib
dylibbundler -b -x "q2probuilds/${ARCH}/q2pro" \
        -x "q2probuilds/${ARCH}/q2proded" \
		-d "q2probuilds/${ARCH}/lib" -of -p @executable_path/lib

## make q2pro executable
chmod +x q2probuilds/${ARCH}/q2pro*
echo "Build script complete for Q2PRO ${ARCH}"

## build TNG
TNG_DIR="aq2-tng"
## Cleanup /tmp/q2pro
rm -rf ${TNG_DIR}

## Clone repository, copy config file
git clone https://github.com/raptor007/aq2-tng ${TNG_DIR}

## Apple Silicon M1 needs a special Makefile
if [[ ${ARCH} = "m1" ]]; then
    cp aq2tng_Makefile_mac_m1 ${TNG_DIR}/source/Makefile
    echo "Copying m1 Makefile successful"
fi

## Build the tng binaries
cd ${TNG_DIR}/source || return
git checkout bots
make -j2 V=1
build_exitcode=$?

## Copy files in preparation for the build step
if [[ ${build_exitcode} -eq 0 ]]; then
    echo "TNG Build successful!  Copying relevant files"
    cp ${CURRENT_DIR}/${TNG_DIR}/source/game*.so ${CURRENT_DIR}/q2probuilds/${ARCH}/
else
    echo "Error occurred during build step: Copying tng files"
    echo "Exiting script!"
    exit 1
fi

## Cleanup task
rm -rf ${CURRENT_DIR}/${TNG_DIR}