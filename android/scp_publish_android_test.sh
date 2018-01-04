#!/bin/bash
#########################################################################
#																		#
#							scp	publish android							#
#																		#
#########################################################################
#check params num
if [ $# < 4 ]
then
	echo "Params num error."
	echo "scp     publish android need 4 input params:"
	echo "param 1: android build output path."
	echo "param 2: android publish server address."
	echo "param 3: dest path on publish server."
	echo "param 4: copy dir path"
	exit 1
fi

ANDROID_OUTPUT_PATH=$1
ADNROID_PUBLISH_SERVER=$2
ANDROID_PUBLISH_PATH=$3
ANDROID_COPY_DIR=$4
ANDROID_MANIFEST_PUBLISH_PATH=$5

#HOST_NANE=`hostname`
#echo "HOST_NANE: ${HOST_NANE}"
#str=`echo ${HOST_NANE} | cut -d '-' -f 2`
#echo "str: $str"
#ADNROID_PUBLISH_SERVER=`echo firmware-$str.amlogic.com`
echo "ADNROID_PUBLISH_SERVER: ${ADNROID_PUBLISH_SERVER}"

ANDROID_BURN_IMG_LIST=(
	aml_upgrade_package.img
)
ANDROID_BURN_IMG_FILE=aml_upgrade_img.tar.bz2

ANDROID_SYSTEM_IMG_LIST=(
	system.img
	obj/KERNEL_OBJ/vmlinux
)
ANDROID_SYSTEM_IMG_FILE=system_vmlinux_img.tar.bz2

ANDROID_OTHER_IMG_LIST=(
	u-boot.bin
	u-boot.bin.sd.bin
	dtb.img
	boot.img
	recovery.img
	ramdisk.img
	kernel
)
ANDROID_OTHER_IMG_FILE=other_img.tar.bz2




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
tar cf $ANDROID_BURN_IMG_FILE -I pbzip2 $COMPRESS_IMGS
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
tar cf $ANDROID_SYSTEM_IMG_FILE -I pbzip2 $COMPRESS_IMGS
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
tar cf $ANDROID_OTHER_IMG_FILE -I pbzip2 $COMPRESS_IMGS
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
echo "copy_dest_dir: "$ANDROID_COPY_DIR
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
cp $ANDROID_OUTPUT_PATH/$ANDROID_BURN_IMG_FILE $ANDROID_COPY_DIR/

scp $ANDROID_OUTPUT_PATH/$ANDROID_SYSTEM_IMG_FILE autobuild@$ADNROID_PUBLISH_SERVER:$ANDROID_PUBLISH_PATH
if [ $? -ne 0 ]
then
	echo "publish SYSTEM IMG failed."
	exit 1
fi
cp $ANDROID_OUTPUT_PATH/$ANDROID_SYSTEM_IMG_FILE $ANDROID_COPY_DIR/

scp $ANDROID_OUTPUT_PATH/$ANDROID_OTHER_IMG_FILE autobuild@$ADNROID_PUBLISH_SERVER:$ANDROID_PUBLISH_PATH
if [ $? -ne 0 ]
then
	echo "publish OTHER IMG failed."
	exit 1
fi
cp $ANDROID_OUTPUT_PATH/$ANDROID_OTHER_IMG_FILE $ANDROID_COPY_DIR/

scp $ANDROID_OUTPUT_PATH/*.zip autobuild@$ADNROID_PUBLISH_SERVER:$ANDROID_PUBLISH_PATH
if [ $? -ne 0 ]
then
	echo "publish upgrade zip failed."
	exit 1
fi
cp $ANDROID_OUTPUT_PATH/*.zip $ANDROID_COPY_DIR/

scp $ANDROID_OUTPUT_PATH/*.xml autobuild@$ADNROID_PUBLISH_SERVER:$ANDROID_PUBLISH_PATH
if [ $? -ne 0 ]
then
	echo "publish manifest & jenkins xml failed."
	exit 1
fi
cp $ANDROID_OUTPUT_PATH/*.xml $ANDROID_COPY_DIR/

scp $ANDROID_OUTPUT_PATH/*.xml autobuild@$ADNROID_PUBLISH_SERVER:$ANDROID_MANIFEST_PUBLISH_PATH

exit 0
