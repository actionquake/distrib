#!/bin/bash

RAW_ARCH=$1
CURRENT_DIR=$(pwd)
PKG_CONFIG_PATH="/usr/local/Cellar/openal-soft/1.21.1/lib/pkgconfig/"
PLATFORMS=(Steam Standalone)

if [[ -z ${RAW_ARCH} ]]
then
    echo "How to use this script:"
    echo "./build_mac.sh [intel | m1]"
    echo "Re-run with the appropriate arguments"
    exit 1
fi

ARCH=$(echo ${RAW_ARCH} | tr '[:upper:]' '[:lower:]')
if [[ ${ARCH} -ne "intel" || ${ARCH} -ne "m1" ]]
then
    echo "First argument must be one of [intel | m1]"
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

    ## Clone repository, copy config file
    git clone https://github.com/skullernet/q2pro.git ${Q2PRO_DIR}
    cp q2pro_config_mac ${Q2PRO_DIR}/config_mac

    ## Patch system.c patch file to make Mac paths work
    patch -u ${Q2PRO_DIR}/src/unix/system.c << EOF
--- system.c	2022-04-25 23:05:48.000000000 -0400
+++ system.c.mac	2022-04-25 23:09:42.000000000 -0400
@@ -282,6 +282,22 @@
     signal(SIGPIPE, SIG_IGN);
     signal(SIGUSR1, hup_handler);
 
+    #ifdef __APPLE__
+	// set AQ.app/Contents/Resources as basedir
+	char path[MAX_OSPATH], *c;
+	unsigned int i = sizeof(path);
+
+	if (_NSGetExecutablePath(path, &i) > -1) {
+		if ((c = strstr(path, "AQ.app"))) {
+			strcpy(c, "AQ.app/Contents/MacOS");
+			Cvar_FullSet("basedir", path, CVAR_NOSET, FROM_CODE);
+
+			strcpy(c, "AQ.app/Contents/MacOS");
+			Cvar_FullSet("libdir", path, CVAR_NOSET, FROM_CODE);
+		}
+	}
+    #endif
+
     // basedir <path>
     // allows the game to run from outside the data tree
     sys_basedir = Cvar_Get("basedir", DATADIR, CVAR_NOSET);
EOF


    ## Patch common.h & q2pro/src/common/common.c to rename q2pro to AQtion
    patch -u ${Q2PRO_DIR}/inc/common/common.h << EOF
--- common.h.orig
+++ common.h
@@ -26,10 +26,10 @@
 // common.h -- definitions common between client and server, but not game.dll
 //
 
-#define PRODUCT         "Q2PRO"
+#define PRODUCT         "AQtion"
 
 #if USE_CLIENT
-#define APPLICATION     "q2pro"
+#define APPLICATION     "AQtion (${PLATFORM})"
 #else
 #define APPLICATION     "q2proded"
 #endif
EOF

    patch -u ${Q2PRO_DIR}/src/common/common.c << EOF
--- common.c.orig
+++ common.c
@@ -1031,7 +1031,7 @@
 
     Com_Printf("====== " PRODUCT " initialized ======\n\n");
     Com_LPrintf(PRINT_NOTICE, APPLICATION " " VERSION ", " __DATE__ "\n");
-    Com_Printf("https://github.com/skullernet/q2pro\n\n");
+    Com_Printf("https://github.com/skullernet/q2proasdfasdfsadf\n\n");
 
     time(&com_startTime);
EOF

    ## Build the q2pro binaries
    cd ${Q2PRO_DIR} || return
    export CONFIG_FILE=config_mac; make -j2 V=1
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
    mkdir -p q2probuilds/${ARCH}/lib

    dylibbundler -b -x "q2probuilds/${ARCH}/${PLATFORM}/q2pro" \
            -x "q2probuilds/${ARCH}/${PLATFORM}/q2proded" \
            -d "q2probuilds/${ARCH}/lib" -of -p @executable_path/${ARCH}lib

    ## make q2pro executable
    chmod +x q2probuilds/${ARCH}/${PLATFORM}/q2pro*
    echo "Build script complete for Q2PRO ${ARCH}"

    ## build TNG
    TNG_DIR="aq2-tng"
    ## Cleanup /tmp/q2pro
    rm -rf ${TNG_DIR}

    ## Clone repository, copy config file
    git clone https://github.com/raptor007/aq2-tng ${TNG_DIR}

    ## Apple Silicon M1 needs a special Makefile
    if [[ ${ARCH} = "m1" ]]; then
        cp aq2tng_Makefile_mac_m1 ${TNG_DIR}/source/Makefile
        export BUILDFOR=M1
        echo "Copying m1 Makefile successful"
    fi

    ## Build the tng binaries
    cd ${TNG_DIR}/source || return
    git checkout bots
    make -j2 V=1
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