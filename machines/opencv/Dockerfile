# FROM auser/python23
FROM auser/spark

ENV OPENCV_VERSION 3.1.0
ENV LD_LIBRARY_PATH /usr/local/lib
ENV OPENCV_ROOT /usr/local/src
ENV OPENCV_HOME $OPENCV_ROOT/opencv

USER root

RUN apt-get update -yq
RUN apt-get -yq dist-upgrade

# Install opencv prerequisites...
# [ Base ]
# Install git, bc and dependencies
RUN apt-get install -yq \
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
RUN apt-get install -y --no-install-recommends libboost-all-dev

RUN apt-get remove -yq python python-dev

# Install build-essential, git, python-dev, pip and other dependencies
RUN apt-get install -y libopenblas-dev

# [ OpenCV ]

# GUI:
RUN apt-get install -yq qt5-default

# Media I/O:
RUN apt-get install -yq zlib1g-dev \
            libjpeg-dev \
            libwebp-dev \
            libpng-dev \
            libtiff5-dev \
            libjasper-dev \
            libopenexr-dev \
            libgdal-dev

# Video I/O:
RUN apt-get install -yq libdc1394-22-dev \
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
RUN apt-get install -yq \
    libtool \
    v4l-utils \
    libtbb-dev \
    libqtwebkit-dev \
    libqt4-dev \
    libxml2-dev \
    qtmobility-dev \
    libeigen3-dev \
    libtesseract-dev

RUN apt-get install -yq \
    unzip \
    g++ \
    jq

RUN apt-get clean -yq

ENV CUDA_LIB_PATH=/usr/local/cuda/lib64/stubs/

USER compute
RUN conda env list

RUN source activate py2 && \
    export CONDA_DIR="$(conda info --json | jq -r .default_prefix)" && \
    echo $CONDA_DIR && \
    cp $CONDA_DIR/include/*.h $CONDA_DIR/include/python2.7

RUN source activate py3 && \
    export CONDA_DIR="$(conda info --json | jq -r .default_prefix)" && \
    echo $CONDA_DIR && \
    cp $CONDA_DIR/include/*.h $CONDA_DIR/include/python3.4m

# RUN source activate py3 && \
#     PY3_CONDA_DIR=$(conda info --json | jq -r .default_prefix) \
#     ls -l "$PY3_CONDA_DIR"
#
# RUN echo "CONDA DIR =>" $PY2_CONDA_DIR
# RUN echo "CONDA DIR =>" $PY3_CONDA_DIR
#
# RUN cp $CONDA_DIR/envs/py2/include/*.h $CONDA_DIR/envs/py2/include/python2.7
# RUN cp $CONDA_DIR/include/*.h $CONDA_DIR/include/py3.4m/

# Build OpenCV 3.x
# =================================
# WORKDIR /usr/local/src
WORKDIR $OPENCV_ROOT
USER compute
RUN mkdir -p $OPENCV_ROOT && \
    cd $OPENCV_ROOT && \
    git clone --branch $OPENCV_VERSION --depth 1 https://github.com/Itseez/opencv.git && \
    git clone --branch $OPENCV_VERSION --depth 1 https://github.com/Itseez/opencv_contrib.git && \
    source activate py2 && export PY2_CONDA_DIR="$(conda info --json | jq -r .default_prefix)" && \
    source activate py3 && export PY3_CONDA_DIR="$(conda info --json | jq -r .default_prefix)" && \
    mkdir $OPENCV_HOME/build && \
    cd $OPENCV_HOME/build && \
    cmake -D CMAKE_BUILD_TYPE=Release \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D WITH_TBB=ON \
          # -D BUILD_PYTHON_SUPPORT=ON \
          -D WITH_V4L=ON \
#          -D INSTALL_C_EXAMPLES=ON \     bug w/ tag=3.1.0: cmake has error
          -D INSTALL_C_EXAMPLES=OFF \
          -D INSTALL_PYTHON_EXAMPLES=OFF \
          -D BUILD_EXAMPLES=OFF \
          -D BUILD_DOCS=OFF \
          -D OPENCV_EXTRA_MODULES_PATH=$OPENCV_ROOT/opencv_contrib/modules \
          # -D WITH_XIMEA=YES \
#          -D WITH_QT=YES \
          # -D WITH_FFMPEG=YES \
          # -D WITH_PVAPI=YES \
          # -D WITH_GSTREAMER=YES \
          -D WITH_TIFF=YES \
          -D WITH_OPENCL=YES \
          -D PYTHON2_EXECUTABLE=$PY2_CONDA_DIR/bin/python \
          -D PYTHON2_INCLUDE_DIR=$PY2_CONDA_DIR/include \
          -D PYTHON2_LIBRARIES=$PY2_CONDA_DIR/lib/libpython2.7.so \
          -D PYTHON2_PACKAGES_PATH=$PY2_CONDA_DIR/lib/python2.7/site-packages \
          -D PYTHON2_NUMPY_INCLUDE_DIRS=$PY2_CONDA_DIR/lib/python2.7/site-packages/numpy/core/include/ \
          -D BUILD_opencv_py3=ON \
          -D PYTHON3_EXECUTABLE=$PY3_CONDA_DIR/bin/python \
          -D PYTHON3_INCLUDE_DIR=$PY3_CONDA_DIR/include/py3.4m/ \
          -D PYTHON3_LIBRARY=$PY3_CONDA_DIR/lib/libpy3.so \
          -D PYTHON_LIBRARY=$PY3_CONDA_DIR/lib/libpy3.so \
          -D PYTHON3_PACKAGES_PATH=$PY3_CONDA_DIR/lib/python3.4/site-packages \
          -D PYTHON3_NUMPY_INCLUDE_DIRS=$PY3_CONDA_DIR/lib/python3.4/site-packages/numpy/core/include/ \
          .. && \
      make -j8

RUN make install && \
      ldconfig && \
      rm -rf $OPENCV_ROOT

RUN sh -c 'echo "/usr/local/lib" > /etc/ld.so.conf.d/opencv.conf'
RUN ln -sf /usr/local/src/opencv/release/lib/cv2.* /usr/lib/py3/dist-packages/
RUN ln -sf /usr/local/src/opencv/release/lib/py3/cv2.* /usr/lib/py3/dist-packages/
#

USER compute
## Additional python modules
RUN source activate py2 && pip install imutils
RUN source activate py3 && pip install imutils

# RUN DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
#     libboost-dev \
#     libboost-python-dev
#
# RUN pip install dlib

## =================================

# ## CLEAN UP
# RUN apt-get clean autoclean -yq && \
#     apt-get autoremove -yq && \
#     rm -rf /tmp/* /var/tmp/* && \
#     rm -rf /var/lib/apt/lists/* && \
#     rm -rf $OPENCV_ROOT/opencv && \
#     rm -rf $OPENCV_ROOT/opencv_contrib
# ## CLEAN UP

## Switch back to jupyter user (for now)
WORKDIR /data
