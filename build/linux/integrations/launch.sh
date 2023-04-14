#!/bin/sh

Q2PRO_BIN=$1

if [ -z $Q2PRO_BIN ]; then
  Q2PRO_BIN=q2pro
fi

LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/
./aqtion $Q2PRO_BIN
