#!/bin/bash
#########################################################################
#																		#
#						source code setup       						#
#																		#
#########################################################################

# UPDATE UBOOT FOR SECUREOS.
UBOOT_SOURCE_PATH="$WORKSPACE/source/uboot"
if [ "$BUILD_TYPE" = "AOSP" ]
then
	echo "UBOOT UPDATE("$BUILD_TYPE"): nothing to do."
else
	echo "UBOOT UPDATE("$BUILD_TYPE"): update bl32.img for secureos."
	cp -f $WORKSPACE/source/vendor/amlogic/tdk/secureos/bl32.img $UBOOT_SOURCE_PATH/fip/gxl
	if [ $? -ne 0 ]
	then
		echo $BUILD_TYPE" copy bl32.img fail."
		exit 1
	fi
fi


# INSTALL GMS PACKAGE FROM LOCAL DIRECTY.
