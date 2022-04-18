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
echo "Adjusting dynamic lib paths for ${ARCH}..."
if [[ ${ARCH} = "m1" ]]; then
    install_name_tool -change /System/Library/Frameworks/OpenAL.framework/Versions/A/OpenAL @executable_path/.lib/libopenal.1.21.1.dylib q2probuilds/${ARCH}/q2pro
    install_name_tool -change /opt/homebrew/opt/libpng/lib/libpng16.16.dylib @executable_path/.lib/libpng16.16.dylib q2probuilds/${ARCH}/q2pro
    install_name_tool -change /opt/homebrew/opt/jpeg/lib/libjpeg.9.dylib @executable_path/.lib/libjpeg.9.dylib q2probuilds/${ARCH}/q2pro
    install_name_tool -change /usr/lib/libz.1.dylib @executable_path/.lib/libz.1.2.8.dylib q2probuilds/${ARCH}/q2pro
else
    install_name_tool -change /usr/local/opt/openal-soft/lib/libopenal.1.dylib @executable_path/.lib/libopenal.1.21.1.dylib q2probuilds/${ARCH}/q2pro
    install_name_tool -change /usr/local/opt/libpng/lib/libpng16.16.dylib @executable_path/.lib/libpng16.16.dylib q2probuilds/${ARCH}/q2pro
    install_name_tool -change /usr/local/opt/jpeg/lib/libjpeg.9.dylib @executable_path/.lib/libjpeg.9.dylib q2probuilds/${ARCH}/q2pro
    install_name_tool -change /usr/lib/libz.1.dylib @executable_path/.lib/libz.1.2.11.dylib q2probuilds/${ARCH}/q2pro
fi

## create MacOS if it does not exist
mkdir -p AQ_Install/AQ.app/Contents/MacOS

## Populate AQ_Install directory
mv ../../action AQ_Install/AQ.app/Contents/MacOS/
cp -r q2probuilds/${ARCH}/.lib AQ_Install/AQ.app/Contents/MacOS/
cp q2probuilds/${ARCH}/q2proded q2probuilds/${ARCH}/q2pro AQ_Install/AQ.app/Contents/MacOS/
cp q2probuilds/${ARCH}/game*.so AQ_Install/AQ.app/Contents/MacOS/action/

## make q2pro executable
chmod +x AQ_Install/AQ.app/Contents/MacOS/q2pro*

## Create dmg file
hdiutil create -ov aqtion-client-${VERSION}-mac-${ARCH}.dmg -srcfolder AQ_Install -volname "AQtion"

## Move action folder back
mv AQ_Install/AQ.app/Contents/MacOS/action ../../

## Delete MacOS-folder
rm -r -f AQ_Install/AQ.app/Contents/MacOS

## Optional upload directly to the release
read -p "Do you want to automatically upload aqtion-client-${VERSION}-mac-${ARCH}.dmg to an existing Github Release? (Y/N):  " yn
case $yn in
    [Yy]* ) gh release upload ${VERSION} aqtion-client-${VERSION}-mac-${ARCH}.dmg;;
    [Nn]* ) exit 0;;
    * ) echo "Please answer Y or N.";;
esac