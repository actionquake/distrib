#!/usr/bin/env bash

command -v curl >/dev/null 2>&1 || { echo "I require curl but it's not installed.  Aborting." >&2; exit 1; }

arch=$(uname -m)
target_file=/tmp/aqtion-distrib.tar.gz
target_dir=~/aqtion

if [[ $arch == "x86_64" ]]; then
    download_link=$(curl -s https://api.github.com/repos/actionquake/distrib/releases | grep browser_download_url | grep linux-amd64 | head -n 1 | cut -d '"' -f 4)
    curl -L -o $target_file $download_link
    mkdir -p $target_dir
    tar xf $target_file -C $target_dir
fi