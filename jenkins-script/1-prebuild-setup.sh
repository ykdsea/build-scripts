#!/bin/bash
#########################################################################
#																		#
#						source code setup       						#
#																		#
#########################################################################

UBOOT_SOURCE_PATH="$WORKSPACE/source/uboot"
GMS_INSTALL_PATH="$WORKSPACE/source/vendor/google"


##########################################################################
#functions.
##########################################################################
BUILD_PRE_UPDATE_SECUREOS=FALSE
BUILD_PRE_INSTALL_GMS=FALSE

#check build type.
if [ "$BUILD_TYPE" = "DRM" ]
then
	BUILD_PRE_UPDATE_SECUREOS=TRUE
elif [ "$BUILD_TYPE" = "ATV" ]
then
	BUILD_PRE_UPDATE_SECUREOS=TRUE
	BUILD_PRE_INSTALL_GMS=TRUE
else
	echo "nothing to do for "$BUILD_TYPE
	exit 0
fi

##########################################################################
#check build type.
##########################################################################
if [ "$BUILD_PRE_UPDATE_SECUREOS" = "TRUE" ]
then
	echo "UBOOT UPDATE("$BUILD_TYPE"): update bl32.img for secureos."
	cp -f $WORKSPACE/source/vendor/amlogic/tdk/secureos/gx/bl32.img $UBOOT_SOURCE_PATH/fip/gxl
	if [ $? -ne 0 ]
	then
		echo $BUILD_TYPE" copy bl32.img fail."
		exit 1
	fi
fi

##########################################################################
# INSTALL GMS PACKAGE FROM LOCAL DIRECTY.
##########################################################################
if [ "$BUILD_PRE_INSTALL_GMS" = "TRUE" ]
then
	echo "Install gms patckage"
	$AML_SCRIPTS_PATH/android/install_gms_package.sh  $GMS_VERSION $GMS_INSTALL_PATH
	if [ $? -ne 0 ]
	then
		exit 1
	fi
fi

exit 0
