#!/bin/bash
#########################################################################
#																		#
#							publish uboot								#
#																		#
#########################################################################
#check params num
if [ $# != 2 ]
then
	echo "Params num error."
	echo "build_uboot need 2 input params:"
	echo "param 1: uboot source path"
	echo "param 2: uboot image publish dest path."
	exit 1
fi


##########################################################################
#publish uboot images
##########################################################################
UBOOT_OUTPUT_PATH=$1/build
UBOOT_PUBLISH_PATH=$2

UBOOT_IMAGE_LIST=(
	u-boot.bin u-boot.bin.usb.bl2 u-boot.bin.usb.tpl u-boot.bin.sd.bin
)

UBOOT_PUBSH_IMAGE_LIST=(
	bootloader.img upgrade/u-boot.bin.usb.bl2 upgrade/u-boot.bin.usb.tpl upgrade/u-boot.bin.sd.bin
)


idx=0
for object in ${UBOOT_IMAGE_LIST[@]}
do
	if [ -f "$UBOOT_OUTPUT_PATH/$object" ]
	then
		cp "$UBOOT_OUTPUT_PATH/$object"  $UBOOT_PUBLISH_PATH/${UBOOT_PUBSH_IMAGE_LIST[$idx]}
		if [ $? -ne 0 ]
		then
			echo "UBOOT PUBLISH:"$UBOOT_OUTPUT_PATH/$object" publish failed."
			exit 1
		fi
	else
		echo "UBOOT PUBLISH:"$UBOOT_OUTPUT_PATH/$object" not exist. Build uboot must failed, please check!"
		exit 1
	fi
	
	let idx++
done


exit 0
