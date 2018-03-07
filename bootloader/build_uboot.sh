#!/bin/bash
#########################################################################
#																		#
#								make uboot								#
#																		#
#########################################################################
#check params num


##########################################################################
#global vars.
##########################################################################
UBOOT_BOARD_CFG_FILE="$AML_SCRIPTS_PATH/bootloader/uboot-cfg.list"
UBOOT_BUILD_BOARD=$1
UBOOT_SOURCE_PATH=$2
UBOOT_BL32=$3
UBOOT_BUILD_CFG=null
UBOOT_BUILD_RET=0


##########################################################################
#Functions to get uboot configs from board name.
##########################################################################
UBOOT_BOARD_LIST=()
UBOOT_CFG_LIST=()

parseBoardCfgFile(){
	local tmp
	local i=0
	local boardIdx=0
	local cfgIdx=0
	local list=0

	if [ ! -f $1 ]
	then
		echo "file "$1" not exist."
		return 1
	else
		list=`cat $1`
	fi

	for val in $list
	do
		let tmp=i%2
		if [ $tmp -eq 0 ]
		then
			UBOOT_BOARD_LIST[$boardIdx]=$val
			let boardIdx++
		else
			UBOOT_CFG_LIST[$cfgIdx]=$val
			let cfgIdx++
		fi

		let i++
	done
	
	if [ $boardIdx -ne $cfgIdx ]
	then
		echo "cfg file parse error"
		return 1
	else
		echo "Parse cfgs:"
		for ((tmp=0;tmp<$boardIdx;tmp++))
		do
			echo "Board "${UBOOT_BOARD_LIST[$tmp]}" , config "${UBOOT_CFG_LIST[$tmp]}
		done
	fi
	
	return 0
}

getBuildCfg(){
	local i=0
	local ret=1

	for val in ${UBOOT_BOARD_LIST[@]}
	do
		if [ "$val" = "$1" ]
		then
			UBOOT_BUILD_CFG=${UBOOT_CFG_LIST[$i]}
			ret=0
			break;
		fi
		let i++
	done
	
	if [ $ret -eq 0 ]
	then
		echo "get cfg "$UBOOT_BUILD_CFG" for board "$1
	else
		echo "get cfg for board "$1" failed!"
	fi

	return $ret
}

##########################################################################
#make uboot
##########################################################################
parseBoardCfgFile $UBOOT_BOARD_CFG_FILE
if [ $? -ne 0 ]
then
	exit 1
fi

getBuildCfg $UBOOT_BUILD_BOARD
if [ $? -ne 0 ]
then
	exit 1
fi

echo "UBOOT_BUILD_CFG: $UBOOT_BUILD_CFG"
str1=`echo $UBOOT_BUILD_CFG | cut -d "_" -f 1`
echo "str1: $str1"

LAST_WD=$(pwd)
cd "$UBOOT_SOURCE_PATH/bl33"
make distclean
cd "$UBOOT_SOURCE_PATH"
if [ "$3" = "true" ]
then
	echo "build gtvs....$UBOOT_SOURCE_PATH/fip/$str1/bl32.img....."
	./mk $UBOOT_BUILD_CFG --bl32 $UBOOT_SOURCE_PATH/fip/$str1/bl32.img
else
	echo "build aosp........."
	./mk $UBOOT_BUILD_CFG
fi

if [ $? -ne 0 ]
then
        cd "$UBOOT_SOURCE_PATH/bl33"
	make distclean
	cd "$UBOOT_SOURCE_PATH"
	if [ "$3" = "true" ]
	then
		echo "build gtvs....$UBOOT_SOURCE_PATH/fip/$str1/bl32.img....."
		./mk $UBOOT_BUILD_CFG --bl32 $UBOOT_SOURCE_PATH/fip/$str1/bl32.img
	else
		echo "build aosp........."
		./mk $UBOOT_BUILD_CFG
	fi
fi

if [ $? -ne 0 ]
then
	UBOOT_BUILD_RET=1
fi

cd "$LAST_WD"

exit $UBOOT_BUILD_RET



