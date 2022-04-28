#!/bin/bash

##
### This file should be run as part of the CI pipeline as it builds a DMG file
##
### If you're trying to compile a Mac version, use the `build_mac.sh` script
##

RAW_ARCH=$1
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


echo "Current dir is ${CURRENT_DIR}"
echo "Architecture: ${ARCH}"
DMG_FILENAME=aqtion-mac-${ARCH}

## create MacOS if it does not exist
mkdir -p AQ_Install/AQ.app/Contents/MacOS

## Move action dir into the app for the zip file and populate AQ_Install directory
mv ../../action AQ_Install/AQ.app/Contents/MacOS/
cp -r q2probuilds/${ARCH}/lib AQ_Install/AQ.app/Contents/MacOS/
install q2probuilds/${ARCH}/q2proded AQ_Install/AQ.app/Contents/MacOS/q2proded
install q2probuilds/${ARCH}/q2pro AQ_Install/AQ.app/Contents/MacOS/q2pro
install q2probuilds/${ARCH}/game*.so AQ_Install/AQ.app/Contents/MacOS/action/

## make q2pro executable
chmod +x AQ_Install/AQ.app/Contents/MacOS/q2pro*

## Create dmg file
hdiutil create -ov ${DMG_FILENAME}.dmg -srcfolder AQ_Install -volname "AQtion"

cd AQ_Install || return
zip -r ../${DMG_FILENAME}.zip AQ.app
cd .. || return

## Move action folder back
mv AQ_Install/AQ.app/Contents/MacOS/action ../../
