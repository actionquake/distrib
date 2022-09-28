#!/bin/bash

compare=$1

directoryArray=(default-configs default-game-content default-hdtextures default-mappack0 default-mappack1 default-pics default-sounds)

function buildChecksumFiles() {
    for directory in "${directoryArray[@]}"; do
        echo "Building checksums for ${directory}"
        find ../../action/$directory -type f -print0 | xargs -0 sha1sum > $directory.chksum
        sed -i 's-*../../action/--' $directory.chksum
    done
}

function checkExistingFiles() {
    diff_found=0
    for directory in "${directoryArray[@]}"; do
        echo "Building comparison checksums for ${directory}"
        mkdir -p compare
        find ../../action/$directory -type f -print0 | xargs -0 sha1sum > compare/$directory.chksum
        sed -i 's-*../../action/--' compare/$directory.chksum
        if [[ ${?} = 0 ]]; then
            echo "# No differences found in ${directory} #"
            diff_found=1
        fi
    done

    if [[ ${diff_found} = 1 ]]; then
        return 1
    fi
}

echo "Comparing ${directory} checksums..."
#differences=$(diff ${directory}.chksum compare/${directory}.chksum)

checkExistingFiles
if [[ ${?} = 0 ]]; then
    exit 0
else
    echo "! Differences found in ${directory} !"
    buildChecksumFiles
fi
