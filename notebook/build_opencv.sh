#!/bin/bash -ex

apt-get update \
	  && DEBIAN_FRONTEND=noninteractive \
	                    apt-get install -y cmake

git clone https://github.com/itseez/opencv.git /usr/local/src/opencv

cd /usr/local/src/opencv

git clone https://github.com/Itseez/opencv_contrib.git /usr/local/src/opencv_contrib

git checkout ${OPENCV_VERSION} \
	  && mkdir release

cd /usr/local/src/opencv/release

cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D WITH_IPP=ON -D INSTALL_CREATE_DISTRIB=ON ..

cmake -D CMAKE_BUILD_TYPE=RELEASE \
      -D CMAKE_INSTALL_PREFIX=/usr/local \
      -D OPENCV_EXTRA_MODULES_PATH=/usr/local/src/opencv_contrib \
      -D WITH_TBB=ON -D WITH_V4L=ON \
      -D INSTALL_C_EXAMPLES=OFF \
      -D WITH_IPP=ON \
      -D INSTALL_CREATE_DISTRIB=ON \
      -D INSTALL_PYTHON_EXAMPLES=ON \
      -D BUILD_EXAMPLES=OFF \
      -D WITH_OPENGL=OFF ..

make j4 && make install
ldconfig

cd /

rm -rf /usr/local/src/opencv \
	  && apt-get purge -y cmake \
	  && apt-get autoremove -y --purge
