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
DMG_FILENAME=aqtion-${VERSION}-mac-${ARCH}

## create MacOS if it does not exist
mkdir -p AQ_Install/AQ.app/Contents/MacOS

## Populate AQ_Install directory (note we're specifying the specifically-built pacage types)
mv ../../action AQ_Install/AQ.app/Contents/MacOS/
cp -r q2probuilds/${ARCH}/.lib AQ_Install/AQ.app/Contents/MacOS/
cp q2probuilds/${ARCH}/q2proded_standalone AQ_Install/AQ.app/Contents/MacOS/q2proded
cp q2probuilds/${ARCH}/q2pro_standalone AQ_Install/AQ.app/Contents/MacOS/q2pro
cp q2probuilds/${ARCH}/game*.so AQ_Install/AQ.app/Contents/MacOS/action/

## make q2pro executable
chmod +x AQ_Install/AQ.app/Contents/MacOS/q2pro*

## Create dmg file
hdiutil create -ov ${DMG_FILENAME}.dmg -srcfolder AQ_Install -volname "AQtion"

## Move action folder back
mv AQ_Install/AQ.app/Contents/MacOS/action ../../

## Delete MacOS-folder
rm -r -f AQ_Install/AQ.app/Contents/MacOS

## Optional upload directly to the release (manual)
if [[ -z ${CI} ]]; then
    read -p "Do you want to automatically upload ${DMG_FILENAME}.dmg to an existing Github Release? (Y/N):  " yn
    case $yn in
        [Yy]* ) gh release upload ${VERSION} ${DMG_FILENAME}.dmg;;
        [Nn]* ) echo "Not uploading, script complete!"; exit 0;;
        * ) echo "Please answer Y or N.";;
    esac
fi