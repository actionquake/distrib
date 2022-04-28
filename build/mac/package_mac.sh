#!/bin/bash

##
### This file should be run as part of the CI pipeline as it builds a DMG file
##
### If you're trying to compile a Mac version, use the `build_mac.sh` script
##

CURRENT_DIR=$(pwd)

echo "Current dir is ${CURRENT_DIR}"
DMG_FILENAME=aqtion-mac-universal

## create MacOS dir if it does not exist
mkdir -p AQ_Install/AQ.app/Contents/MacOS

## Create universal binary from prebuilt binaries
lipo -create -output q2probuilds/universal/q2pro q2probuilds/intel/q2pro q2probuilds/m1/q2pro
lipo -create -output q2probuilds/universal/q2proded q2probuilds/intel/q2proded q2probuilds/m1/q2proded

## Move action dir into the app for the zip file and populate AQ_Install directory
mv ../../action AQ_Install/AQ.app/Contents/MacOS/
cp -r q2probuilds/intel/lib AQ_Install/AQ.app/Contents/MacOS/intellib
cp -r q2probuilds/m1/lib AQ_Install/AQ.app/Contents/MacOS/armlib
install q2probuilds/universal/q2proded AQ_Install/AQ.app/Contents/MacOS/q2proded
install q2probuilds/universal/q2pro AQ_Install/AQ.app/Contents/MacOS/q2pro
install q2probuilds/intel/gamex86_64.so AQ_Install/AQ.app/Contents/MacOS/action/
install q2probuilds/intel/gamearm.so AQ_Install/AQ.app/Contents/MacOS/action/

## make q2pro executable
chmod +x AQ_Install/AQ.app/Contents/MacOS/q2pro*

## Create dmg file
hdiutil create -ov ${DMG_FILENAME}.dmg -srcfolder AQ_Install -volname "AQtion"

cd AQ_Install || return
zip -r ../${DMG_FILENAME}.zip AQ.app
cd .. || return

## Move action folder back
mv AQ_Install/AQ.app/Contents/MacOS/action ../../
