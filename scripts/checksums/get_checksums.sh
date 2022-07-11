#!/bin/bash

directoryArray=(default-configs default-game-content default-hdtextures default-mappack0 default-mappack1 default-pics default-sounds)

for directory in ${directoryArray[@]}; do
    find ../../action/$directory -type f -print0 | xargs -0 sha1sum > $directory.chksum
    sed -i 's-*../../action/--' $directory.chksum
done
