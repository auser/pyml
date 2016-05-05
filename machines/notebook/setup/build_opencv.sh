#!/bin/bash

# FROM auser/python23
# FROM auser/spark

OPENCV_VERSION=${OPENCV_VERSION:-3.1.0}
OPENCV_ROOT=${OPENCV_ROOT:-/usr/local/src}
OPENCV_HOME=${OPENCV_HOME:-$OPENCV_ROOT/opencv}

LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

apt-get update -yq
apt-get -yq dist-upgrade

# Install opencv prerequisites...
# [ Base ]
# Install git, bc and dependencies
apt-get install -yq \
  git \
  bc \
  cmake \
  libgflags-dev \
  libavcodec-dev \
  build-essential \
  checkinstall \
  pkg-config \
  yasm \
  libjpeg-dev \
  libtiff-dev \
  libjasper-dev \
  libavformat-dev \
  libswscale-dev \
  libv4l-dev \
  libgoogle-glog-dev \
  libopencv-dev \
  libleveldb-dev \
  libsnappy-dev \
  liblmdb-dev \
  libgtk2.0-dev \
  libhdf5-serial-dev \
  libprotobuf-dev \
  protobuf-compiler \
  libatlas-base-dev \
  gfortran \
  g++

# Install boost
apt-get install -y --no-install-recommends libboost-all-dev

apt-get remove -yq python python-dev

# Install build-essential, git, python-dev, pip and other dependencies
apt-get install -y libopenblas-dev

# [ OpenCV ]

# GUI:
apt-get install -yq qt5-default

# Media I/O:
apt-get install -yq zlib1g-dev \
            libjpeg-dev \
            libwebp-dev \
            libpng-dev \
            libtiff5-dev \
            libjasper-dev \
            libopenexr-dev \
            libgdal-dev

# Video I/O:
apt-get install -yq libdc1394-22-dev \
            libavcodec-dev libavformat-dev \
            libswscale-dev \
            libtheora-dev \
            libvorbis-dev \
            libxvidcore-dev \
            libx264-dev yasm \
            libopencore-amrnb-dev \
            libopencore-amrwb-dev libv4l-dev \
            libxine2-dev

# Parallelism and linear algebra libraries:
apt-get install -yq \
    libtool \
    v4l-utils \
    libtbb-dev \
    libqtwebkit-dev \
    libqt4-dev \
    libxml2-dev \
    qtmobility-dev \
    libeigen3-dev \
    libtesseract-dev

apt-get install -yq \
    unzip \
    g++

apt-get clean -yq

export CUDA_LIB_PATH=/usr/local/cuda/lib64/stubs/

cp $CONDA_DIR/envs/python2/include/*.h $CONDA_DIR/envs/python2/include/python2.7
cp $CONDA_DIR/include/*.h $CONDA_DIR/include/python3.4m/

# Build OpenCV 3.x
# =================================
# WORKDIR /usr/local/src
cd $OPENCV_ROOT

mkdir -p $OPENCV_ROOT && \
    cd $OPENCV_ROOT && \
    git clone --branch $OPENCV_VERSION --depth 1 https://github.com/Itseez/opencv.git && \
    git clone --branch $OPENCV_VERSION --depth 1 https://github.com/Itseez/opencv_contrib.git && \
    mkdir $OPENCV_HOME/build && \
    cd $OPENCV_HOME/build && \
    cmake -D CMAKE_BUILD_TYPE=Release \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D WITH_TBB=ON \
          -D WITH_V4L=ON \
          -D INSTALL_C_EXAMPLES=OFF \
          -D INSTALL_PYTHON_EXAMPLES=OFF \
          -D BUILD_EXAMPLES=OFF \
          -D BUILD_DOCS=OFF \
          -D OPENCV_EXTRA_MODULES_PATH=$OPENCV_ROOT/opencv_contrib/modules \
          -D WITH_TIFF=YES \
          -D WITH_OPENCL=YES \
          -D PYTHON2_EXECUTABLE=$CONDA_DIR/envs/python2/bin/python \
          -D PYTHON2_INCLUDE_DIR=$CONDA_DIR/envs/python2/include/python2.7 \
          -D PYTHON2_LIBRARIES=$CONDA_DIR/envs/python2/lib/libpython2.7.so \
          -D PYTHON2_PACKAGES_PATH=$CONDA_DIR/envs/python2/lib/python2.7/site-packages \
          -D PYTHON2_NUMPY_INCLUDE_DIRS=$CONDA_DIR/envs/python2/lib/python2.7/site-packages/numpy/core/include/ \
          -D BUILD_opencv_python3=ON \
          -D PYTHON3_EXECUTABLE=$CONDA_DIR/bin/python \
          -D PYTHON3_INCLUDE_DIR=$CONDA_DIR/include/python3.4m/ \
          -D PYTHON3_LIBRARY=$CONDA_DIR/lib/libpython3.so \
          -D PYTHON_LIBRARY=$CONDA_DIR/lib/libpython3.so \
          -D PYTHON3_PACKAGES_PATH=$CONDA_DIR/lib/python3.4/site-packages \
          -D PYTHON3_NUMPY_INCLUDE_DIRS=$CONDA_DIR/lib/python3.4/site-packages/numpy/core/include/ \
          .. && \
      make -j2 && \
      make install && \
      ldconfig && \
      rm -rf $OPENCV_ROOT

sh -c 'echo "/usr/local/lib" > /etc/ld.so.conf.d/opencv.conf'
ln -sf /usr/local/src/opencv/release/lib/cv2.* /usr/lib/python3/dist-packages/
ln -sf /usr/local/src/opencv/release/lib/python3/cv2.* /usr/lib/python3/dist-packages/
#
## Additional python modules
$CONDA_DIR/envs/python2/bin/pip install imutils
$CONDA_DIR/bin/pip install imutils

# DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
#     libboost-dev \
#     libboost-python-dev
#
# pip install dlib

## =================================
