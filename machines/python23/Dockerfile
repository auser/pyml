FROM jupyter/scipy-notebook

USER root

RUN apt-get update && apt-get install -y \
  build-essential \
  wget module-init-tools

# Change to the /tmp directory
RUN cd /tmp && \
# Download run file
  wget http://developer.download.nvidia.com/compute/cuda/7.5/Prod/local_installers/cuda_7.5.18_linux.run && \
# Make the run file executable and extract
  chmod +x cuda_*_linux.run && ./cuda_*_linux.run -extract=`pwd` && \
# Install CUDA drivers (silent, no kernel)
  ./NVIDIA-Linux-x86_64-*.run -s --no-kernel-module && \
# Install toolkit (silent)
  ./cuda-linux64-rel-*.run -noprompt && \
# Clean up
  rm -rf *

# Add to path
ENV PATH=/usr/local/cuda/bin:$PATH \
  LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

RUN apt-get update -yq
# Install dependencies
RUN apt-get install -y \
  libhdf5-dev \
  python-h5py \
  python-yaml \
  cython
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install bleeding-edge Theano
RUN pip install --upgrade --no-deps git+git://github.com/Theano/Theano.git

# [ Lasagne ]

# Install bleeding-edge Lasagne
RUN pip install --upgrade https://github.com/Lasagne/Lasagne/archive/master.zip

# [ Keras ]

# Clone Keras repo and move into it
RUN cd /usr/local && \
    git clone https://github.com/fchollet/keras.git

RUN cd /usr/local/keras && source activate python2 && python setup.py install
RUN cd /usr/local/keras && source activate root && python setup.py install

WORKDIR /usr/local/

# [ python deps ]

ADD requirements.txt /tmp/requirements.txt

# RUN source activate python2 && \
#     conda install -f conda-env && \
#     conda install -c https://conda.anaconda.org/anaconda setuptools && \
#     pip install --upgrade --no-cache-dir -r /tmp/requirements.txt

# RUN source activate root && \
#     conda install -c https://conda.anaconda.org/anaconda setuptools pip && \
#     pip install --upgrade --no-cache-dir -r /tmp/requirements.txt

# Install Python 3 packages
RUN which python && python --version
RUN conda update --all python=3.4
RUN conda create -n python3 --quiet --yes python=3.4
ENV PATH "$CONDA_DIR/envs/python3.4/bin:$PATH"
RUN which python && python --version
RUN echo $PATH
RUN conda install --quiet --yes --file /tmp/requirements.txt && \
    conda clean -tipsy

RUN conda install --quiet --force --yes -p $CONDA_DIR/envs/python2 python=2.7 \
    --file /tmp/requirements.txt && \
    conda clean -tipsy

# Install Python 2 kernel spec globally to avoid permission problems when NB_UID
# switching at runtime.
RUN $CONDA_DIR/envs/python2/bin/python -m ipykernel install


RUN rm /tmp/requirements.txt

USER jovyan
