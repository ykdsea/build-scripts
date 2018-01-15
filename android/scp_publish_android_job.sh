#!/bin/bash
#########################################################################
#																		#
#							scp	publish android							#
#																		#
#########################################################################
#check params num
if [ $# < 3 ]
then
	echo "Params num error."
	echo "scp publish android need 3 input params:"
	echo "param 1: android build output path."
	echo "param 2: android publish server address."
	echo "param 3: dest path on publish server."
	exit 1
fi

ANDROID_OUTPUT_PATH=$1
ADNROID_PUBLISH_SERVER=$2
ANDROID_PUBLISH_PATH=$3
ANDROID_MANIFEST_PUBLISH_PATH=$4

echo "ADNROID_PUBLISH_SERVER: ${ADNROID_PUBLISH_SERVER}"

ANDROID_BURN_IMG_FILE=aml_upgrade_img.tar.bz2
ANDROID_SYSTEM_IMG_FILE=system_vmlinux_img.tar.bz2
ANDROID_OTHER_IMG_FILE=other_img.tar.bz2

##########################################################################
#publish comporessed imgs
##########################################################################
echo "PUBLISH PATH : "$ANDROID_PUBLISH_PATH
ssh autobuild@$ADNROID_PUBLISH_SERVER	"mkdir -p $ANDROID_PUBLISH_PATH"
if [ $? -ne 0 ]
then
	echo "ssh the publish server "$ADNROID_PUBLISH_SERVER" failed."
	exit 1
fi

scp $ANDROID_OUTPUT_PATH/$ANDROID_BURN_IMG_FILE autobuild@$ADNROID_PUBLISH_SERVER:$ANDROID_PUBLISH_PATH
if [ $? -ne 0 ]
then
	echo "publish BURN IMG failed."
	exit 1
fi

scp $ANDROID_OUTPUT_PATH/$ANDROID_SYSTEM_IMG_FILE autobuild@$ADNROID_PUBLISH_SERVER:$ANDROID_PUBLISH_PATH
if [ $? -ne 0 ]
then
	echo "publish SYSTEM IMG failed."
	exit 1
fi

scp $ANDROID_OUTPUT_PATH/$ANDROID_OTHER_IMG_FILE autobuild@$ADNROID_PUBLISH_SERVER:$ANDROID_PUBLISH_PATH
if [ $? -ne 0 ]
then
	echo "publish OTHER IMG failed."
	exit 1
fi

scp $ANDROID_OUTPUT_PATH/*.zip autobuild@$ADNROID_PUBLISH_SERVER:$ANDROID_PUBLISH_PATH
if [ $? -ne 0 ]
then
	echo "publish upgrade zip failed."
	exit 1
fi

scp $ANDROID_OUTPUT_PATH/*.xml autobuild@$ADNROID_PUBLISH_SERVER:$ANDROID_PUBLISH_PATH
if [ $? -ne 0 ]
then
	echo "publish manifest & jenkins xml failed."
	exit 1
fi

echo "PUBLISH MANIFEST PATH : "$ANDROID_MANIFEST_PUBLISH_PATH
ssh autobuild@$ADNROID_PUBLISH_SERVER   "mkdir -p $ANDROID_MANIFEST_PUBLISH_PATH"
scp $ANDROID_OUTPUT_PATH/*.xml autobuild@$ADNROID_PUBLISH_SERVER:$ANDROID_MANIFEST_PUBLISH_PATH

exit 0
