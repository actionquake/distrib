#!/bin/bash

## Define directories and check for basic commands

AQTION_DIR=${HOME}/aqtion
DISTRIB_URL="https://api.github.com/repos/actionquake/distrib/releases/latest"
ARCH=$(uname -m)

CURRENT_USER=$(whoami)

if [ ${CURRENT_USER} == "root" ]; then
    echo "Error: User running script is root, do not install as root"
    exit 1
fi

if $(command -v curl &> /dev/null)
then
    LATEST_VERSION=$(curl -s ${DISTRIB_URL} | grep browser_download_url | cut -d '"' -f 4 | grep client | head -n 1 | cut -d "/" -f 8)
else
    echo "${command} not found, please install ${command}"
fi

## Functions
check_for_install () {
    INSTALLED_VERSION=$(grep -s installed_version ${AQTION_DIR}/versions | cut -f 2 -d "=")

    if [ ! -f "${AQTION_DIR}/versions" ]  ## Version not found, assuming this is a fresh install
    then
        download_aqtion
    else
        check_for_updates ${INSTALLED_VERSION}
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

    LATEST_PACKAGE=$(curl -q -s ${DISTRIB_URL} | grep browser_download_url | cut -d '"' -f 4 | grep ${LINUX_ARCH} | grep client | head -n 1)
    LATEST_VERSION=$(curl -q -s ${DISTRIB_URL} | grep browser_download_url | cut -d '"' -f 4 | grep ${LINUX_ARCH} | grep client | head -n 1 | cut -d "/" -f 8)
    curl -q -s -L -o /tmp/aqtion_latest.tar.gz "${LATEST_PACKAGE}"
    tar xzf /tmp/aqtion_latest.tar.gz -C "${AQTION_DIR}" --strip-components=1
    update_version_number ${LATEST_VERSION}
    echo "Installation successful!"
    launch_game
}

launch_game () {
    cd ${AQTION_DIR}
    ${AQTION_DIR}/q2pro "$@"
}

# Let's-a go
check_for_install