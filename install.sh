#!/usr/bin/env bash

command -v curl >/dev/null 2>&1 || { echo "I require curl but it's not installed.  Aborting." >&2; exit 1; }

arch=$(uname -m)
target_file=/tmp/aqtion-distrib.tar.gz
target_dir=~/aqtion

if [[ $arch == "x86_64" ]]; then
    download_link=$(curl -s https://api.github.com/repos/actionquake/distrib/releases | grep browser_download_url | grep linux-amd64 | head -n 1 | cut -d '"' -f 4)
    curl -L -o $target_file $download_link
    mkdir -p $target_dir
    tar xf $target_file -C $target_dir --strip-components=1
    
    echo "Creating symlinks to /usr/local/games, exit this script with CTRL-C if you do not have sudo access or do not want symlinks created..."
    echo "Attempting this command: sudo ln -s $target_dir/q2pro /usr/local/bin/q2pro"
    sudo ln -s $target_dir/q2pro /usr/local/bin/q2pro
    echo "Attempting this command: sudo ln -s $target_dir/q2proded /usr/local/bin/q2proded"
    sudo ln -s $target_dir/q2proded /usr/local/bin/q2proded

else
    echo "This installer only supports 64-bit Linux, if you feel this is in error, please create a Github issue"
    echo "at this address: https://github.com/actionquake/distrib/issues"
    echo "Paste the following information in the Github Issue you create:"
    echo "Arch detected: " ${arch}
    echo "uname output: " $(uname -a)
    echo "Download link provided: " $download_link
    exit 1
fi
exit 0