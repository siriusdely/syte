#!/usr/bin/env bash

# A git post-receive hook
# Taken from: https://gist.github.com/guillaumewuip/072f5c90e96cedc2e1cc
#
# On master branch only:
# 1. It builds a docker image named with the dir name
# 2. It then stop container of the same name, rm it and start a new one

## --- Config

deployDir="/home/sirius/syte"
buildConfig="--rm=true"
runConfig=""
## --- End Config

while read oldrev newrev refname
do
    branch=$(git rev-parse --symbolic --abbrev-ref $refname)

    if [ "master" == "$branch" ]; then

        imageName=`basename $(pwd) | tr \'[:upper:]\' \'[:lower:]\'`    # docker img name
        containerName="$imageName"                                      # docker container name

        lastCommit=`git log --pretty=format:'%h' -n 1`  # get last commit for img tag

        echo "Hook : deploy to dir $deployDir"
        # we're in a bare repo, so let's checkout this somewhere
        GIT_WORK_TREE=$deployDir git checkout -f master
        cd $deployDir

        echo "Docker : Building $imageName:$lastCommit"
        buildID=`docker build $buildConfig --tag $imageName .`  # This build and tag the image with "latest" tag
        docker tag $imageName:latest $imageName:$lastCommit     # Add the commit tag

        if [ $? -ne 0 ]; then
            echo "Docker : Build failed, aborting"
        fi

        echo "Docker : stop and rm $containerName"
        docker stop $containerName
        docker rm $containerName

        if [ $? -ne 0 ]; then
            echo "Docker : Stop failed, aborting"
        fi

        echo "Docker : run $containerName"
        docker run --name $containerName -d $runConfig $imageName:latest

        if [ $? -ne 0 ]; then
            echo "Docker : Run failed, aborting"
        fi

    fi
done
