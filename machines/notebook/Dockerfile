FROM bethgelab/jupyter-torch:cuda7.5-cudnn4
# FROM ubuntu:14.04
# FROM auser/torch

ENV OPENCV_VERSION 3.1.0
ENV LD_LIBRARY_PATH /usr/local/lib
ENV INSTALL_ROOT /usr/local/src/
ENV OPENCV_ROOT /usr/local/src
ENV OPENCV_HOME $OPENCV_ROOT/opencv
ENV USER_LOGIN compute
ENV CONDA_DIR /opt/conda

COPY etc/apt/sources.list /etc/apt/
RUN apt-get update -qq
RUN apt-get install -yq \
    mktemp

#######################
# OpenCV
#######################

WORKDIR $OPENCV_ROOT
USER compute
RUN git clone --branch $OPENCV_VERSION --depth 1 https://github.com/Itseez/opencv.git $OPENCV_ROOT/opencv
RUN git clone --branch $OPENCV_VERSION --depth 1 https://github.com/Itseez/opencv_contrib.git $OPENCV_ROOT/opencv_contrib

RUN mkdir $OPENCV_HOME/build
WORKDIR $OPENCV_HOME/build

RUN source activate py2 && export PY2_CONDA_DIR="$(conda info --json | jq -r .default_prefix)" && \
    source activate py3 && export PY3_CONDA_DIR="$(conda info --json | jq -r .default_prefix)" && \
    cmake -D CMAKE_BUILD_TYPE=Release \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D WITH_TBB=ON \
          -D BUILD_PYTHON_SUPPORT=ON \
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

          -D OPENCV_EXTRA_MODULES_PATH=$OPENCV_ROOT/opencv_contrib/modules \

          -D PYTHON2_EXECUTABLE=$PY2_CONDA_DIR/bin/python \
          -D PYTHON2_INCLUDE_DIR=$PY2_CONDA_DIR/include/python2.7 \
          -D PYTHON2_LIBRARIES=$PY2_CONDA_DIR/lib/libpython2.7.so \
          -D PYTHON2_PACKAGES_PATH=$PY2_CONDA_DIR/lib/python2.7/site-packages \
          -D PYTHON2_NUMPY_INCLUDE_DIRS=$PY2_CONDA_DIR/lib/python2.7/site-packages/numpy/core/include/ \

          -D BUILD_opencv_python3=ON \
          -D PYTHON3_EXECUTABLE=$PY3_CONDA_DIR/bin/python \
          -D PYTHON3_INCLUDE_DIR=$PY3_CONDA_DIR/include/python3.4m/ \
          -D PYTHON3_LIBRARY=$PY3_CONDA_DIR/lib/libpython3.4m.so \
          -D PYTHON_LIBRARY=$PY3_CONDA_DIR/lib/libpython3.4m.so \
          -D PYTHON3_PACKAGES_PATH=$PY3_CONDA_DIR/lib/python3.4/site-packages \
          -D PYTHON3_NUMPY_INCLUDE_DIRS=$PY3_CONDA_DIR/lib/python3.4/site-packages/numpy/core/include/ \
          .. && \
      make -j8

#######################
# End OpenCV
#######################

# Copy local configuration & fix perms
COPY system-conf /
# RUN chown -R root:root /etc/sudoers.d && chmod 0440 /etc/sudoers.d/*
RUN addgroup compute-users

USER compute



EXPOSE 8888
COPY entry.sh /opt/compute-container/entry.sh
RUN chmod +x /opt/compute-container/entry.sh
CMD ["/opt/compute-container/entry.sh"]
USER compute
