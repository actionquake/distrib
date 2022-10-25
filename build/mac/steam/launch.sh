#!/bin/bash

ARCH=$(uname -v)
if [[ "$ARCH" == *"ARM64"* ]]; then
    arch -arm64 ./aqtion
else 
    ./aqtion
fi
