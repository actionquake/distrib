#!/bin/bash

ARCH=$(uname -m)
if [[ "$ARCH" == *"ARM64"* ]]; then
    arch -arm64 ./aqtion
else 
    ./aqtion
fi
