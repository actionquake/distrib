#!/bin/bash

RAW_ARCH=$1
VERSION=$2
PACKAGE_TYPE="steam"
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
echo "Package Type: steam"
DMG_FILENAME=aqtion-mac-${VERSION}-${ARCH}-${PACKAGE_TYPE}

## create MacOS if it does not exist
mkdir -p AQ_Install/AQ.app/Contents/MacOS

## Populate AQ_Install directory (note we're specifying the specifically-built pacage types)
mv ../../action AQ_Install/AQ.app/Contents/MacOS/
cp -r q2probuilds/${ARCH}/.lib AQ_Install/AQ.app/Contents/MacOS/
cp q2probuilds/${ARCH}/q2proded_${PACKAGE_TYPE} AQ_Install/AQ.app/Contents/MacOS/q2proded
cp q2probuilds/${ARCH}/q2pro_${PACKAGE_TYPE} AQ_Install/AQ.app/Contents/MacOS/q2pro
cp q2probuilds/${ARCH}/game*.so AQ_Install/AQ.app/Contents/MacOS/action/

## make q2pro executable
chmod +x AQ_Install/AQ.app/Contents/MacOS/q2pro*

## Create zip file
cd AQ_Install || return
zip -r ../../../${DMG_FILENAME}.zip AQ.app
cd .. || return

## Move action folder back
mv AQ_Install/AQ.app/Contents/MacOS/action ../../
