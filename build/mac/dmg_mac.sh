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

## Change dynamic lib references manually because Apple is dumb and won't let us static link

#install_name_tool -change /usr/lib/libcurl.4.dylib
install_name_tool -change /System/Library/Frameworks/OpenAL.framework/Versions/A/OpenAL @executable_path/.lib/libopenal.1.21.1.dylib q2probuilds/${ARCH}/q2pro
install_name_tool -change /usr/local/opt/libpng/lib/libpng16.16.dylib @executable_path/.lib/libpng16.16.dylib q2probuilds/${ARCH}/q2pro
install_name_tool -change /usr/local/opt/jpeg/lib/libjpeg.9.dylib @executable_path/.lib/libjpeg.9.dylib q2probuilds/${ARCH}/q2pro
install_name_tool -change /usr/lib/libz.1.dylib @executable_path/.lib/libz.1.dylib q2probuilds/${ARCH}/q2pro
install_name_tool -change /usr/local/opt/sdl2/lib/libSDL2-2.0.0.dylib @executable_path/.lib/libSDL2-2.0.0.dylib q2probuilds/${ARCH}/q2pro
#install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/.lib/

## Populate AQ_Install directory
mv ../../action AQ_Install/AQ.app/Contents/MacOS/
cp -r q2probuilds/${ARCH}/.lib AQ_Install/AQ.app/Contents/MacOS/
cp q2probuilds/${ARCH}/q2proded q2probuilds/${ARCH}/q2pro AQ_Install/AQ.app/Contents/MacOS/
cp q2probuilds/${ARCH}/game*.so AQ_Install/AQ.app/Contents/MacOS/action/

## Create dmg file
hdiutil create -ov action_quake-${VERSION}-mac-${ARCH}.dmg -srcfolder AQ_Install -volname "Action Quake"

## Move action folder back
mv AQ_Install/AQ.app/Contents/MacOS/action ../../
