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


ANDROID_BURN_IMG_LIST=(
	aml_upgrade_package.img
)
ANDROID_BURN_IMG_FILE=aml_upgrade_img.tar.xz

ANDROID_SYSTEM_IMG_LIST=(
	system.img
	obj/KERNEL_OBJ/vmlinux
)
ANDROID_SYSTEM_IMG_FILE=system_vmlinux_img.tar.xz

ANDROID_OTHER_IMG_LIST=(
	u-boot.bin
	u-boot.bin.sd.bin
	dtb.img
	boot.img
	recovery.img
        system.img
)
ANDROID_OTHER_IMG_FILE=other_img.tar.xz




##########################################################################
#compress imsg before publish
##########################################################################
LAST_PWD=$(pwd)
cd "$ANDROID_OUTPUT_PATH"

COMPRESS_RET=0

COMPRESS_IMGS=''
for object in ${ANDROID_BURN_IMG_LIST[@]}
do
	obj_path=$object
	echo "obj_path "$obj_path
	COMPRESS_IMGS=$object" "$COMPRESS_IMGS
	if [ ! -f $obj_path ]
	then
		echo "object "$obj_path" not exist, android build should failed, please check."
		COMPRESS_RET=1
	else
		chmod +r $obj_path
	fi
done
echo "compress:"$COMPRESS_IMGS
tar Jcvf $ANDROID_BURN_IMG_FILE $COMPRESS_IMGS
if [ $? -ne 0 ]
then
	COMPRESS_RET=1
fi

COMPRESS_IMGS=''
for object in ${ANDROID_SYSTEM_IMG_LIST[@]}
do
	obj_path=$object
	echo "obj_path "$obj_path
	COMPRESS_IMGS=$object" "$COMPRESS_IMGS
	if [ ! -f $obj_path ]
	then
		echo "object "$obj_path" not exist, android build should failed, please check."
		COMPRESS_RET=1
	else
		chmod +r $obj_path
	fi
done
echo "compress:"$COMPRESS_IMGS
tar Jcvf $ANDROID_SYSTEM_IMG_FILE $COMPRESS_IMGS
if [ $? -ne 0 ]
then
	COMPRESS_RET=1
fi

COMPRESS_IMGS=''
for object in ${ANDROID_OTHER_IMG_LIST[@]}
do
	obj_path=$object
	echo "obj_path "$obj_path
	COMPRESS_IMGS=$object" "$COMPRESS_IMGS
	if [ ! -f $obj_path ]
	then
		echo "object "$obj_path" not exist, android build should failed, please check."
		COMPRESS_RET=1
	else
		chmod +r $obj_path
	fi
done
echo "compress:"$COMPRESS_IMGS
tar Jcvf $ANDROID_OTHER_IMG_FILE $COMPRESS_IMGS
if [ $? -ne 0 ]
then
	COMPRESS_RET=1
fi


cd "$LAST_PWD"

if [ $COMPRESS_RET -ne 0 ]
then
	echo "COMPRESS IMGS FAILED."
	exit 1
fi


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


exit 0
