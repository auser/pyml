#!/bin/bash

CONDA_DIR=${CONDA_DIR:-/opt/conda}

rm /bin/sh && ln -s /bin/bash /bin/sh


# libav-tools for matplotlib anim
apt-get update && \
    apt-get install -y --no-install-recommends libav-tools \
    libhdf5-dev graphviz libhdf5-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
  libglib2.0-0 libxext6 libsm6 libxrender1 \
  git mercurial subversion
echo 'export PATH=$CONDA_DIR/bin:$PATH' > /etc/profile.d/conda.sh && \
  wget --quiet https://repo.continuum.io/miniconda/Miniconda2-4.0.5-Linux-x86_64.sh && \
  /bin/bash /Miniconda2-4.0.5-Linux-x86_64.sh -b -p $CONDA_DIR && \
  rm Miniconda2-4.0.5-Linux-x86_64.sh

apt-get install -y curl grep sed dpkg && \
  TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
  curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
  dpkg -i tini.deb && \
  rm tini.deb && \
  apt-get clean

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

export PATH=$CONDA_DIR/bin:$PATH

# Install Python 3 packages
$CONDA_DIR/bin/conda install python=3.4
$CONDA_DIR/bin/conda update --all python=3.4
$CONDA_DIR/bin/conda install --quiet --yes \
    'ipywidgets=4.1*' \
    'pandas=0.17*' \
    'numexpr=2.5*' \
    'matplotlib=1.5*' \
    'scipy=0.17*' \
    'seaborn=0.7*' \
    'scikit-learn=0.17*' \
    'scikit-image=0.11*' \
    'sympy=0.7*' \
    'cython=0.23*' \
    'patsy=0.4*' \
    'statsmodels=0.6*' \
    'cloudpickle=0.1*' \
    'dill=0.2*' \
    'numba=0.23*' \
    'bokeh=0.11*' \
    'h5py=2.5*' \
    && $CONDA_DIR/bin/conda clean -tipsy

# Install bleeding-edge Theano
# source activate root && \
#     pip install --upgrade --no-deps git+git://github.com/Theano/Theano.git && \
#     # [ Lasagne ]
#     pip install --upgrade https://github.com/Lasagne/Lasagne/archive/master.zip && \
#     # [ Keras ]
#     mkdir -p /tmp && cd /tmp && \
#     git clone https://github.com/fchollet/keras.git
#
# cd /tmp/keras && \
#   source activate root && python setup.py install

# cd /usr/local/src/keras && \
    # source activate python2 && python setup.py install

# Install Python 2 packages
$CONDA_DIR/bin/conda create --quiet --yes \
    -p $CONDA_DIR/envs/python2 python=2.7 \
    'ipython=4.1*' \
    'ipywidgets=4.1*' \
    'pandas=0.17*' \
    'numexpr=2.5*' \
    'matplotlib=1.5*' \
    'scipy=0.17*' \
    'seaborn=0.7*' \
    'scikit-learn=0.17*' \
    'scikit-image=0.11*' \
    'sympy=0.7*' \
    'cython=0.23*' \
    'patsy=0.4*' \
    'statsmodels=0.6*' \
    'cloudpickle=0.1*' \
    'dill=0.2*' \
    'numba=0.23*' \
    'bokeh=0.11*' \
    'h5py=2.5*' \
    'pyzmq' \
    && $CONDA_DIR/bin/conda clean -tipsy

# Install Python 2 kernel spec globally to avoid permission problems when NB_UID
# switching at runtime.
$CONDA_DIR/envs/python2/bin/python -m ipykernel install

echo "Configuring Jupyter notebook server for Python 2 and 3..."
setup_jupyter $CONDA_DIR/envs/python2/bin/python "Python 2"
setup_jupyter $CONDA_DIR/bin/python "Python 3"


$CONDA_DIR/envs/python2/bin/pip install \
      --no-cache-dir --upgrade \
      -r /tmp/requirements.txt
$CONDA_DIR/bin/pip install \
      --no-cache-dir --upgrade \
      -r /tmp/requirements.txt
rm /tmp/requirements.txt
