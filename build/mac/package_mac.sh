#!/bin/bash

##
### This file should be run as part of the CI pipeline as it builds DMG and ZIP files
##
### If you're trying to compile a Mac version, use the `build_mac.sh` script
##
### Do not run this locally, you need to package the 0_default-configs.pkz in action/ first
##

DISTRIB=$1
CURRENT_DIR=$(pwd)

if [[ -z ${DISTRIB} ]]
then
    echo "How to use this script:"
    echo "./package_mac.sh [steam | standalone]"
    echo "Re-run with the appropriate arguments"
    exit 1
fi

echo "Current dir is ${CURRENT_DIR}"

## create MacOS dir if it does not exist

## Move action dir into the app for the zip file and populate AQ_Install directory
if [[ ${DISTRIB} == "standalone" ]]; then
    mkdir -p AQ_Install/AQ.app/Contents/MacOS
    DMG_FILENAME=aqtion-mac-universal-${DISTRIB}
    ## Create universal binary from prebuilt binaries
    lipo -create -output q2probuilds/universal/${DISTRIB}/q2pro q2probuilds/x86_64/${DISTRIB}/q2pro q2probuilds/arm64/${DISTRIB}/q2pro
    lipo -create -output q2probuilds/universal/${DISTRIB}/q2proded q2probuilds/x86_64/${DISTRIB}/q2proded q2probuilds/arm64/${DISTRIB}/q2proded
    
    #mv ../../action AQ_Install/AQ.app/Contents/MacOS/
    cp -r ../../aqtion/action AQ_Install/AQ.app/Contents/MacOS/
    install q2probuilds/universal/${DISTRIB}/q2proded AQ_Install/AQ.app/Contents/MacOS/q2proded
    install q2probuilds/universal/${DISTRIB}/q2pro AQ_Install/AQ.app/Contents/MacOS/q2pro
    install q2probuilds/x86_64/${DISTRIB}/gamex86_64.so AQ_Install/AQ.app/Contents/MacOS/action/
    install q2probuilds/arm64/${DISTRIB}/gamearm.so AQ_Install/AQ.app/Contents/MacOS/action/
    install q2probuilds/universal/${DISTRIB}/discord_game_sdk.dylib AQ_Install/AQ.app/Contents/MacOS/discord_game_sdk.dylib
    cp -R q2probuilds/universal/libs AQ_Install/AQ.app/Contents/MacOS/
    rm -rf AQ_Install/AQ.app/Contents/MacOS/.dummyfile
    ## make q2pro executable
    chmod +x AQ_Install/AQ.app/Contents/MacOS/q2pro*

    ## Create dmg file
    hdiutil create -ov ${DMG_FILENAME}.dmg -srcfolder AQ_Install -volname "AQtion"

    # cd AQ_Install || return
    # zip -r ../${DMG_FILENAME}.zip AQ.app
    # cd .. || return

    ## Move action folder back
    ##mv AQ_Install/AQ.app/Contents/MacOS/action ../../
else
    mkdir -p Steam_Install
    DMG_FILENAME=aqtion-mac-universal-${DISTRIB}
    ## Create universal binary from prebuilt binaries
    lipo -create -output q2probuilds/universal/${DISTRIB}/q2pro q2probuilds/x86_64/${DISTRIB}/q2pro q2probuilds/arm64/${DISTRIB}/q2pro
    lipo -create -output q2probuilds/universal/${DISTRIB}/q2proded q2probuilds/x86_64/${DISTRIB}/q2proded q2probuilds/arm64/${DISTRIB}/q2proded
    
    #mv ../../action Steam_Install/
    cp -r ../../../aqtion/action Steam_Install/
    lipo -create -output q2probuilds/universal/${DISTRIB}/aqtion q2probuilds/x86_64/${DISTRIB}/aqtion q2probuilds/arm64/${DISTRIB}/aqtion

    # Install AQtion required files
    install q2probuilds/universal/${DISTRIB}/aqtion Steam_Install/aqtion
    install q2probuilds/universal/${DISTRIB}/q2proded Steam_Install/q2proded
    install q2probuilds/universal/${DISTRIB}/q2pro Steam_Install/q2pro
    install q2probuilds/x86_64/${DISTRIB}/gamex86_64.so Steam_Install/action/
    install q2probuilds/arm64/${DISTRIB}/gamearm.so Steam_Install/action/

    # Install Steamshim and Discord lib files
    install q2probuilds/universal/${DISTRIB}/libsteam_api.dylib Steam_Install/libsteam_api.dylib
    install q2probuilds/universal/${DISTRIB}/steam_appid.txt Steam_Install/steam_appid.txt
    install q2probuilds/universal/${DISTRIB}/discord_game_sdk.dylib Steam_Install/discord_game_sdk.dylib

    # Copy universal libraries
    cp -R q2probuilds/universal/libs Steam_Install/

    # Install launch script until Steam fully supports Apple Silicon properly
    install q2probuilds/universal/${DISTRIB}/launch.sh Steam_Install/launch.sh
    
    ## Make items executable
    chmod +x Steam_Install/q2pro* Steam_Install/aqtion Steam_Install/launch.sh

    #cd Steam_Install && zip -r ../${DMG_FILENAME}.zip *

    ##mv action ../../../
fi
