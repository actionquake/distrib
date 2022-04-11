#!/bin/sh

CURRENT_USER=$(whoami)

if [ ${CURRENT_USER} == "root" ]; then
    echo "Warning: installing as root user, if you do not want to do this, cancel this script with Ctrl-C and change your user"
    sleep 1
    echo "5..."
    sleep 1
    echo "4..."
    sleep 1
    echo "3..."
    sleep 1
    echo "2..."
    sleep 1
    echo "1..."
fi

echo "Installing to ${HOME}/aqtion ..."
mkdir -p ${HOME}/aqtion
mv q2pro q2proded action ${HOME}/aqtion
echo "Install complete, open q2pro at ${HOME}/aqtion to begin"

rm -rf install.sh