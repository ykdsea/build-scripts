#!/bin/bash
#########################################################################
#																		#
#						install gms source								#
#																		#
#########################################################################
#check params num
if [ $# != 2 ]
then
	echo "Params num error."
	echo "build_uboot need 2 input params:"
	echo "param 1: gms package name"
	echo "param 2: the path gms should install."
	exit 1
fi


##########################################################################
#global vars.
##########################################################################
ANDROID_GMS_PACKAGE=$AML_GMS_PATH/$1.tar.gz
ANDROID_GMS_INSTALL_PATH=$2


##########################################################################
#check src & dest path .
##########################################################################

#check AML_GMS_PATH enviroment if set.
if [ "$AML_GMS_PATH" = "" ]
then
	echo "AML_GMS_PATH is null, need set it to the local gms path."
	exit 1
else
	if [ ! -d "$AML_GMS_PATH" ]
	then
		echo "AML_GMS_PATH ("$AML_GMS_PATH") is not exist, please check."
		exit 1
	fi
fi

#check gms package which need install.
if [ ! -f "$ANDROID_GMS_PACKAGE" ]
then
	echo "GMS package ("$ANDROID_GMS_PACKAGE") is not exist, please check."
	exit 1
fi

#check AML_BUILD_WORK_BASE_PATH path.
if [ "$AML_BUILD_WORK_BASE_PATH" = "" ]
then
	echo "AML_BUILD_WORK_BASE_PATH is null, need set it to the local gms path."
	exit 1
else
	if [ ! -d "$AML_BUILD_WORK_BASE_PATH" ]
	then
		echo "AML_BUILD_WORK_BASE_PATH ("$AML_BUILD_WORK_BASE_PATH") is not exist, please check."
		exit 1
	fi
fi

#check gms install dest path
expr index "$ANDROID_GMS_INSTALL_PATH" "$AML_BUILD_WORK_BASE_PATH"
if [ $? == 0 ]
then
	echo "INSTALL PATH("$ANDROID_GMS_INSTALL_PATH") is not in work dir("$AML_BUILD_WORK_BASE_PATH")."
	exit 1
else
	if [ ! -d "$ANDROID_GMS_INSTALL_PATH" ]
	then
		echo "gms install path ("$ANDROID_GMS_INSTALL_PATH") is not exist, create it."
		mkdir -p $ANDROID_GMS_INSTALL_PATH
		if [ $? -ne 0 ]
		then
			exit 1
		fi
	else
		echo "gms install path ("$ANDROID_GMS_INSTALL_PATH") exist, clean it."
		rm -r "$ANDROID_GMS_INSTALL_PATH"
	fi
fi


##########################################################################
#install gms.tar.gz to dest path.
##########################################################################

echo "tar zxf $ANDROID_GMS_PACKAGE -C $ANDROID_GMS_INSTALL_PATH"
tar zxf "$ANDROID_GMS_PACKAGE" -C "$ANDROID_GMS_INSTALL_PATH"
if [ $? -ne 0 ]
then
	exit 1
else
	exit 0
fi

