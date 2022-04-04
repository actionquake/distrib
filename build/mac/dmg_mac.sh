#!/bin/bash

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

## Populate AQ_Install directory
mv ../../action AQ_Install/AQ.app/Contents/MacOS/
cp q2probuilds/${ARCH}/q2proded q2probuilds/${ARCH}/q2pro AQ_Install/AQ.app/Contents/MacOS/
cp q2probuilds/${ARCH}/game*.so AQ_Install/AQ.app/Contents/MacOS/action/

## Create dmg file
hdiutil create -ov action_quake-${VERSION}-mac-${ARCH}.dmg -srcfolder AQ_Install -volname "Action Quake"

## Move action folder back
mv AQ_Install/AQ.app/Contents/MacOS/action ../../
