FROM bethgelab/jupyter-torch:cuda7.5-cudnn4
# FROM ubuntu:14.04
# FROM auser/torch

ENV OPENCV_VERSION 3.1.0
ENV TESSERACT_VERSION 3.04.00
ENV LEPTONICA_VERSION v1.73
ENV FFMPEG_VERSION v0.6.1

ENV LD_LIBRARY_PATH /usr/local/lib
ENV INSTALL_ROOT /usr/local/src/
ENV NUM_CORES 4

RUN apt-get update -qq
RUN apt-get install -yq \
    mktemp

# Copy local configuration & fix perms
COPY system-conf /
# RUN chown -R root:root /etc/sudoers.d && chmod 0440 /etc/sudoers.d/*
RUN addgroup compute-users

#######################
# OpenCV
#######################
RUN apt-get update -qq && apt-get install -qy --force-yes \
    curl \
    git \
    g++ \
    autoconf \
    automake \
    build-essential \
    checkinstall \
    cmake \
    pkg-config \
    yasm \
    libtiff5-dev \
    libpng-dev \
    libjpeg-dev \
    libjasper-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libdc1394-22-dev \
    libxine2-dev \
    libgstreamer0.10-dev \
    libgstreamer-plugins-base0.10-dev \
    libv4l-dev \
    libtbb-dev \
    libgtk2.0-dev \
    libmp3lame-dev \
    libopencore-amrnb-dev \
    libopencore-amrwb-dev \
    libtheora-dev \
    libvorbis-dev \
    libxvidcore-dev \
    libtool \
    v4l-utils \
    default-jdk \
    wget \
    zlib1g-dev \
    libtiff4-dev \
    libjpeg62-dev \
    libpng12-dev \
    tmux \
    libqt4-dev \
    libphonon-dev \
    libxml2-dev \
    libxslt1-dev \
    qtmobility-dev \
    libqtwebkit-dev \
    libfdk_aac-dev \
    libcairo2-dev \
    libpango1.0-dev \
    libicu-dev \
    libleptonica-dev \
    unzip; \
    apt-get clean

RUN git clone --branch $OPENCV_VERSION --depth 1 https://github.com/Itseez/opencv.git $INSTALL_ROOT/opencv && \
    git clone --branch $OPENCV_VERSION --depth 1 https://github.com/Itseez/opencv_contrib.git $INSTALL_ROOT/opencv_contrib && \
    git clone --branch $TESSERACT_VERSION --depth 1 https://github.com/tesseract-ocr/tesseract.git $INSTALL_ROOT/tesseract && \
    git clone --branch $FFMPEG_VERSION --depth 1 git://source.ffmpeg.org/ffmpeg $INSTALL_ROOT/ffmpeg && \
    git clone --branch $LEPTONICA_VERSION --depth 1 https://github.com/DanBloomberg/leptonica.git


ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib

#######################
# Tesseract
#######################

WORKDIR $INSTALL_ROOT/leptonica
RUN cd $INSTALL_ROOT/leptonica && \
    ./autobuild && \
    ./configure && \
    make && \
    make install && \
    ldconfig

#######################
# End Tesseract
#######################


#######################
# Tesseract
#######################

WORKDIR $INSTALL_ROOT/tesseract
RUN cd $INSTALL_ROOT/tesseract && \
    mkdir m4 && \
    ./autogen.sh && \
    ./configure && \
    LDFLAGS="-L/usr/local/lib" CFLAGS="-I/usr/local/include" make && \
    make install && \
    ldconfig

#######################
# End Tesseract
#######################


RUN mkdir $INSTALL_ROOT/opencv/build
WORKDIR $INSTALL_ROOT/opencv/build

RUN CUDA_LIB_PATH=/usr/local/cuda-7.5/targets/x86_64-linux/lib/stubs/:/usr/local/cuda/lib64/stubs/:$LD_LIBRARY_PATH \
    LD_LIBRARY_PATH=$CUDA_LIB_PATH:$LD_LIBRARY_PATH \
    cmake -D CMAKE_BUILD_TYPE=Release \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D WITH_TBB=ON \
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
          -D ENABLE_FAST_MATH=1 -D CUDA_FAST_MATH=1 -D WITH_CUBLAS=1 \

          -D OPENCV_EXTRA_MODULES_PATH=$INSTALL_ROOT/opencv_contrib/modules \

          -D BUILD_opencv_python=ON \
          -D PYTHON2_EXECUTABLE=/usr/bin/python2.7 \
          -D PYTHON2_INCLUDE_DIR=/usr/include/python2.7 \
          -D PYTHON2_LIBRARIES=/usr/lib/x86_64-linux-gnu/libpython2.7.so \
          -D PYTHON2_PACKAGES_PATH=/usr/local/lib/python2.7/dist-packages \
          -D PYTHON2_NUMPY_INCLUDE_DIRS=/usr/lib/python2.7/dist-packages/numpy/core/include/ \

          -D BUILD_opencv_python3=ON \
          -D PYTHON3_EXECUTABLE=/usr/bin/python3.4 \
          -D PYTHON3_INCLUDE_DIR=/usr/include/python3.4/ \
          -D PYTHON3_LIBRARIES=/usr/lib/python3.4/config-3.4m-x86_64-linux-gnu/libpython3.4.so \
          -D PYTHON3_PACKAGES_PATH=/usr/local/lib/python3.4/dist-packages \
          -D PYTHON3_PACKAGES_PATH=/usr/local/lib/python3.4/dist-packages/numpy/core/include \
          .. && \
      make -j8

RUN make install && \
    ldconfig

RUN python -c "import cv2; print('cv2.__version__ = ' + str(cv2.__version__))"


#######################
# End OpenCV
#######################

#######################
# ffmpeg
#######################

# WORKDIR $INSTALL_ROOT/ffmpeg
# RUN ./configure --extra-libs="-ldl" \
#             --enable-gpl \
#             --enable-libass \
#             --enable-libfdk-aac \
#             --enable-libfontconfig \
#             --enable-libfreetype \
#             --enable-libfribidi \
#             --enable-libmp3lame \
#             --enable-libopus \
#             --enable-libtheora \
#             --enable-libvorbis \
#             --enable-libvpx \
#             --enable-libx264 \
#             --enable-nonfree \
#     && make -j ${NUM_CORES} \
#     && make install

#######################
# End ffmpeg
#######################

# RUN rm -rf /usr/local/src/*

# USER compute
RUN mkdir /data
WORKDIR /data

EXPOSE 8888
COPY entry.sh /opt/compute-container/entry.sh
RUN chmod +x /opt/compute-container/entry.sh
CMD ["/opt/compute-container/entry.sh"]
