FROM jupyter/scipy-notebook

ENV OPENCV_VERSION 3.1.0
ENV LD_LIBRARY_PATH /usr/local/lib

USER root

RUN apt-get update -yq
RUN apt-get -yq dist-upgrade

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
  libjpeg-dev libpng-dev libtiff-dev libjasper-dev \
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
  gfortran

# Install boost
RUN apt-get install -y --no-install-recommends libboost-all-dev

# Install build-essential, git, python-dev, pip and other dependencies
RUN apt-get install -y \
  build-essential \
  checkinstall \
  cmake \
  pkg-config yasm \
  git \
  python-dev \
  libopenblas-dev \
  python-pip \
  python-nose \
  python-numpy \
  python-scipy \
  python-opencv \
  python-tk \
  python2.7-dev \
  python3-dev \
  python3-tk \
  python3-numpy

# [ OpenCV ]

# GUI:
RUN apt-get install -yq qt5-default libvtk6-dev

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
            libswscale-dev libtheora-dev \
            libvorbis-dev libxvidcore-dev \
            libx264-dev yasm \
            libopencore-amrnb-dev \
            libopencore-amrwb-dev libv4l-dev libxine2-dev

# Parallelism and linear algebra libraries:
RUN apt-get install -yq \
    libtbb-dev \
    libeigen3-dev \
    libtesseract-dev

RUN apt-get clean -yq

WORKDIR /usr/local/src/opencv
RUN git clone https://github.com/itseez/opencv.git /usr/local/src/opencv
RUN git clone https://github.com/Itseez/opencv_contrib.git /usr/local/src/opencv_contrib
RUN git checkout "$OPENCV_VERSION" && mkdir release

ENV PYTHONPATH="/usr/local/lib/python2.7/site-packages:$PYTHONPATH"
ENV PYTHONPATH="/usr/local/lib/python3.4/site-packages:$PYTHONPATH"

ENV CUDA_LIB_PATH=/usr/local/cuda/lib64/stubs/

RUN cd /usr/local/src/opencv/release && \
    cmake -G "Unix Makefiles" \
    -D OPENCV_EXTRA_MODULES_PATH=/usr/local/src/opencv_contrib/modules \
    -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D WITH_TBB=ON \
    -D WITH_V4L=ON \
    -D INSTALL_C_EXAMPLES=ON \
    -D BUILD_EXAMPLES=ON \
    -D INSTALL_PYTHON_EXAMPLES=ON \
    -D BUILD_opencv_python2=ON \
    -D BUILD_opencv_python3=ON \
    -D WITH_QT=ON \
    -D WITH_GDAL=ON \
    -D WITH_XINE=ON \
    -D WITH_OPENGL=ON \
    -D ENABLE_FAST_MATH=ON \
    -D BUILD_SHARED_LIBS=ON \
    -D INSTALL_TESTS=OFF \
    -D WITH_GSTREAMER=ON ..
    # -D FORCE_VTK=ON \
    # -D INSTALL_CREATE_DISTRIB=ON \
    # -D INSTALL_TO_MANGLED_PATHS=ON \
    # -D BUILD_NEW_PYTHON_SUPPORT=ON \
    # -D CUDA_GENERATION=Kepler \
    # -D WITH_IMAGEIO=ON \

# /usr/local/lib/python2.7/
# /usr/local/lib/python3.4/


RUN cd /usr/local/src/opencv/release && \
      make all -j4 && \
      make install && \
      ldconfig

RUN apt-get purge -yq cmake && apt-get autoremove -yq --purge
