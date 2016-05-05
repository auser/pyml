#!/bin/bash
#
# Initial setup script for compute machine

# Log commands & exit on error
set -e

OPENCV_VER=3.1.0
OPENCV_CONTRIB_VER="${OPENCV_VER}"
OPENCV_INSTALL_PREFIX="/opt/opencv"

NOTES_DIR=/usr/local/src/installed
LOG_DIR=/usr/local/src/logs/
LOG_FILE=/usr/local/src/install_log
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
THIS_DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

mkdir -p $NOTES_DIR $LOG_DIR

function run_script() {
	SCRIPT_NAME=$1
	SCRIPT_PATH=$2

	local result=-1

	if [[ ! -f $NOTES_DIR/$SCRIPT_NAME ]]; then
		/bin/bash $SCRIPT_PATH > "$LOG_DIR/$SCRIPT_NAME"

		result=$?
		if [[ $result -eq 0 ]]; then
			echo "SUCCESS"
			return 0
		else
			return $result
		fi
	fi
}

function install_pip_packages() {
	PYTHON_PACKAGES=$1

	for _pip in pip2 pip3; do
		echo "Upgrading ${_pip}..."
		${_pip} install --upgrade pip

		echo "Installing remaining requirements via ${_pip}..."
		for _pkg in ${PYTHON_PACKAGES}; do
			${_pip} install --upgrade "${_pkg}"
		done
	done
}

function setup_jupyter() {
	_python=$1
	_name=$2

	_ktmp=$(mktemp -d kernelspecs-XXXXXXX)
	echo "Setting up Jupyter for ${_python}"
	_spec_dir="${_ktmp}/$(basename ${_python})"
	mkdir -p "${_spec_dir}"
	cat >"${_spec_dir}/kernel.json" <<EOI
{
	"language": "python",
	"display_name": "${_name}",
	"argv": [
		"${_python}", "-m", "ipykernel", "-f", "{connection_file}"
	]
}
EOI
	jupyter kernelspec install "${_spec_dir}"
	rm -r "${_ktmp}"
}

function install_python() {
	echo "Checking python..."
	run_script python $THIS_DIR/build_python.sh
	# if [[ ! -f $NOTES_DIR/python ]]; then
	# 	echo "Installing python"
	# 	/bin/bash ./build_python.sh
	#
	# 	touch $NOTES_DIR/python
	# fi
}

function install_jupyter() {

	if [[ ! -f $NOTES_DIR/jupyter ]]; then
		echo "Configuring Jupyter notebook server for Python 2 and 3..."
		setup_jupyter python2 "Python 2"
		setup_jupyter python3 "Python 3"

		touch $NOTES_DIR/jupyter
	fi
}

function install_cuda() {
	local res=$(run_script cuda $THIS_DIR/build_cuda.sh)
	if [[ $res -eq 0 ]]; then
		echo "Successfully installed cuda"
	fi
}

function install_opencv() {
	local res=$(run_script opencv ./build_opencv.sh)
	if [[ $res -eq 0 ]]; then
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
	fi
}

function install_spark() {
	local res=$(run_script spark ./build_spark.sh)
	if [[ $res -eq 0 ]]; then
		echo "Installed spark"
	fi
}

function install_tensorflow() {
	local res=$(run_script tensorflow ./build_tensorflow.sh)
	if [[ $res -eq 0 ]]; then
		echo "Installed tensorflow"
	fi
}

function install_torch() {
	local res=$(run_script torch ./build_torch.sh)
	if [[ $res -eq 0 ]]; then
		echo "Installed torch"
	fi
}

function install_testing() {
	echo "Checking testing..."
	local res=$(run_script testing $THIS_DIR/build_test.sh)
	if [[ $res -eq 0 ]]; then
		echo "RESULT: $res"
		touch $NOTES_DIR/testing
	fi
	# if [[ ! -f $NOTES_DIR/python ]]; then
	# 	echo "Installing python"
	# 	/bin/bash ./build_python.sh
	#
	# 	touch $NOTES_DIR/python
	# fi
}

install_cuda
install_python
install_jupyter
install_spark
install_opencv
install_tensorflow
install_torch
