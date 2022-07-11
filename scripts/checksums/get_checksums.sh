#!/bin/bash

compare=$1

directoryArray=(default-configs default-game-content default-hdtextures default-mappack0 default-mappack1 default-pics default-sounds)

if [[ -z ${compare} ]]; then
    for directory in "${directoryArray[@]}"; do
        echo "Building checksums for ${directory}"
        find ../../action/$directory -type f -print0 | xargs -0 sha1sum > $directory.chksum
        sed -i 's-*../../action/--' $directory.chksum
    done
fi

if [[ ${compare} = "compare" ]]; then
    for directory in "${directoryArray[@]}"; do
        echo "Building comparison checksums for ${directory}"
        mkdir -p compare
        find ../../action/$directory -type f -print0 | xargs -0 sha1sum > compare/$directory.chksum
        sed -i 's-*../../action/--' compare/$directory.chksum

        echo "Comparing ${directory} checksums..."
        differences=$(diff ${directory}.chksum compare/${directory}.chksum)
        if [[ ${?} = 0 ]]; then
            echo "No differences found, exiting"
            exit 0
        else
            echo "Differences found in above files"
            echo "Recreating zip files"
            exit 1
        fi
    done
fi
