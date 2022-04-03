#!/bin/bash

VERSION=$1
ARCH=$2

if [[ ${ARCH} -ne "intel" || ${ARCH} -ne "arm" ]]; then
    echo "ARCH must be one of [intel | arm]"
    exit 1
fi

## Populate AQ_Install directory
mv ../../action AQ_Install/AQ.app/Contents/MacOS/
cp q2probuilds/${ARCH}/q2proded q2probuilds/${ARCH}/q2pro AQ_Install/AQ.app/Contents/MacOS/
cp q2probuilds/${ARCH}/gamex86_64.so AQ_Install/AQ.app/Contents/MacOS/action

## Create dmg file
hdiutil -ov create action_quake-${VERSION}-mac_${ARCH}.dmg -srcfolder AQ_Install -volname "Action Quake"

## Move action folder back
mv AQ_Install/AQ.app/Contents/MacOS/action ../../