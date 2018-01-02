H=/tmp/$(whoami)
NOW_TIME=`date +%y%m%d-%H%M%S`
TM=${H}/manifest_${NOW_TIME}.txt
SRC=${H}/src_${NOW_TIME}.txt
PTH=${H}/pth_${NOW_TIME}.txt
S=${H}/s_${NOW_TIME}.txt
P=${H}/p_${NOW_TIME}.txt
F=${H}/f_${NOW_TIME}.txt
G=${H}/g_${NOW_TIME}.txt

mkdir -p ${H}
grep "<project" $WORKSPACE/source/.repo/manifests/default.xml > ${TM}
grep "<project" $WORKSPACE/source/.repo/manifests/amlogic.xml >> ${TM}
grep "<project" $WORKSPACE/source/.repo/manifests/tv_trunk.xml >> ${TM}

cut -f 2 -d '=' ${TM} > ${SRC}
cut -f 2 -d '"' ${SRC} > ${S}
cut -f 3 -d '=' ${TM} > ${PTH}
cut -f 2 -d '"' ${PTH} > ${P}
paste ${P} ${S} > ${F}
sed -e 's/[[:space:]][[:space:]]*/;/g' ${F} > ${G}
rm -rf ${TM} ${SRC} ${PTH} ${S} ${P}

for commit in $CHANGEID_PATCHSET
do
    echo $commit
    project=$(ssh -p 29418 sky.zhou@scgit.amlogic.com gerrit query $commit | grep 'project:' | sed 's/.*project:\s*\(\S*\).*/\1/g' | sed 's/^acos\///')
    if [ $? != 0 ]; then
        echo "patchset num $commit is error. We can not find it. It may be moved."
        exit 1
    fi
    echo $project
    
    if [ "${project}" == "platform/manifest" ]; then
        cd $WORKSPACE/source/.repo/manifests
        if [ $? != 0 ]; then
            echo "We can not find the directory: $WORKSPACE/source/.repo/manifests"
            exit 1
        fi
        refId=$(ssh -p 29418 sky.zhou@scgit.amlogic.com gerrit query --current-patch-set $commit | grep 'ref:' | awk '{print $2}')
        echo $refId
        patchSetNum=${refId##*/}
        echo $patchSetNum
        if [ "$DOWNLOAD_METHOD" = "cherry-pick" ]; then
            git fetch ssh://sky.zhou@scgit.amlogic.com:29418/$project $refId && git cherry-pick FETCH_HEAD
        else
        	git pull ssh://sky.zhou@scgit.amlogic.com:29418/$project $refId
        fi
        if [ $? != 0 ]; then
            echo "auto cherry-pick error, please fix it."
            exit 1
        fi
        cd $WORKSPACE/source
        repo sync -j16
        if [ $? != 0 ]; then
            echo "repo sync error, please check."
            exit 1
        fi
        NOW_TIME=`date +%y%m%d-%H%M%S`
		TM=${H}/manifest_${NOW_TIME}.txt
		SRC=${H}/src_${NOW_TIME}.txt
		PTH=${H}/pth_${NOW_TIME}.txt
		S=${H}/s_${NOW_TIME}.txt
		P=${H}/p_${NOW_TIME}.txt
		F=${H}/f_${NOW_TIME}.txt
		G=${H}/g_${NOW_TIME}.txt

        mkdir -p ${H}
        grep "<project" $WORKSPACE/source/.repo/manifests/default.xml > ${TM}
        grep "<project" $WORKSPACE/source/.repo/manifests/amlogic.xml >> ${TM}
        grep "<project" $WORKSPACE/source/.repo/manifests/tv_trunk.xml >> ${TM}

        cut -f 2 -d '=' ${TM} > ${SRC}
        cut -f 2 -d '"' ${SRC} > ${S}
        cut -f 3 -d '=' ${TM} > ${PTH}
        cut -f 2 -d '"' ${PTH} > ${P}
        paste ${P} ${S} > ${F}
        sed -e 's/[[:space:]][[:space:]]*/;/g' ${F} > ${G}
        rm -rf ${TM} ${SRC} ${PTH} ${S} ${P}
    else
        while read -r src dst
        do
            C=$((C+1))
            #echo ${src}
            name=$(echo ${src} | cut -f 1 -d ';')
            path_n=$(echo ${src} | cut -f 2 -d ';')
            #echo "name: ${name}, path_n: ${path_n}"
            if [ ${name} == ${project} ]
            then
                echo "here name: ${name}, path_n: ${path_n}"
                D=1
                cd $WORKSPACE/source/${path_n}
                if [ $? != 0 ]; then
                    echo "We can not find the directory: $WORKSPACE/source/${path_n}"
                    exit 1
                fi
                refId=$(ssh -p 29418 sky.zhou@scgit.amlogic.com gerrit query --current-patch-set $commit | grep 'ref:' | awk '{print $2}')
                echo $refId
                patchSetNum=${refId##*/}
                echo $patchSetNum
                if [ "$DOWNLOAD_METHOD" = "cherry-pick" ]; then
                    git fetch ssh://sky.zhou@scgit.amlogic.com:29418/$project $refId && git cherry-pick FETCH_HEAD
                else
        	        git pull ssh://sky.zhou@scgit.amlogic.com:29418/$project $refId
                fi
                if [ $? != 0 ]; then
                    echo "auto cherry-pick error, please fix it."
                    exit 1
                fi
                break
            fi
        done < ${G}
    
        if [ $D != 1 ]; then
            echo "Sorry, we can not find ${project} in this xml"
            exit 1
        fi
    fi

    cd $WORKSPACE
done
