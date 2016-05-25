#######################
# OpenCV
#######################

RUN git clone --branch {{ OPENCV_VERSION }} --depth 1 https://github.com/Itseez/opencv.git $INSTALL_ROOT/opencv && \
    git clone --branch {{ OPENCV_VERSION }} --depth 1 https://github.com/Itseez/opencv_contrib.git $INSTALL_ROOT/opencv_contrib

RUN mkdir $INSTALL_ROOT/opencv/build
WORKDIR $INSTALL_ROOT/opencv/build

ENV PY2_DIR "$CONDA_DIR/envs/py2"
ENV PY3_DIR "$CONDA_DIR/envs/py3"

RUN apt-get install -yq software-properties-common && \
    add-apt-repository ppa:george-edison55/cmake-3.x && \
    apt-get update -yq && \
    apt-get install -yq --only-upgrade cmake
    # apt-get install -yq qt5-default libvtk6-dev

RUN \
  export PY2_SITE_PACKAGES=$($PY2_DIR/bin/python -c "import site;print(site.getsitepackages()[0])") && \
  export PY3_SITE_PACKAGES=$($PY3_DIR/bin/python -c "import site;print(site.getsitepackages()[0])") && \
  export PY2_INCLUDE_DIR=$($PY2_DIR/bin/python -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") && \
  export PY3_INCLUDE_DIR=$($PY3_DIR/bin/python -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") && \

  export CUDA_LIB_PATH=/usr/local/cuda-7.5/targets/x86_64-linux/lib/stubs/:/usr/local/cuda/lib64/stubs/:$LD_LIBRARY_PATH && \
    export LD_LIBRARY_PATH=$CUDA_LIB_PATH:$LD_LIBRARY_PATH && \
    cmake -D CMAKE_BUILD_TYPE=Release \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D WITH_TBB=ON \
          -D WITH_V4L=ON \
#          -D INSTALL_C_EXAMPLES=ON \     bug w/ tag=3.1.0: cmake has error
          -D INSTALL_PYTHON_EXAMPLES=ON \
          -D BUILD_EXAMPLES=ON \
          -D BUILD_DOCS=OFF \
          -D OPENCV_EXTRA_MODULES_PATH=$INSTALL_ROOT/opencv_contrib/modules \
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
          -D PYTHON2_NUMPY_INCLUDE_DIRS=$PY2_SITE_PACKAGES/numpy/core/include/ \

          -D PYTHON2_EXECUTABLE=$PY2_DIR/bin/python \
          -D PYTHON2_PACKAGES_PATH=$PY2_SITE_PACKAGES \
          -D PYTHON2_LIBRARY=$PY2_DIR/lib/libpython2.7.so \
          -D PYTHON2_NUMPY_INCLUDE_DIRS=$PY2_SITE_PACKAGES/numpy/core/include \

          -D PYTHON_INCLUDE_DIR=$PY2_INCLUDE_DIR \
          -D PYTHON_INCLUDE_DIR2=$PY3_INCLUDE_DIR \

          -D BUILD_opencv_python3=ON \
          -D PYTHON3_EXECUTABLE=$PY3_DIR/bin/python \
          -D PYTHON3_INCLUDE_DIR=$PY3_DIR/include/python3.4m \
          -D PYTHON3_INCLUDE_DIRS=$PY3_DIR/include/python3.4m \
          -D PYTHON_INCLUDE_DIRS=$PY3_DIR/include/python3.4m \
          -D PYTHON3_PACKAGES_PATH=$PY3_SITE_PACKAGES \
          -D PYTHON3_LIBRARY=$PY3_DIR/lib/libpython3.4m.so \
          -D PYTHON3_NUMPY_INCLUDE_DIRS=$PY3_SITE_PACKAGES/numpy/core/include \
          .. && \
      make -j8

RUN make install && \
    ldconfig

ENV PYTHONPATH $PYTHONPATH:$($PY2_DIR/bin/python -c "import site;print(site.getsitepackages()[0])")
ENV PYTHONPATH $PYTHONPATH:$($PY3_DIR/bin/python -c "import site;print(site.getsitepackages()[0])")

RUN ls -l $INSTALL_ROOT/opencv/build/lib/python3

RUN cp $INSTALL_ROOT/opencv/build/lib/cv2.so $PY2_SITE_PACKAGES/cv2.so && \
    cp $INSTALL_ROOT/opencv/build/lib/python3/cv2.cpython-34m.so $PY3_SITE_PACKAGES/cv2.so

# RUN cp $INSTALL_ROOT/opencv/build/lib/cv2.so /usr/local/lib/python2.7/ && \
    # cp $INSTALL_ROOT/opencv/build/lib/cv2.so /usr/local/lib/python3.4/
RUN source activate py2 && \
    python2.7 -c "import cv2; print('cv2.__version__ = ' + str(cv2.__version__))"
RUN source activate py3 && \
    python3.4 -c "import cv2; print('cv2.__version__ = ' + str(cv2.__version__))"

#######################
# End OpenCV
#######################
