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
    g++

RUN apt-get clean -yq

ENV CUDA_LIB_PATH=/usr/local/cuda/lib64/stubs/

RUN cp /opt/conda/envs/python2/include/*.h /opt/conda/envs/python2/include/python2.7
RUN cp /opt/conda/include/*.h /opt/conda/include/python3.4m/

# Build OpenCV 3.x
# =================================
# WORKDIR /usr/local/src
WORKDIR $OPENCV_ROOT
RUN git clone --branch $OPENCV_VERSION --depth 1 https://github.com/Itseez/opencv.git
RUN git clone --branch $OPENCV_VERSION --depth 1 https://github.com/Itseez/opencv_contrib.git
RUN mkdir -p $OPENCV_HOME/release
WORKDIR $OPENCV_HOME/release
RUN cmake -D CMAKE_BUILD_TYPE=RELEASE \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D WITH_TBB=ON \
          # -D BUILD_PYTHON_SUPPORT=ON \
          -D WITH_V4L=ON \
#          -D INSTALL_C_EXAMPLES=ON \     bug w/ tag=3.1.0: cmake has error
          -D INSTALL_PYTHON_EXAMPLES=ON \
          -D BUILD_EXAMPLES=ON \
          -D BUILD_DOCS=ON \
          -D OPENCV_EXTRA_MODULES_PATH=/usr/local/src/opencv_contrib/modules \
          -D WITH_XIMEA=YES \
#          -D WITH_QT=YES \
          -D WITH_FFMPEG=YES \
          -D WITH_PVAPI=YES \
          -D WITH_GSTREAMER=YES \
          -D WITH_TIFF=YES \
          -D WITH_OPENCL=YES \
          -D PYTHON2_EXECUTABLE=/opt/conda/envs/python2/bin/python \
          -D PYTHON2_INCLUDE_DIR=/opt/conda/envs/python2/include/python2.7 \
          -D PYTHON2_LIBRARIES=/opt/conda/envs/python2/lib/libpython2.7.so \
          -D PYTHON2_PACKAGES_PATH=/opt/conda/envs/python2/lib/python2.7/site-packages \
          -D PYTHON2_NUMPY_INCLUDE_DIRS=/opt/conda/envs/python2/lib/python2.7/site-packages/numpy/core/include/ \
          -D BUILD_opencv_python3=ON \
          -D PYTHON3_EXECUTABLE=/opt/conda/bin/python \
          -D PYTHON3_INCLUDE_DIR=/opt/conda/include/python3.4m/ \
          -D PYTHON3_LIBRARY=/opt/conda/lib/libpython3.so \
          -D PYTHON_LIBRARY=/opt/conda/lib/libpython3.so \
          -D PYTHON3_PACKAGES_PATH=/opt/conda/lib/python3.4/site-packages \
          -D PYTHON3_NUMPY_INCLUDE_DIRS=/opt/conda/lib/python3.4/site-packages/numpy/core/include/ \
          ..
RUN make -j4
RUN make install
RUN sh -c 'echo "/usr/local/lib" > /etc/ld.so.conf.d/opencv.conf'
RUN ldconfig
#
## Additional python modules
RUN /opt/conda/envs/python2/bin/pip install imutils
RUN /opt/conda/bin/pip install imutils

## =================================

## Switch back to jupyter user (for now)
USER jovyan

WORKDIR /data

# # [ Base ]
# # Install git, bc and dependencies
# RUN apt-get install -yq \
#   git \
#   bc \
#   cmake \
#   libgflags-dev \
#   libavcodec-dev \
#   build-essential \
#   checkinstall \
#   pkg-config \
#   yasm \
#   libjpeg-dev \
#   libtiff-dev \
#   libjasper-dev \
#   libavformat-dev \
#   libswscale-dev \
#   libv4l-dev \
#   libgoogle-glog-dev \
#   libopencv-dev \
#   libleveldb-dev \
#   libsnappy-dev \
#   liblmdb-dev \
#   libgtk2.0-dev \
#   libhdf5-serial-dev \
#   libprotobuf-dev \
#   protobuf-compiler \
#   libatlas-base-dev \
#   gfortran \
#   g++
#
# # Install boost
# RUN apt-get install -y --no-install-recommends libboost-all-dev
#
# RUN apt-get remove -yq python python-dev
#
# # Install build-essential, git, python-dev, pip and other dependencies
# RUN apt-get install -y libopenblas-dev
#
# # [ OpenCV ]
#
# # GUI:
# RUN apt-get install -yq qt5-default libvtk6-dev
#
# # Media I/O:
# RUN apt-get install -yq zlib1g-dev \
#             libjpeg-dev \
#             libwebp-dev \
#             libpng-dev \
#             libtiff5-dev \
#             libjasper-dev \
#             libopenexr-dev \
#             libgdal-dev
#
# # Video I/O:
# RUN apt-get install -yq libdc1394-22-dev \
#             libavcodec-dev libavformat-dev \
#             libswscale-dev \
#             libtheora-dev \
#             libvorbis-dev \
#             libxvidcore-dev \
#             libx264-dev yasm \
#             libopencore-amrnb-dev \
#             libopencore-amrwb-dev libv4l-dev \
#             libxine2-dev
#
# # Parallelism and linear algebra libraries:
# RUN apt-get install -yq \
#     libtool \
#     v4l-utils \
#     libtbb-dev \
#     libqtwebkit-dev \
#     libqt4-dev \
#     libxml2-dev \
#     qtmobility-dev \
#     libeigen3-dev \
#     libtesseract-dev
#
# RUN apt-get install -yq \
#     unzip \
#     g++
#
# RUN apt-get clean -yq

# WORKDIR /usr/local/src/opencv
# RUN git clone https://github.com/itseez/opencv.git /usr/local/src/opencv
# RUN git clone https://github.com/Itseez/opencv_contrib.git /usr/local/src/opencv_contrib
# RUN git checkout "$OPENCV_VERSION" && mkdir release

# ENV PYTHONPATH="/usr/local/lib/python2.7/site-packages:$PYTHONPATH"
# ENV PYTHONPATH="/usr/local/lib/python3.4/site-packages:$PYTHONPATH"

# ENV CUDA_LIB_PATH=/usr/local/cuda/lib64/stubs/

# RUN cd /usr/local/src/opencv/release && \
#     cmake -G "Unix Makefiles" \
#     -D OPENCV_EXTRA_MODULES_PATH=/usr/local/src/opencv_contrib/modules \
#     -D CMAKE_BUILD_TYPE=RELEASE \
#     -D CMAKE_INSTALL_PREFIX=/opt/local \
#     -D WITH_TBB=OFF \
#     -D WITH_V4L=ON \
#     -D INSTALL_C_EXAMPLES=OFF \
#     -D BUILD_EXAMPLES=OFF \
#     -D INSTALL_PYTHON_EXAMPLES=ON \
#     -D BUILD_opencv_python2=ON \
#     -D BUILD_opencv_python3=ON \
#     -D WITH_QT=ON \
#     -D WITH_GDAL=ON \
#     -D WITH_XINE=ON \
#     -D WITH_OPENGL=ON \
#     -D ENABLE_FAST_MATH=ON \
#     -D BUILD_SHARED_LIBS=OFF \
#     -D INSTALL_TESTS=OFF \
#     -D PYTHON2_EXECUTABLE=/opt/conda/envs/python2/bin/python \
#     -D PYTHON2_INCLUDE_DIR=/opt/conda/envs/python2/include/python2.7 \
#     -D PYTHON2_LIBRARIES=/opt/conda/envs/python2/lib/libpython2.7.so \
#     -D PYTHON2_PACKAGES_PATH=/opt/conda/envs/python2/lib/python2.7/site-packages \
#     -D PYTHON2_NUMPY_INCLUDE_DIRS=/opt/conda/envs/python2/lib/python2.7/site-packages/numpy/core/include/ \
#     -D BUILD_opencv_python3=ON \
#     -D PYTHON3_EXECUTABLE=/opt/conda/bin/python \
#     -D PYTHON3_INCLUDE_DIR=/opt/conda/include/python3.4m/ \
#     -D PYTHON3_LIBRARY=/opt/conda/lib/libpython3.so \
#     -D PYTHON_LIBRARY=/opt/conda/lib/libpython3.so \
#     -D PYTHON3_PACKAGES_PATH=/opt/conda/lib/python3.4/site-packages \
#     -D PYTHON3_NUMPY_INCLUDE_DIRS=/opt/conda/lib/python3.4/site-packages/numpy/core/include/ \
#     -D WITH_GSTREAMER=ON ..

#     # -D FORCE_VTK=ON \
#     # -D INSTALL_CREATE_DISTRIB=ON \
#     # -D INSTALL_TO_MANGLED_PATHS=ON \
#     # -D BUILD_NEW_PYTHON_SUPPORT=ON \
#     # -D CUDA_GENERATION=Kepler \
#     # -D WITH_IMAGEIO=ON \

# # /usr/local/lib/python2.7/
# # /usr/local/lib/python3.4/


# RUN cd /usr/local/src/opencv/release && \
#       make all -j4 && \
#       make install && \
#       ldconfig

# RUN apt-get purge -yq cmake && apt-get autoremove -yq --purge
