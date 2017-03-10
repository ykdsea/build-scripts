#!/bin/bash
#########################################################################
#																		#
#							scp	publish android							#
#																		#
#########################################################################
#check params num
if [ $# != 3 ]
then
	echo "Params num error."
	echo "build_uboot need 3 input params:"
	echo "param 1: android build output path."
	echo "param 2: android publish server address."
	echo "param 3: dest path on publish server."
	exit 1
fi



ANDROID_OUTPUT_PATH=$1
ADNROID_PUBLISH_SERVER=$2
ANDROID_PUBLISH_PATH=$3

ANDROID_PUBLISH_LIST=(
	u-boot.bin
	dtb.img
	boot.img
	recovery.img
	system.img
	obj/KERNEL_OBJ/vmlinux
)


##########################################################################
#check if all publish object exists.
##########################################################################
for object in ${ANDROID_PUBLISH_LIST[@]}
do
	obj_path=$ANDROID_OUTPUT_PATH/$object
	echo "obj_path "$obj_path

	if [ ! -f $obj_path ]
	then
		echo "object "$obj_path" not exist, android build should failed, please check."
		exit 1
	fi
done


##########################################################################
#publish images
##########################################################################
echo "PUBLISH PATH : "$ANDROID_PUBLISH_PATH
ssh autobuild@$ADNROID_PUBLISH_SERVER	"mkdir -p $ANDROID_PUBLISH_PATH"
if [ $? -ne 0 ]
then
	echo "ssh the publish server "$ADNROID_PUBLISH_SERVER" failed."
	exit 1
fi

for object in ${ANDROID_PUBLISH_LIST[@]}
do
	obj_path="$ANDROID_OUTPUT_PATH/$object"
	scp $obj_path autobuild@$ADNROID_PUBLISH_SERVER:$ANDROID_PUBLISH_PATH
	if [ $? -ne 0 ]
	then
		echo "publish file failed."
		exit 1
	fi
done

scp $ANDROID_OUTPUT_PATH/*.xml autobuild@$ADNROID_PUBLISH_SERVER:$ANDROID_PUBLISH_PATH
if [ $? -ne 0 ]
then
	echo "publish manifest & jenkins xml failed."
	exit 1
fi


exit 0
