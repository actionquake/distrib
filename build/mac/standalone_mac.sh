#!/bin/bash

##
### This file should be run as part of the CI pipeline as it builds a DMG file
##
### If you're trying to compile a Mac version, use the `build_mac.sh` script
##


#####################################################################
#
#  This script is deprecated, do not use
# 
#####################################################################


RAW_ARCH=$1
CURRENT_DIR=$(pwd)
PLATFORMS=(Steam itch Standalone)

if [[ -z $1 ]]; then
    echo "Run script with arguments: [intel|m1] <version>"
    exit 0
fi

ARCH=$(echo ${RAW_ARCH} | tr '[:upper:]' '[:lower:]')
if [[ ${ARCH} -ne "intel" || ${ARCH} -ne "m1" ]]; then
    echo "ARCH must be one of [intel | m1]"
    exit 1
fi

if [ ${ARCH} = "intel" ]; then
    GAMEFILE=gamex86_64.so
else
    GAMEFILE=gamearm.so
fi

for PLATFORM in "${PLATFORMS[@]}"
do
    echo "Current dir is ${CURRENT_DIR}"
    echo "Architecture: ${ARCH}"
    echo "Platform: ${PLATFORM}"
    DMG_FILENAME=aqtion-mac-${ARCH}-${PLATFORM}

    ## create MacOS if it does not exist
    mkdir -p AQ_Install/AQ.app/Contents/MacOS

    ## Move action dir into the app for the zip file and populate AQ_Install directory
    mv ../../action AQ_Install/AQ.app/Contents/MacOS/
    cp -r q2probuilds/${ARCH}/lib AQ_Install/AQ.app/Contents/MacOS/
    install q2probuilds/${ARCH}/${PLATFORM}/q2proded AQ_Install/AQ.app/Contents/MacOS/q2proded
    install q2probuilds/${ARCH}/${PLATFORM}/q2pro AQ_Install/AQ.app/Contents/MacOS/q2pro
    install q2probuilds/${ARCH}/${PLATFORM}/${GAMEFILE} AQ_Install/AQ.app/Contents/MacOS/action/

    ## make q2pro executable
    chmod +x AQ_Install/AQ.app/Contents/MacOS/q2pro*

    ## Create dmg file
    hdiutil create -ov ${DMG_FILENAME}.dmg -srcfolder AQ_Install -volname "AQtion"

    ## Move action folder back
    mv AQ_Install/AQ.app/Contents/MacOS/action ../../

    ## Delete MacOS-folder
    rm -r -f AQ_Install/AQ.app/Contents/MacOS

    ## Optional upload directly to the release (manual)
    # if [[ -z ${CI} ]]; then
    #     read -p "Do you want to automatically upload ${DMG_FILENAME}.dmg to an existing Github Release? (Y/N):  " yn
    #     case $yn in
    #         [Yy]* ) gh release upload ${DMG_FILENAME}.dmg;;
    #         [Nn]* ) echo "Not uploading, script complete!"; exit 0;;
    #         * ) echo "Please answer Y or N.";;
    #     esac
    # fi
done