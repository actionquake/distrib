#!/bin/sh

INSTALL="~/Applications/AQ.app/Contents/MacOS/action/game-content.pkz"
if test -f ${INSTALL}; then
    mkdir -p ~/.actionquake
    mv ~/Applications/AQ.app/Contents/MacOS/action ~/.actionquake 
else
    echo "Script did not detect installation at ~/Applications, please open a Github Issue."
    exit 1
fi
