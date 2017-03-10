#!/bin/bash

export AML_SCRIPTS_PATH=/home/autobuild/build-scripts
export BOARD=p212
export BUILD_VARIANT=user
export BUILD_ARCH=64
export COMPILE_JOBS=32
export FIRMWARE_UPLOAD_BASE_PATH=/firmware/image/android/Android-N/trunk
export BUILD_TYPE=ATV
export WORKSPACE=$(pwd)
export GMS_VERSION=gms-7.1
export AML_GMS_PATH=/home/autobuild/local-gms
export AML_BUILD_WORK_BASE_PATH=/mnt/fileroot/autobuild
