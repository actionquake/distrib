#!/bin/bash

## Define directories and check for basic commands

AQTION_DIR=${HOME}/aqtion
DISTRIB_URL="https://api.github.com/repos/actionquake/distrib/releases/latest"
ARCH=$(uname -m)

## Argument script logic

if [ $1 = "clean" ]
then
    rm -rf ${AQTION_DIR}/aqtion/versions
fi

if [ $1 = "update" ]
then
    if [ ! -f "${AQTION_DIR}/versions" ]
    then
        echo "No local install found, downloading the latest version..."
        check_for_install
    else
        INSTALLED_VERSION=$(grep -s installed_version ${AQTION_DIR}/versions | cut -f 2 -d "=")
        check_for_updates ${INSTALLED_VERSION}
    fi
fi

if [ $1 = "uninstall" ]
then
    uninstall
fi

## Check if current context is root, do not install if root
CURRENT_USER=$(whoami)
if [ ${CURRENT_USER} = "root" ]
then
    echo "Error: User running script is root, do not install as root"
    exit 1
fi

## This script uses curl, check
if command -v curl &> /dev/null
then
    :
else
    echo "curl not found, please install curl"
    echo "Run this and retry:"
    echo "sudo apt-get update && sudo apt-get install curl -y"
    exit 1
fi

## AQtion requires SDL2, check
if command -v sdl2-config &> /dev/null
then
    :
else
    echo "sdl2 not found, please install sdl2"
    echo "Run this and retry:"
    echo "sudo apt-get update && sudo apt-get install libsdl2-2.0 -y"
    exit 1
fi

## Functions
check_for_install () {
    INSTALLED_VERSION=$(grep -s installed_version ${AQTION_DIR}/versions | cut -f 2 -d "=")
    LATEST_VERSION=$(curl -s ${DISTRIB_URL} | grep browser_download_url | cut -d '"' -f 4 | grep client | head -n 1 | cut -d "/" -f 8)

    if [ ! -f "${AQTION_DIR}/versions" ]  ## Version not found, assuming this is a fresh install
    then
        download_aqtion
    else
        echo "Existing installation found!"
        echo "If you wish to upgrade to a newer version if one is available, re-run like so:"
        echo "aqtion update"
        exit 0
    fi
}

check_for_updates () {
    if [ "${INSTALLED_VERSION}" = "${LATEST_VERSION}" ]
    then
        echo "Installed version is up-to-date, continuing..."
        launch_game
    else
        if [ -f ${AQTION_DIR}/update_check ]
        then
            echo "Update check disabled, launching game..."
            launch_game;
        else
            echo "Installed version detected: ${INSTALLED_VERSION}"
            echo "Latest version detected:  ${LATEST_VERSION}"
            read -p "There's a new version of AQtion available, do you want to download it?  (Y)es/(N)o/(D)on't Ask Again:  " ynd
            case $ynd in
                [Yy]* ) download_aqtion;;
                [Nn]* ) launch_game;;
                [Dd]* ) touch "${AQTION_DIR}/update_check"; launch_game;;
                * ) echo "Please answer Y, N or D.";;
            esac
        fi
    fi
}

update_version_number () {
    if [ -s "${AQTION_DIR}/versions" ] || [ ! -f "${AQTION_DIR}/versions" ]
    then  # Version file not found
        echo "installed_version=${LATEST_VERSION}" >> ${AQTION_DIR}/versions
    else  # Update version
        awk -F '[= ]+' -v name="installed_version" -v value="${LATEST_VERSION}" '$1==name{$2=value}1' ${AQTION_DIR}/version
    fi

}

download_aqtion () {
    mkdir -p ${AQTION_DIR}

    if [ ${ARCH} = "x86_64" ]
    then
        LINUX_ARCH="amd64"
    elif [ ${ARCH} = "aarch64" ]
    then
        LINUX_ARCH="arm64"
    else
        echo "x86_64 or aarch64 not detected, please post a Github Issue at https://github.com/actionquake/distrib with the following information:"
        echo "uname: $(uname)"
        echo "arch detected: $(uname -m)"
        exit 1
    fi

    ## Tarball name "aqtion-client-VERSION-linux-ARCH.tar.gz"

    #LATEST_PACKAGE=$(curl -q -s ${DISTRIB_URL} | grep browser_download_url | cut -d '"' -f 4 | grep ${LINUX_ARCH} | grep client | grep -v deb | head -n 1)
    LATEST_VERSION=$(curl -q -s ${DISTRIB_URL} | grep browser_download_url | cut -d '"' -f 4 | grep ${LINUX_ARCH} | grep client | grep -v deb | head -n 1 | cut -d "/" -f 8)
    LATEST_PACKAGE="aqtion-client-${LATEST_VERSION}-linux-${LINUX_ARCH}.tar.gz"
    echo "Downloading AQtion ${LATEST_VERSION} ..."
    curl --progress-bar -q -s -L -o /tmp/aqtion_latest.tar.gz "${LATEST_PACKAGE}"
    tar xzf /tmp/aqtion_latest.tar.gz -C "${AQTION_DIR}" --strip-components=1
    if [ $? = 0 ]
    then
        update_version_number ${LATEST_VERSION}
        echo "Installation successful!"
        launch_game
    else
        if [ -z "${LATEST_VERSION}" ] || [ -z "${LATEST_PACKAGE}" ]
        then
            LATEST_VERSION="undefined"
            LATEST_PACKAGE="undefined"
        fi
        echo "Installation failure, take this debug information and post a Github Issue at https://github.com/actionquake/distrib with the following information: "
        echo "Latest version available: ${LATEST_VERSION}"
        echo "Attempted package download: ${LATEST_PACKAGE}"
    fi
}

uninstall () {
    echo "Completely removing AQtion from ${AQTION_DIR} ..."
    rm -rf ${AQTION_DIR}
    if [ $? = "0" ]
    then
        echo "Removal successful"
        exit 0
    else
        echo "Error in removing files, check that they are not in use or that you don't have a shell that is in ${AQTION_DIR} directory"
        echo "To manually uninstall, run 'rm -rf ${AQTION_DIR}' in your shell"
        exit 1
    fi
}

launch_game () {
    cd ${AQTION_DIR} || return
    ${AQTION_DIR}/q2pro
}

# Let's-a go
check_for_install