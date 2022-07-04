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
PLATFORMS=(steam standalone)


if [[ -z ${DISTRIB} ]]
then
    echo "How to use this script:"
    echo "./package_mac.sh [steam | standalone]"
    echo "Re-run with the appropriate arguments"
    exit 1
fi

echo "Current dir is ${CURRENT_DIR}"

for PLATFORM in "${PLATFORMS[@]}"
do
    DMG_FILENAME=aqtion-mac-universal-${PLATFORM}

    ## create MacOS dir if it does not exist
    mkdir -p AQ_Install/AQ.app/Contents/MacOS
    mkdir -p Steam_Install

    ## Create universal binary from prebuilt binaries
    lipo -create -output q2probuilds/universal/${PLATFORM}/q2pro q2probuilds/intel/${PLATFORM}/q2pro q2probuilds/m1/${PLATFORM}/q2pro
    lipo -create -output q2probuilds/universal/${PLATFORM}/q2proded q2probuilds/intel/${PLATFORM}/q2proded q2probuilds/m1/${PLATFORM}/q2proded

    ## Move action dir into the app for the zip file and populate AQ_Install directory
    if [[ ${PLATFORM} == "standalone" ]]; then
        mv ../../action AQ_Install/AQ.app/Contents/MacOS/
        install q2probuilds/universal/${PLATFORM}/q2proded AQ_Install/AQ.app/Contents/MacOS/q2proded
        install q2probuilds/universal/${PLATFORM}/q2pro AQ_Install/AQ.app/Contents/MacOS/q2pro
        install q2probuilds/intel/${PLATFORM}/gamex86_64.so AQ_Install/AQ.app/Contents/MacOS/action/
        install q2probuilds/m1/${PLATFORM}/gamearm.so AQ_Install/AQ.app/Contents/MacOS/action/
        rm -rf AQ_Install/AQ.app/Contents/MacOS/.dummyfile
        ## make q2pro executable
        chmod +x AQ_Install/AQ.app/Contents/MacOS/q2pro*

        ## Create dmg file
        hdiutil create -ov ${DMG_FILENAME}.dmg -srcfolder AQ_Install -volname "AQtion"

        cd AQ_Install || return
        zip -r ../${DMG_FILENAME}.zip AQ.app
        cd .. || return

        ## Move action folder back
        mv AQ_Install/AQ.app/Contents/MacOS/action ../../
    else
        mv ../../action Steam_Install/
        lipo -create -output q2probuilds/universal/${PLATFORM}/aqtion q2probuilds/intel/${PLATFORM}/aqtion q2probuilds/m1/${PLATFORM}/aqtion
        install q2probuilds/universal/${PLATFORM}/aqtion Steam_Install/aqtion
        install q2probuilds/universal/${PLATFORM}/q2proded Steam_Install/q2proded
        install q2probuilds/universal/${PLATFORM}/q2pro Steam_Install/q2pro
        install q2probuilds/intel/${PLATFORM}/gamex86_64.so Steam_Install/action/
        install q2probuilds/m1/${PLATFORM}/gamearm.so Steam_Install/action/
        ## make q2pro executable
        chmod +x Steam_Install/q2pro* Steam_Install/aqtion

        zip -r ${DMG_FILENAME}.zip Steam_Install
    fi
done