#!/bin/sh

CLONE_URL=$1
SHA1=$2
NAME=$3

REPO_PATH=/tmp/$NAME
GIT=$(which git)


$GIT clone --depth 1 $CLONE_URL $REPO_PATH
cd $REPO_PATH
$GIT reset $SHA1 --hard

## Build the images
make build-all
cd /

rm -rf /tmp/$NAME
