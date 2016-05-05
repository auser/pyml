#!/bin/bash -ex

if [[ $UPDATE  =~ true || $UPDATE =~ 1 || $UPDATE =~ yes ]]; then
  echo "==> Updating list of repositories"
  apt-get -yq update

  echo "==> Performing dist-upgrade (all packages and kernel)"
  apt-get -y dist-upgrade --force-yes
fi
