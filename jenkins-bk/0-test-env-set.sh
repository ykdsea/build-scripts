#!/bin/bash

export AML_SCRIPTS_PATH=/mnt/fileroot/autobuild/build-scripts
export BOARD=p212
export BUILD_VARIANT=user
export BUILD_ARCH=64
export COMPILE_JOBS=32
export FIRMWARE_UPLOAD_BASE_PATH=/firmware/image/android/Android-N/trunk
export BUILD_TYPE=AOSP
export WORKSPACE=$(pwd)
