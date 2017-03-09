#!/bin/bash
#########################################################################
#																		#
#						save jenkins build url							#
#																		#
#########################################################################
#publish the build url.

JENKINS_BUILD_XML=$WORKSPACE/jenkins-build-url.xml
if [ -f $JENKINS_BUILD_XML ]
then
	rm $JENKINS_BUILD_XML
fi

touch $JENKINS_BUILD_XML

echo "<content>" > $JENKINS_BUILD_XML
echo "<note>open the url below in browser to check the detail of this build</note>" >> $JENKINS_BUILD_XML
echo "<url>"$BUILD_URL"</url>" >> $JENKINS_BUILD_XML
echo "</content>" >> $JENKINS_BUILD_XML
mv  $JENKINS_BUILD_XML "$WORKSPACE/source/out/target/product/$BOARD"


exit 0