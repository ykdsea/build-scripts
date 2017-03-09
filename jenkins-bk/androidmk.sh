#!/bin/bash
#########################################################################
#																		#
#							build android								#
#																		#
#########################################################################
ANDROID_SOURCE_PATH="$WORKSPACE/source"
ANDROID_BUILD_COMBO=$BOARD-$BUILD_VARIANT-$BUILD_ARCH
MANIFEST_SAVE_NAME=build-manifest.xml
$AML_SCRIPTS_PATH/android/build_android.sh $ANDROID_SOURCE_PATH $ANDROID_BUILD_COMBO  $BUILD_TYPE $COMPILE_JOBS $MANIFEST_SAVE_NAME 
if [ $? -ne 0 ]
then
	exit 1
else
	#mv file need publish to output for next step to publish
	mv $ANDROID_SOURCE_PATH/$MANIFEST_SAVE_NAME "$ANDROID_SOURCE_PATH/out/target/product/$BOARD"
fi

exit 0

