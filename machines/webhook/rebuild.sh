#!/bin/sh

CLONE_URL=$1
SHA1=$2
NAME=$3

GIT=$(which git)

echo "git: $GIT"

$GIT clone --depth 1 $CLONE_URL $NAME
cd $NAME
$GIT reset $SHA1 --hard

make build-all
