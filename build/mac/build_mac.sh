#!/bin/bash

ARCH=$(uname -m | sed -e 's/i.86/i386/' -e 's/amd64/x86_64/' -e 's/sun4u/sparc64/' -e 's/arm.*/arm/' -e 's/sa110/arm/' -e 's/alpha/axp/')
CURRENT_DIR=$(pwd)
PKG_CONFIG_PATH="/usr/local/Cellar/openal-soft/1.21.1/lib/pkgconfig/"
PLATFORMS=(steam standalone)

if ! ( [ ${ARCH} = 'x86_64' ] || [ ${ARCH} = "arm" ] )
then
    echo "Architecture not x86_64 or arm, stopping"
    echo "Arch found via uname -m: ${ARCH}"
    exit 1
fi

echo "Building for ${ARCH}"
echo "Current dir is ${CURRENT_DIR}"
echo "Proceeding with build..."

### Q2Pro
for PLATFORM in "${PLATFORMS[@]}"
do
    cd ${CURRENT_DIR}
    Q2PRO_DIR="q2pro"

    ## Cleanup /tmp/q2pro if exists
    rm -rf ${Q2PRO_DIR}

    ## Set branch
    aqtion_branch="aqtion"
    ## Clone repository, checkout aqtion branch, copy config file
    git clone -b ${aqtion_branch} https://github.com/actionquake/q2pro.git ${Q2PRO_DIR}

    ## Build the q2pro binaries
    cd ${Q2PRO_DIR} || return

    ## Uncomment if in the future somehow Discord fixes their lib naming scheme?
    #mkdir -p extern/discord
    #wget https://dl-game-sdk.discordapp.net/2.5.6/discord_game_sdk.zip && unzip discord_game_sdk.zip -d extern/discord/

    if [ ${PLATFORM} = "steam" ]; then
        cp ../q2pro_config_steam .
        export CONFIG_FILE=q2pro_config_steam; make -j4 V=1
    else
        cp ../q2pro_config_standalone .
        export CONFIG_FILE=q2pro_config_standalone; make -j4 V=1
    fi
    build_exitcode=$?

    ## Copy files in preparation for the build step
    mkdir -p ${CURRENT_DIR}/q2probuilds/${ARCH}/${PLATFORM}
    if [[ ${build_exitcode} -eq 0 ]]; then
        echo "Q2Pro build successful!  Copying relevant files"
        cp ${CURRENT_DIR}/${Q2PRO_DIR}/q2pro ${CURRENT_DIR}/q2probuilds/${ARCH}/${PLATFORM}/q2pro
        cp ${CURRENT_DIR}/${Q2PRO_DIR}/q2proded ${CURRENT_DIR}/q2probuilds/${ARCH}/${PLATFORM}/q2proded
    else
        echo "Error occurred during build step: Copying q2pro files"
        echo "Exiting script!"
        exit 1
    fi

    ## Cleanup task
    rm -rf ${CURRENT_DIR}/q2pro

    ## Generate dylib mappings
    cd ${CURRENT_DIR}
    #mkdir -p q2probuilds/${ARCH}/lib
    #dylibbundler -b -x "q2probuilds/${ARCH}/${PLATFORM}/q2pro" \
    #        -x "q2probuilds/${ARCH}/${PLATFORM}/q2proded" \
    #        -d "q2probuilds/${ARCH}/lib" -of -p @executable_path/${ARCH}lib

    ## make q2pro executable
    chmod +x q2probuilds/${ARCH}/${PLATFORM}/q2pro*

    ## Tell q2pro where to find the Discord SDK dylib
    install_name_tool -change '@rpath/discord_game_sdk.dylib' '@loader_path/discord_game_sdk.dylib' q2probuilds/${ARCH}/${PLATFORM}/q2pro
    
    echo "Build script complete for Q2PRO ${ARCH}"

    ## build TNG
    TNG_DIR="aq2-tng"
    ## Cleanup /tmp/q2pro
    rm -rf ${TNG_DIR}

    ## Set branch
    aqtion_branch="aqtion"
    ## Clone repository, copy config file
    git clone -b ${aqtion_branch} https://github.com/actionquake/aq2-tng ${TNG_DIR}

    ## Apple Silicon needs defined to change CC and MACHINE
    if [[ ${ARCH} = "arm" ]]; then
        #cp aq2tng_Makefile_mac_m1 ${TNG_DIR}/source/Makefile
        export TNG_BUILD_FOR=M1
        #echo "Copying m1 Makefile successful"
    fi

    ## Build the tng binaries
    cd ${TNG_DIR}/source || return
    USE_AQTION=1 make -j4 V=1
    build_exitcode=$?

    ## Copy files in preparation for the build step
    if [[ ${build_exitcode} -eq 0 ]]; then
        echo "TNG Build successful!  Copying relevant files"
        cp ${CURRENT_DIR}/${TNG_DIR}/source/game*.so ${CURRENT_DIR}/q2probuilds/${ARCH}/${PLATFORM}/
    else
        echo "Error occurred during build step: Copying tng files"
        echo "Exiting script!"
        exit 1
    fi

    ## Cleanup task
    rm -rf ${CURRENT_DIR}/${TNG_DIR}
done
