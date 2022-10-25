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

DMG_FILENAME=aqtion-mac-universal-${DISTRIB}

## Create universal binary from prebuilt binaries
lipo -create -output q2probuilds/universal/q2pro q2probuilds/x86_64/q2pro q2probuilds/arm64/q2pro
lipo -create -output q2probuilds/universal/q2proded q2probuilds/x86_64/q2proded q2probuilds/arm64/q2proded

## Tell q2pro where to find the bundled dylibs - need a verified developer account for this to work cleanly for other libs
install_name_tool -change '@rpath/discord_game_sdk.dylib' '@loader_path/discord_game_sdk.dylib' q2probuilds/universal/q2pro
# install_name_tool -change '/usr/local/opt/sdl2/lib/libSDL2-2.0.0.dylib' '@loader_path/libs/libSDL2-2.0.0.dylib' q2probuilds/universal/q2pro
# install_name_tool -change '/usr/lib/libcurl.4.dylib' '@loader_path/libs/libcurl.4.dylib' q2probuilds/universal/q2pro
# install_name_tool -change '/usr/lib/libz.1.dylib' '@loader_path/libs/libz.1.dylib' q2probuilds/universal/q2pro
# install_name_tool -change '/usr/local/opt/libpng/lib/libpng16.16.dylib' '@loader_path/libs/libpng16.16.dylib' q2probuilds/universal/q2pro
# install_name_tool -change '/usr/local/opt/jpeg-turbo/lib/libjpeg.8.dylib' '@loader_path/libs/libjpeg.8.dylib' q2probuilds/universal/q2pro

## Move action dir into the app for the zip file and populate AQ_Install directory
if [[ ${DISTRIB} == "standalone" ]]; then
    mkdir -p AQ_Install/AQ.app/Contents/MacOS
    
    cp -r ../../action AQ_Install/AQ.app/Contents/MacOS/
    install q2probuilds/universal/q2proded AQ_Install/AQ.app/Contents/MacOS/q2proded
    install q2probuilds/universal/q2pro AQ_Install/AQ.app/Contents/MacOS/q2pro
    install q2probuilds/x86_64/gamex86_64.so AQ_Install/AQ.app/Contents/MacOS/action/
    install q2probuilds/arm64/gamearm.so AQ_Install/AQ.app/Contents/MacOS/action/
    install q2probuilds/universal/libs/discord_game_sdk.dylib AQ_Install/AQ.app/Contents/MacOS/discord_game_sdk.dylib
    #cp -R q2probuilds/universal/libs AQ_Install/AQ.app/Contents/MacOS/
    rm -rf AQ_Install/AQ.app/Contents/MacOS/.dummyfile
    ## make q2pro executable
    chmod +x AQ_Install/AQ.app/Contents/MacOS/q2pro*

    ## Create dmg file
    hdiutil create -ov ${DMG_FILENAME}.dmg -srcfolder AQ_Install -volname "AQtion"
else
    mkdir -p Steam_Install
    
    cp -r ../../../aqtion/action Steam_Install/
    lipo -create -output q2probuilds/universal/aqtion q2probuilds/x86_64/aqtion q2probuilds/arm64/aqtion

    # Install AQtion required files
    install q2probuilds/universal/aqtion Steam_Install/aqtion
    install q2probuilds/universal/q2proded Steam_Install/q2proded
    install q2probuilds/universal/q2pro Steam_Install/q2pro
    install q2probuilds/x86_64/gamex86_64.so Steam_Install/action/
    install q2probuilds/arm64/gamearm.so Steam_Install/action/

    # Copy universal libraries
    #cp -R q2probuilds/universal/libs Steam_Install/

    # Install lib files and launch script until Steam fully supports Apple Silicon properly
    install steam/libsteam_api.dylib Steam_Install/libsteam_api.dylib
    install steam/steam_appid.txt Steam_Install/steam_appid.txt
    install q2probuilds/universal/libs/discord_game_sdk.dylib Steam_Install/discord_game_sdk.dylib
    install steam/launch.sh Steam_Install/launch.sh
    
    ## Make items executable
    chmod +x Steam_Install/q2pro* Steam_Install/aqtion Steam_Install/launch.sh

    #cd Steam_Install && zip -r ../${DMG_FILENAME}.zip *

    ##mv action ../../../
fi
