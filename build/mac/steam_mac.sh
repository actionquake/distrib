#!/bin/bash

##
### This file should be run as part of the CI pipeline as it builds a DMG file
##
### If you're trying to compile a Mac version, use the `build_mac.sh` script
##

RAW_ARCH=$1
VERSION=$2
CURRENT_DIR=$(pwd)

if [[ -z $1 ]]; then
    echo "Run script with arguments: [intel|arm] <version>"
    exit 0
fi

ARCH=$(echo ${RAW_ARCH} | tr '[:upper:]' '[:lower:]')
if [[ ${ARCH} -ne "intel" || ${ARCH} -ne "arm" ]]; then
    echo "ARCH must be one of [intel | arm]"
    exit 1
fi

if [[ -z ${VERSION} ]]; then
    echo "No version detected, example suggested value format: v0.0.20"
    exit 1
fi

echo "Current dir is ${CURRENT_DIR}"
echo "Architecture: ${ARCH}"
echo "Version: ${VERSION}"
DMG_FILENAME=aqtion-mac-${VERSION}-${ARCH}

## Move action dir into the app for the zip file and populate AQ_Install directory
mv ../../action AQ_Install/AQ.app/Contents/MacOS/
cp -r q2probuilds/${ARCH}/lib AQ_Install/AQ.app/Contents/MacOS/
install q2probuilds/${ARCH}/q2proded AQ_Install/AQ.app/Contents/MacOS/q2proded
install q2probuilds/${ARCH}/q2pro AQ_Install/AQ.app/Contents/MacOS/q2pro
install q2probuilds/${ARCH}/gamex86_64.so AQ_Install/AQ.app/Contents/MacOS/action/

## Create zip file
cd AQ_Install || return
zip -r ../${DMG_FILENAME}.zip AQ.app
cd .. || return

## Move action folder back
mv AQ_Install/AQ.app/Contents/MacOS/action ../../
