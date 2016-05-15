FROM bethgelab/jupyter-torch:cuda7.5-cudnn4
# FROM ubuntu:14.04
# FROM auser/torch

ENV OPENCV_VERSION 3.1.0
ENV TESSERACT_VERSION 3.04.00
ENV LEPTONICA_VERSION 1.73
ENV FFMPEG_VERSION v0.6.1

ENV LD_LIBRARY_PATH /usr/local/lib
ENV INSTALL_ROOT /usr/local/src
ENV CUDA_ROOT /usr/local/cuda/bin
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

WORKDIR $INSTALL_ROOT
RUN git clone --branch $OPENCV_VERSION --depth 1 https://github.com/Itseez/opencv.git $INSTALL_ROOT/opencv && \
    git clone --branch $OPENCV_VERSION --depth 1 https://github.com/Itseez/opencv_contrib.git $INSTALL_ROOT/opencv_contrib && \
    # git clone --branch $TESSERACT_VERSION --depth 1 https://github.com/tesseract-ocr/tesseract.git $INSTALL_ROOT/tesseract && \
    # git clone --branch $LEPTONICA_VERSION --depth 1 https://github.com/DanBloomberg/leptonica.git $INSTALL_ROOT/leptonica && \
    git clone --branch $FFMPEG_VERSION --depth 1 git://source.ffmpeg.org/ffmpeg $INSTALL_ROOT/ffmpeg

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib

#######################
# Tesseract
#######################

RUN apt-get install -yq \
    libwebp-dev \
    giflib-tools \
    autoconf automake libtool checkinstall

WORKDIR $INSTALL_ROOT
RUN wget http://www.leptonica.org/source/leptonica-${LEPTONICA_VERSION}.tar.gz -O $INSTALL_ROOT/leptonica.tar.gz && \
    tar -zxvf leptonica.tar.gz && \
    rm -rf leptonica.tar.gz && \
    cd leptonica-${LEPTONICA_VERSION} && \
    ./configure && \
    make -j ${NUM_CORES} && \
    make install && \
    ldconfig

#######################
# End Tesseract
#######################


#######################
# Tesseract
#######################

WORKDIR $INSTALL_ROOT/
RUN wget https://github.com/tesseract-ocr/tesseract/archive/${TESSERACT_VERSION}.tar.gz \
      -O $INSTALL_ROOT/tesseract.tar.gz
RUN tar -zxvf $INSTALL_ROOT/tesseract.tar.gz && \
    rm -rf tesseract.tar.gz && \
    cd tesseract-${TESSERACT_VERSION} && \
    ls -la && \
    /bin/bash ./autogen.sh && \
    ./configure && \
    LDFLAGS="-L/usr/local/lib" CFLAGS="-I/usr/local/include" make -j ${NUM_CORES} && \
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
          -D CMAKE_INSTALL_PREFIX=$(python3 -c "import sys; print(sys.prefix)") \
          -D WITH_TBB=ON \
          -D WITH_V4L=ON \
#          -D INSTALL_C_EXAMPLES=ON \     bug w/ tag=3.1.0: cmake has error
          -D INSTALL_PYTHON_EXAMPLES=ON \
          -D BUILD_EXAMPLES=OFF \
          -D BUILD_DOCS=OFF \
          -D OPENCV_EXTRA_MODULES_PATH=/usr/local/src/opencv_contrib/modules \
          -D WITH_XIMEA=YES \
#          -D WITH_QT=YES \
          -D WITH_FFMPEG=YES \
          -D WITH_PVAPI=YES \
          -D WITH_GSTREAMER=YES \
          -D WITH_TIFF=YES \
          -D WITH_OPENCL=YES \
          -D ENABLE_FAST_MATH=1 -D CUDA_FAST_MATH=1 -D WITH_CUBLAS=1 \

          -D Tesseract_LIBRARY=/usr/local/lib/libtesseract.so \
          -D Tesseract_INCLUDE_DIR=/usr/local/include/tesseract \

          -D OPENCV_EXTRA_MODULES_PATH=$INSTALL_ROOT/opencv_contrib/modules \

          -D BUILD_opencv_python2=ON \
          -D PYTHON2_NUMPY_INCLUDE_DIRS=/usr/lib/python2.7/dist-packages/numpy/core/include/ \

          -D PYTHON2_EXECUTABLE=$(which python2.7) \
          -D PYTHON2_INCLUDE_DIR=$(python2.7 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
          -D PYTHON2_PACKAGES_PATH=$(python2.7 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") \
          -D PYTHON2_LIBRARIES=/usr/lib/x86_64-linux-gnu/libpython2.7.so \
          -D PYTHON2_NUMPY_INCLUDE_DIRS=$(python2.7 -c "from os import path; import numpy; print(path.join(path.split(numpy.__file__)[0], 'numpy', 'core', 'include'))") \

          -D BUILD_opencv_python3=ON \
          -D PYTHON3_EXECUTABLE=$(which python3.4) \
          -D PYTHON3_INCLUDE_DIR=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
          -D PYTHON3_PACKAGES_PATH=$(python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") \
          -D PYTHON3_LIBRARIES=/usr/lib/python3.4/config-3.4m-x86_64-linux-gnu/libpython3.4.so \
          -D PYTHON3_NUMPY_INCLUDE_DIRS=$(python3.4 -c "from os import path; import numpy; print(path.join(path.split(numpy.__file__)[0], 'numpy', 'core', 'include'))") \
          .. && \
      make -j8

RUN make install && \
    ldconfig

ENV PYTHONPATH $PYTHONPATH:$(python2.7 -c "import site;print(site.getsitepackages()[0])")
ENV PYTHONPATH $PYTHONPATH:$(python3.4 -c "import site;print(site.getsitepackages()[0])")

RUN cp /usr/local/src/opencv/build/lib/cv2.so $(python2 -c "import site; print(site.getsitepackages()[0])")/cv2.so && \
    cp /usr/local/src/opencv/build/lib/python3/cv2.cpython-34m.so $(python3 -c "import site; print(site.getsitepackages()[0])")/cv2.so

# RUN cp /usr/local/src/opencv/build/lib/cv2.so /usr/local/lib/python2.7/ && \
    # cp /usr/local/src/opencv/build/lib/cv2.so /usr/local/lib/python3.4/
RUN python2.7 -c "import cv2; print('cv2.__version__ = ' + str(cv2.__version__))"
RUN python3.4 -c "import cv2; print('cv2.__version__ = ' + str(cv2.__version__))"

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

#######################
# Cleanup
#######################
RUN rm -rf /usr/local/src/leptonica && \
    rm -rf /usr/local/src/tesseract && \
    rm -rf /usr/local/src/opencv && \
    apt-get clean -yq

# USER compute
RUN mkdir /data
WORKDIR /data

EXPOSE 8888
COPY entry.sh /opt/compute-container/entry.sh
RUN chmod +x /opt/compute-container/entry.sh
CMD ["/opt/compute-container/entry.sh"]
