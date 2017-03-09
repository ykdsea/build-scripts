#!/bin/bash
#########################################################################
#																		#
#						build, publish uboot							#
#																		#
#########################################################################
UBOOT_SOURCE_PATH="$WORKSPACE/source/uboot"
$AML_SCRIPTS_PATH/bootloader/build_uboot.sh $BOARD $UBOOT_SOURCE_PATH
if [ $? -ne 0 ]
then
	exit 1
fi

UBOOT_OUTPUT_PATH="$WORKSPACE/source/device/amlogic/$BOARD"
$AML_SCRIPTS_PATH/bootloader/cp_publish_uboot.sh $UBOOT_SOURCE_PATH $UBOOT_OUTPUT_PATH
if [ $? -ne 0 ]
then
	exit 1
fi

exit 0
