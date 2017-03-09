#!/bin/bash
#########################################################################
#																		#
#								make uboot								#
#																		#
#########################################################################
#check params num
if [ $# < 3 ]
then
	echo "Params num error."
	echo "build_uboot need at least 3 input params:"
	echo "param 1: android source path."
	echo "param 2: android build combo."
	echo "param 3: android build type (AOSP, ATV, DRM)."
	echo "param 4: android build job num. if not set, defualt set to 8."
	echo "param 5: android manifest save path. if not set, default use (param 3) as name."
	exit 1
fi


##########################################################################
#global vars.
##########################################################################
ANDROID_SOURCE_PATH=$1
ANDROID_BUILD_COMBO=$2
ANDROID_BUILD_TYPE=$3
ANDROID_BUILD_JOBNUM=$4
ANDROID_MANIFEST_SAVED_PATH=$5
ANDROID_BUILD_RET=0

if [ $# < 5 ]
then
	ANDROID_MANIFEST_SAVED_PATH=$ANDROID_BUILD_COMBO.xml
	echo "Set default save manifest file:"$ANDROID_MANIFEST_SAVED_PATH
fi
if [ $# < 4 ]
then
	ANDROID_BUILD_JOBNUM=8
	echo "Set default build jobnum:"$ANDROID_BUILD_JOBNUM
fi


setBuildType(){
	if [ "$1" == "AOSP" ]
	then
		echo "AOSP: nothing to set."
	elif if [ "$1" == "DRM" ]
		export BOARD_COMPILE_CTS=true
	elif if [ "$1" == "ATV" ]
		export BOARD_COMPILE_ATV=true
		export BOARD_COMPILE_CTS=true
	else
		echo "ERROR BUILD_TYPE:"$1
		return 1
	fi
	
	return 0
}


##########################################################################
#make android
##########################################################################

#setup jdk 1.8
source /opt/choose_java_version.sh < "$AML_SCRIPTS_PATH/android/jdk18"
#set up build enviroment.
setBuildType $ANDROID_BUILD_TYPE
if [ $? -eq 0 ]
then
	exit 1
fi

# build
echo "start build android."

LAST_WD='$(pwd)'
cd "$ANDROID_SOURCE_PATH"

repo manifest -r -o $ANDROID_MANIFEST_SAVED_PATH

source build/envsetup.sh
lunch $ANDROID_BUILD_COMBO
make clean
make otapackage -j$ANDROID_BUILD_JOBNUM

if [ $? -eq 0 ]
then
	ANDROID_BUILD_RET=1
fi

cd $LAST_WD

exit $ANDROID_BUILD_RET

