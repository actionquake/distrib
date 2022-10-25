#!/bin/bash

ARCH=$(uname -m | sed -e 's/i.86/i386/' -e 's/amd64/x86_64/' -e 's/sun4u/sparc64/' -e 's/arm.*/arm/' -e 's/sa110/arm/' -e 's/alpha/axp/')
CURRENT_DIR=$(pwd)
PKG_CONFIG_PATH="/usr/local/Cellar/openal-soft/1.21.1/lib/pkgconfig/"
PLATFORMS=(steam standalone)

if ! ( [ ${ARCH} = 'x86_64' ] || [ ${ARCH} = "arm" ] )
then
    echo "Architecture not x86_64 or arm, stopping"
    echo "Arch found via uname -m: ${ARCH}"
    exit 1
fi

echo "Building for ${ARCH}"
echo "Current dir is ${CURRENT_DIR}"
echo "Proceeding with build..."

### Build Q2Pro
cd ${CURRENT_DIR}
Q2PRO_DIR="q2pro"

## Cleanup q2pro if exists
rm -rf ${Q2PRO_DIR}

## Set branch
aqtion_branch="aqtion"
## Clone repository, checkout aqtion branch
git clone -b ${aqtion_branch} https://github.com/actionquake/q2pro.git ${Q2PRO_DIR}

## Apple Silicon needs some extra libs in source img dir
if [[ ${ARCH} = "arm" ]]; then
    cp /opt/homebrew/Cellar/jpeg/9e/include/j*.h ./q2pro/src/refresh/
    sed -i -- 's/<jpeglib.h>/"jpeglib.h"/g' q2pro/src/refresh/images.c
fi

## Build the q2pro binaries
cd ${Q2PRO_DIR} || return
cp ../mac_q2pro_config .config
make -j4 V=1
build_exitcode=$?

## Copy files in preparation for the build step
mkdir -p ${CURRENT_DIR}/q2probuilds/${ARCH}
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
cd ${CURRENT_DIR}

## make q2pro executable
chmod +x q2probuilds/${ARCH}/q2pro*

echo "Build script complete for Q2PRO ${ARCH}"

## build TNG
TNG_DIR="aq2-tng"
## Cleanup /tmp/q2pro
rm -rf ${TNG_DIR}

## Set branch
aqtion_branch="aqtion"
## Clone repository, copy config file
git clone -b ${aqtion_branch} https://github.com/actionquake/aq2-tng ${TNG_DIR}

## Apple Silicon needs defined to change CC and MACHINE
if [[ ${ARCH} = "arm" ]]; then
    export TNG_BUILD_FOR=M1
fi

## Build the tng binaries
cd ${TNG_DIR}/source || return
USE_AQTION=TRUE make -j4 V=1
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
