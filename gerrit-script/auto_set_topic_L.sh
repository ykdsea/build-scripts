#!/bin/bash

#set -x   #print execution process

CHECKPATCH_GERRIT_SERVER=scgit.amlogic.com:8080
GERRIT_CHANGE_NUMBER=$1
# place http user/pass in ~/.netrc:
# machine scgit.amlogic.com login auto.tester password 2XfMUQKtY

function settopic() {
    #'PUT /changes/{change-id}/topic'
    # $1: change id myProject~master~I8473b95934b5732ac55d26311a706c9c2bde9940
    # $2: ReviewInput JSON filename
    # --trace-ascii - : print detial info
    local url=http://$CHECKPATCH_GERRIT_SERVER/a/changes/$1/topic
    curl   \
        -X PUT \
        -f \
        -s -S \
        --digest \
        --netrc \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        --data-binary @$2 \
        "$url"
    return $?
}

function gettopic() {
    #'GET /changes/{change-id}/topic'
    # $1: change id myProject~master~I8473b95934b5732ac55d26311a706c9c2bde9940
    local url=http://$CHECKPATCH_GERRIT_SERVER/a/changes/$1/topic
    #    --trace-ascii - 
    curl   \
        -f \
        -s -S \
        --digest \
        --netrc \
        -H "Accept: application/json" \
        -o /tmp/topic.txt \
        "$url"
    return $?
}

echo $GERRIT_CHANGE_NUMBER

bugid=$(ssh -p 29418 sky.zhou@scgit.amlogic.com gerrit query $GERRIT_CHANGE_NUMBER | grep 'PD#' | head -1 | sed 's/.*PD#\s*\(\S*\).*/\1/g' | sed 's/^acos\///')
echo $bugid
#"topic": "Documentation"

gettopic $GERRIT_CHANGE_NUMBER

topicnow=$(cat /tmp/topic.txt | head -2 | tail -1 | cut -f 2 -d '"')
echo "topicnow: $topicnow"

if [ ! $topicnow ]; then
  echo "topicnow is NULL"
else
  if [ $topicnow == "NONE" ]; then
    echo "topicnow is NONE, need reset topic"
  else
    echo "topic has been setted, exit"
    exit 0
  fi
fi

if [ $bugid == "NONE" ]; then
    echo "bugid is NONE, exit"
    exit 0
fi

if [ ! $bugid ]; then
  echo "bugid is NULL, exit"
  exit 0
fi

#changeid=30955
echo "{\"topic\": \"$bugid\"}" > /tmp/topic2.txt
#echo '{"topic": "testing2"}' > /tmp/review.txt
if ! time settopic $GERRIT_CHANGE_NUMBER /tmp/topic2.txt ; then
    echo set topic;
fi

exit 0

