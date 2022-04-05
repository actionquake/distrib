#!/bin/bash

RAW_ARCH=$1
CURRENT_DIR=$(pwd)

if [[ -z $1 ]]; then
    echo "Run script with arguments: [intel | m1]"
    exit 0
fi

ARCH=$(echo ${RAW_ARCH} | tr '[:upper:]' '[:lower:]')
if [[ ${ARCH} -ne "intel" || ${ARCH} -ne "m1" ]]; then
    echo "First argument must be one of [intel | m1]"
    exit 1
fi

echo "Building for ${ARCH}"
echo "Current dir is ${CURRENT_DIR}"

Q2PRO_DIR="q2pro"
## Cleanup /tmp/q2pro
rm -rf ${Q2PRO_DIR}

## Clone and enter cloned repository
git clone https://github.com/skullernet/q2pro.git ${Q2PRO_DIR}
cp config_mac_${ARCH} ${Q2PRO_DIR}/config_mac_${ARCH}
if [[ ${ARCH} = "m1" ]]; then
    cp aq2tng_Makefile_mac_m1 ${Q2PRO_DIR}/Makefile
fi

# if [[ ${ARCH} = "intel" ]]; then
#     cp q2pro_Makefile_intel ${Q2PRO_DIR}/Makefile
# fi

cd ${Q2PRO_DIR}

## Build the binaries
export CONFIG_FILE=config_mac_${ARCH};make V=1
build_exitcode=$?

## Copy files in preparation for the build step
if [[ ${build_exitcode} -eq 0 ]]; then
    cp ${CURRENT_DIR}/${Q2PRO_DIR}/q2pro ${CURRENT_DIR}/${Q2PRO_DIR}/q2proded ${CURRENT_DIR}/${Q2PRO_DIR}/game*.so ${CURRENT_DIR}/q2probuilds/${ARCH}
else
    echo "Error occurred during build step, exiting script!"
    exit 1
fi


## Cleanup task
rm -rf ${CURRENT_DIR}/q2pro