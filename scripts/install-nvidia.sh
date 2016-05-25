#!/usr/bin/env bash
echo "Installing nvidia"

DRIVER_NAME=NVIDIA-Linux-x86_64-361.42.run
DRIVER_URL=http://us.download.nvidia.com/XFree86/Linux-x86_64/361.42/$DRIVER_NAME

NVIDIA_PACKAGE=nvidia-docker_1.0.0.rc-1_amd64.deb
NVIDIA_DOCKER_URL=https://github.com/NVIDIA/nvidia-docker/releases/download/v1.0.0-rc/$NVIDIA_PACKAGE

sudo apt-get install --no-install-recommends -y gcc make libc-dev
wget -P /tmp $DRIVER_URL
sudo sh /tmp/$DRIVER_NAME

wget -P /tmp $NVIDIA_DOCKER_URL
sudo dpkg -i /tmp/$NVIDIA_PACKAGE

sudo -b nohup nvidia-docker-plugin > /tmp/nvidia-docker.log
