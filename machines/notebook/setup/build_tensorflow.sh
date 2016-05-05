#!/bin/bash

# [ TensorFlow ]
apt-get update && apt-get install -y \
  curl \
  libfreetype6-dev \
  libpng12-dev \
  libzmq3-dev \
  pkg-config

/opt/conda/envs/python2/bin/pip install --upgrade pip
/opt/conda/envs/python2/bin/pip install --upgrade --ignore-installed \
    https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-0.8.0-cp27-none-linux_x86_64.whl

/opt/conda/bin/pip install --upgrade pip
/opt/conda/bin/pip install --upgrade --ignore-installed \
    https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-0.8.0-cp34-cp34m-linux_x86_64.whl
