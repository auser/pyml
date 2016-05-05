#!/bin/bash

locale-gen en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US:en
export LC_ALL=en_US.UTF-8

# [ common utilities ]
DEBIAN_FRONTEND=noninteractive apt-get install \
    -yq --no-install-recommends \
    autoconf \
    automake \
    build-essential \
    cmake \
    cmake-curses-gui \
    curl \
    git \
    mercurial \
    pkg-config \
    python-software-properties \
    software-properties-common \
    sudo \
    wget \
    unzip

# [ CUDA ]
# Change to the /tmp directory
cd /tmp && \
# Download run file
  wget http://developer.download.nvidia.com/compute/cuda/7.5/Prod/local_installers/cuda_7.5.18_linux.run && \
# Make the run file executable and extract
  chmod +x cuda_*_linux.run && ./cuda_*_linux.run -extract=`pwd` && \
# Install CUDA drivers (silent, no kernel)
  ./NVIDIA-Linux-x86_64-*.run -s --no-kernel-module && \
# Install toolkit (silent)
  ./cuda-linux64-rel-*.run -noprompt && \
# Clean up
  rm -rf *.run

# Add to path
export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
