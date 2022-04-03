#!/bin/bash

BUILD_MAKE=$1
RAW_ARCH=$2
VERSION=$3
CURRENT_DIR=$(pwd)

if [[ -z $1 ]]; then
    echo "Run script with arguments: [make|build|both] [intel|arm] <version>"
    exit 0
fi

if [[ -z ${BUILD_MAKE} ]]; then
    echo "First argument must be one of [make | build | both]"
    exit 1
fi

ARCH=$(echo ${RAW_ARCH} | tr '[:upper:]' '[:lower:]')
if [[ ${ARCH} -ne "intel" || ${ARCH} -ne "arm" ]]; then
    echo "ARCH must be one of [intel | arm]"
    exit 1
fi

if [[ -z ${VERSION} && ${BUILD_MAKE} -ne "make" ]]; then
    echo "No version detected, example suggested value: v0.0.20"
fi

echo "Current dir is ${CURRENT_DIR}"
echo "Build, Make or Both: ${BUILD_MAKE}"
echo "Architecture: ${ARCH}"
echo "Version: ${VERSION}"

if [[ ${BUILD_MAKE} -eq "make" || ${BUILD_MAKE} -eq "both" ]]; then

if [[ -z ${ARCH} ]]; then
    echo "Must supply ARCH argument, ARCH must be one of [intel | arm]"
    exit 1
fi

Q2PRO_DIR="./q2pro"
    ## Cleanup /tmp/q2pro
    rm -rf ${Q2PRO_DIR}

    ## Clone and enter cloned repository
    git clone https://github.com/skullernet/q2pro.git ${Q2PRO_DIR}
    cp config_mac_intel ${Q2PRO_DIR}
    cd ${Q2PRO_DIR}

    ## Build the binaries
    export CONFIG_FILE=config_mac_${ARCH};make V=1
    build_exitcode=$?

    ## Copy files in preparation for the build step
    if [[ ${build_exitcode} -eq 0 ]]; then
        cp ${Q2PRO_DIR}/q2pro ${Q2PRO_DIR}/q2proded ${Q2PRO_DIR}/gamex86_64.so ${CURRENT_DIR}/q2probuilds/${ARCH}
    else
        echo "Error occurred during build step, exiting script!"
        exit 1
    fi
fi


if [[ ${BUILD_MAKE} -eq "build" || ${BUILD_MAKE} -eq "both" ]]; then
    ## Move back to the Mac build dir
    cd ..
    ## Populate AQ_Install directory
    mv ../../action AQ_Install/AQ.app/Contents/MacOS/
    cp q2probuilds/${ARCH}/q2proded q2probuilds/${ARCH}/q2pro AQ_Install/AQ.app/Contents/MacOS/
    cp q2probuilds/${ARCH}/gamex86_64.so AQ_Install/AQ.app/Contents/MacOS/action

    ## Create dmg file
    hdiutil create -ov action_quake-${VERSION}-mac_${ARCH}.dmg -srcfolder AQ_Install -volname "Action Quake"

    ## Move action folder back
    mv AQ_Install/AQ.app/Contents/MacOS/action ../../
fi

## Cleanup task
rm -rf ${CURRENT_DIR}/q2pro