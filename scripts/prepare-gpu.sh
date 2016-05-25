#!/bin/bash -e

SRC_DIR=/usr/local/src

## Mainly for development speed
# SKIP_TENSORFLOW_BUILD=
# SKIP_TENSORFLOW_PACKAGE_BUILD=
CUDA_VERSION=7.0
PYTHON_VERSION=2.7.10

CUDA_PKG=cuda_7.0.28_linux.run
CUDA_INSTALL_URI=compute/cuda/7_0/Prod/local_installers/$CUDA_PKG

export CUDA_HOME=/usr/local/cuda-$CUDA_VERSION

### DO NOT TOUCH BELOW HERE (UNLESS YOU KNOW WHAT YOU ARE DOING)
zero=0
one=1
## Working dir
cd $SRC_DIR

# Install various packages
sudo apt-get update
sudo apt-get upgrade -y # choose “install package maintainers version”
sudo apt-get install -y build-essential git
# python-pip python-dev \
    #  git python-numpy swig \
    #  default-jdk zip zlib1g-dev \
    #  nvidia-352-updates libcuda1-352 nvidia-prime \
    #  nvidia-cuda-toolkit \
    #  libglu1-mesa libxi-dev libxmu-dev libglu1-mesa-dev \
    #  linux-image-extra-virtual

# Install latest Linux headers
# sudo apt-get install -y linux-source linux-headers-`uname -r`
# sudo apt-get install linux-image-extra-$(uname -r)

sudo apt-get autoremove -y

PYENV_ROOT=/home/ubuntu/.pyenv
if [ ! -d $PYENV_ROOT ]; then
    git clone https://github.com/yyuu/pyenv.git ~/.pyenv
fi

PE=$PYENV_ROOT/bin/pyenv

PYENV_INSTALLED=$(grep -qe "^export PYENV_ROOT" "$HOME/.profile")

if [ -z "$PYENV_INSTALLED" ]; then
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.profile
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.profile
    echo 'eval "$($PE init -)"' >> ~/.profile

    export PATH="$PYENV_ROOT/bin:$PATH"

    $PE init -
fi

PYTHON_VERSION_INSTALLED=$($PE version $PYTHON_VERSION)

if [ -z "$PYTHON_VERSION_INSTALLED" ]; then
   $PE install $PYTHON_VERSION
   $PE global $PYTHON_VERSION
fi

PYTHON_BIN_PATH=$($PE which python)
sudo add-apt-repository ppa:xorg-edgers/ppa -y
sudo apt-get update -yq

# if [ ! -f $SRC_DIR/reboot_after_blacklist ]; then
#   echo -e "blacklist nouveau\nblacklist lbm-nouveau\noptions nouveau modeset=0\nalias nouveau off\nalias lbm-nouveau off\n" | sudo tee /etc/modprobe.d/blacklist-nouveau.conf
#   echo options nouveau modeset=0 | sudo tee -a /etc/modprobe.d/nouveau-kms.conf
#   sudo update-initramfs -u
#   touch $SRC_DIR/reboot_after_blacklist
#   sudo reboot
# fi
#
# Install CUDA 7.0 (note – don't use any other version)
# cd $SRC_DIR
#
# if [ ! -f $SRC_DIR/$CUDA_PKG ]; then
#     wget http://developer.download.nvidia.com/$CUDA_INSTALL_URI
#     sudo chmod +x $CUDA_PKG
#     sudo apt-get install -y nvidia-cuda-toolkit
#
#     sudo mkdir /mnt/tmp
#     sudo chmod 777 /mnt/tmp
#     sudo rm -rf /tmp
#     sudo ln -s /mnt/tmp /tmp
#
#     sudo ./$CUDA_PKG --silent --driver --toolkit --toolkitpath=$CUDA_HOME --samples --samplespath=$HOME/
#
#     sudo chmod 0666 /dev/nvidia*
# fi
#
#
cd $SRC_DIR

# Install CUDNN 6.5 (note – don't use any other version)
if [ -f $SRC_DIR/cudnn-7.0-linux-x64-v4.0-prod.tgz ]; then
  tar zxvf $SRC_DIR/cudnn-*.tgz
  ls -l $SRC_DIR
  sudo cp cuda/lib/libcudnn_static.a $CUDA_HOME/lib64/
  sudo cp cuda/lib/*.so $CUDA_HOME/lib64/
  sudo cp cuda/include/*.h $CUDA_HOME/include/
else
  echo "Please upload the cudnn directory at:"
  echo "$SRC_DIR/cudnn-7.0-linux-x64-v4.0-prod.tgz"
  # rm $SRC_DIR/cudnn-*.tgz
fi

#wget https://s3-eu-west-1.amazonaws.com/christopherbourez/public/cudnn-6.5-linux-x64-v2.tgz
# tar cudnn-6.5-linux-x64-v2.tgz
# rm xvzf cudnn-6.5-linux-x64-v2.tgz
# At this point the root mount is getting a bit full
# I had a lot of issues where the disk would fill up and then Bazel would end up in this weird state complaining about random things
# Make sure you don't run out of disk space when building Tensorflow!
# sudo mkdir /mnt/tmp
# sudo chmod 777 /mnt/tmp
# sudo rm -rf /tmp
# sudo ln -s /mnt/tmp /tmp
# Note that /mnt is not saved when building an AMI, so don't put anything crucial on it

# Install Bazel
# cd $SRC_DIR
#
# if [ ! -f /usr/local/bin/bazel ]; then
#
# if [ ! -d $SRC_DIR/bazel ]; then
#     git clone https://github.com/bazelbuild/bazel.git
# fi
#
# cd $SRC_DIR/bazel
# git checkout tags/0.1.1
# ./compile.sh
# sudo cp output/bazel /usr/local/bin
#
# fi
#
#
# # Install TensorFlow
# cd $SRC_DIR
# export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$CUDA_HOME/lib64"
#
# if [ ! -d $SRC_DIR/tensorflow ]; then
#     git clone --recurse-submodules https://github.com/tensorflow/tensorflow
# fi
#
# echo $SKIP_TENSORFLOW_BUILD
# echo $SKIP_TENSORFLOW_PACKAGE_BUILD
#
# if [ "$SKIP_TENSORFLOW_BUILD" != "$one" ]; then
# cd $SRC_DIR/tensorflow
# PYTHON_BIN_PATH=$PYTHON_BIN_PATH CUDA_TOOLKIT_PATH=$CUDA_HOME CUDA_INSTALL_PATH=$CUDA_HOME CUDNN_INSTALL_PATH=$CUDA_HOME TF_NEED_CUDA=1 ./configure
# bazel build -c opt --config=cuda //tensorflow/cc:tutorials_example_trainer
# fi
#
# # Build Python package
# pip install wheel
#
# if [ "$SKIP_TENSORFLOW_PACKAGE_BUILD" != "$one" ]; then
#
# cd $SRC_DIR/tensorflow
# bazel build -c opt --config=cuda //tensorflow/tools/pip_package:build_pip_package
# bazel-bin/tensorflow/tools/pip_package/build_pip_package $SRC_DIR/tensorflow_pkg
#
# PACKAGE_FILENAME=$(ls $SRC_DIR/tensorflow_pkg | sort -V | tail -n 1)
# sudo pip install $SRC_DIR/tensorflow_pkg/$PACKAGE_FILENAME
# fi
#
# # Install docker-compose
# echo "Checking for docker $(command -v docker)"
# if [ ! -x "$(command -v docker)" ]; then
#
# echo "Installing docker"
# ppa="deb https://apt.dockerproject.org/repo ubuntu-trusty main"
#
# listDir=/etc/apt/sources.list.d
# listFile=$listDir/docker.list
#
# if [ ! -x "$(grep -Fxq "$ppa" $listFile)" ]; then
#     sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
#
#     sudo mkdir -p $listDir
#     echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | sudo tee $listFile
#
#     sudo apt-get update -y
# fi
#
# echo "Installing..."
# sudo apt-get purge lxc-docker -y
# sudo apt-get install docker docker-engine -y
# sudo service docker start
#
# fi
#
# # Test it!
# if [ "$RUN_TEST" != "" ]; then
#  python $SRC_DIR/tensorflow/tensorflow/models/image/cifar10/cifar10_multi_gpu_train.py
# fi
