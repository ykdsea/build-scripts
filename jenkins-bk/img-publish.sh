#!/bin/bash
#########################################################################
#																		#
#						save jenkins build url							#
#																		#
#########################################################################


BUILD_DATE=`date +%Y-%m-%d`
ANDROID_BUILD_PATH="$WORKSPACE/source/out/target/product/$BOARD"
ANDROID_BUILD_INFO=$BOARD-$BUILD_VARIANT-$BUILD_ARCH-$BUILD_TYPE
HTTP_DEST_DIR="$FIRMWARE_UPLOAD_BASE_PATH/$BUILD_DATE/$ANDROID_BUILD_INFO($BUILD_NUMBER)"
SCP_DEST_DIR="/data"$UPLOAD_DEST_DIR
ANDROID_PUBLISH_SERVER=firmware-sh.amlogic.com

$AML_SCRIPTS_PATH/android/scp_publish_android.sh $ANDROID_BUILD_PATH $ANDROID_PUBLISH_SERVER $SCP_DEST_DIR
if [ $? -ne 0 ]
then
	exit 1
fi

######
#Don't remove, for description set plugin.
######
echo "<Download Address>"http://$ANDROID_PUBLISH_SERVER$HTTP_DEST_DIR

exit 0