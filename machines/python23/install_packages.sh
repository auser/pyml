#!/usr/bin/env bash

set -xe

apt-get -yq update
# apt-get build-dep -y python3-matplotlib python3-h5py

# Reduce the image size
apt-get autoremove -y
apt-get clean -y

rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ls -l /opt/conda/envs
for PYTHONVER in 2 3 ; do
  PYTHON="python$PYTHONVER"
  PIP="pip$PYTHONVER"

  # The rest of the SciPy Stack
  $PIP install --no-cache-dir pandas scikit-learn
  $PIP install --no-cache-dir matplotlib
  $PIP install --no-cache-dir seaborn
  $PIP install --no-cache-dir h5py
  $PIP install --no-cache-dir yt
  $PIP install --no-cache-dir sympy
  $PIP install --no-cache-dir patsy
  $PIP install --no-cache-dir ggplot
  $PIP install --no-cache-dir statsmodels
  $PIP install --no-cache-dir git+https://github.com/Theano/Theano.git
  $PIP install --no-cache-dir git+https://github.com/Lasagne/Lasagne.git
  $PIP install --no-cache-dir git+https://github.com/fchollet/keras.git
  $PIP install --no-cache-dir https://github.com/Lasagne/Lasagne/archive/master.zip
  $PIP install --no-cache-dir bokeh
  $PIP install --no-cache-dir mock
  $PIP install --no-cache-dir pytest
done
