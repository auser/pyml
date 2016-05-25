#!/bin/bash

set -e

# update OS
sudo apt-get -y update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
sudo apt-get install -y gcc g++ gfortran build-essential git wget \
    linux-image-generic libopenblas-dev htop

cat >> $HOME/.bashrc <<EOF
export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
EOF

# install cuda
# TODO this is installing lots of desktup GUI dependencies, is there a faster
# smaller package to install?
CUDA=cuda-repo-ubuntu1404_7.5-18_amd64.deb
sudo wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1404/x86_64/$CUDA
sudo dpkg -i $CUDA
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install cuda

# TODO is this a better way of installing cuda?
# http://robotics.usc.edu/~ampereir/wordpress/?p=1247

# we're done, but you need to reboot to enable cuda
