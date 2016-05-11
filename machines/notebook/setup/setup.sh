#!/bin/bash
#
# Initial setup script for compute machine

# Log commands & exit on error
set -xe

OPENCV_VER=3.1.0
OPENCV_CONTRIB_VER="${OPENCV_VER}"
OPENCV_INSTALL_PREFIX="/opt/opencv"
PYTHON_PACKAGES="ipython jupyter"
CONDA_DIR=/opt/conda

cd /tmp

export PATH="/home/${USER_LOGIN}/.local/bin:$CONDA_DIR/bin:$PATH"

function install_opencv() {
	echo "Installing OpenCV..."

	# Create download directory
	OPENCV_WORKDIR="$(mktemp -d --tmpdir opencv-compile.XXXXXX)"
	cd "${OPENCV_WORKDIR}"

	# Download and extract OpenCV and OpenCV contrib modules
	echo "Dowloading and extracting OpenCV..."
  git clone --branch $OPENCV_VER --depth 1 https://github.com/Itseez/opencv.git
  git clone --branch $OPENCV_VER --depth 1 https://github.com/Itseez/opencv_contrib.git

	echo "Compiling OpenCV..."
	OPENCV_CONTRIB_MODULES=${OPENCV_WORKDIR}/opencv_contrib-${OPENCV_CONTRIB_VER}/modules

	cd opencv-${OPENCV_VER}
	mkdir release; cd release
	cmake -DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_INSTALL_PREFIX=${OPENCV_INSTALL_PREFIX} \
		-DOPENCV_EXTRA_MODULES_PATH=${OPENCV_CONTRIB_MODULES} \
		..

	make -j8 && make install

	# Add OpenCV to profile
	cat >>/etc/profile.d/opencv.sh <<EOI
export OPENCV_PREFIX="${OPENCV_INSTALL_PREFIX}"
export PATH="\${OPENCV_PREFIX}/bin:\${PATH}"
export LD_LIBRARY_PATH="\${OPENCV_PREFIX}/lib:\${LD_LIBRARY_PATH}"
export PKG_CONFIG_PATH="\${OPENCV_PREFIX}/lib/pkgconfig:\${PKG_CONFIG_PATH}"
for _pp in "\${OPENCV_PREFIX}"/lib/python*/dist-packages; do
	export PYTHONPATH="\${_pp}:\${PYTHONPATH}"
done
EOI

	echo "Deleting OpenCV build directory..."
	rm -r "${OPENCV_WORKDIR}"
}

install_opencv
