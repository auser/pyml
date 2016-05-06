# FROM jupyter/minimal-notebook
FROM auser/cuda

USER root
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

ENV CONDA_DIR /opt/conda
# Configure environment
ENV D_USER compute
ENV D_UID 1000

RUN useradd -m -s /bin/bash -N -u $D_UID $D_USER

# libav-tools for matplotlib anim
RUN apt-get update && \
    apt-get install -y --no-install-recommends libav-tools \
    libhdf5-dev graphviz libhdf5-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
  libglib2.0-0 libxext6 libsm6 libxrender1 \
  git mercurial subversion
RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
  wget --quiet https://repo.continuum.io/miniconda/Miniconda2-4.0.5-Linux-x86_64.sh && \
  /bin/bash /Miniconda2-4.0.5-Linux-x86_64.sh -b -p /opt/conda && \
  rm Miniconda2-4.0.5-Linux-x86_64.sh

RUN apt-get install -y curl grep sed dpkg && \
  TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
  curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
  dpkg -i tini.deb && \
  rm tini.deb && \
  apt-get clean

ENV PATH /opt/conda/bin:$PATH

ENTRYPOINT [ "/usr/bin/tini", "--" ]
USER $D_USER

# Install Python 3 packages
RUN $CONDA_DIR/bin/conda create --quiet --yes -n py3 python=3.4
RUN $CONDA_DIR/bin/conda create --quiet --yes -n py2 python=2.7

RUN source activate py3 && \
  $CONDA_DIR/bin/conda install --yes \
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
    && /opt/conda/bin/conda clean -tipsy

# Install bleeding-edge Theano
# RUN source activate root && \
#     pip install --upgrade --no-deps git+git://github.com/Theano/Theano.git && \
#     # [ Lasagne ]
#     pip install --upgrade https://github.com/Lasagne/Lasagne/archive/master.zip && \
#     # [ Keras ]
#     mkdir -p /tmp && cd /tmp && \
#     git clone https://github.com/fchollet/keras.git
#
# RUN cd /tmp/keras && \
#   source activate root && python setup.py install

# RUN cd /usr/local/src/keras && \
    # source activate python2 && python setup.py install

# Install Python 2 packages

RUN source activate py2 && \
  $CONDA_DIR/bin/conda install --quiet --yes \
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

USER root

# Install Python 2 kernel spec globally to avoid permission problems when NB_UID
# switching at runtime.
RUN source activate py2 && \
    $CONDA_DIR/envs/py2/bin/pip install \
    --no-cache-dir --upgrade \
    -r /tmp/requirements.txt

ADD requirements.txt /tmp/requirements.txt
RUN source activate py2 && \
    $CONDA_DIR/envs/py2/bin/pip install \
      --no-cache-dir --upgrade \
      -r /tmp/requirements.txt
RUN RUN source activate py3 && \
    $CONDA_DIR/bin/pip install \
      --no-cache-dir --upgrade \
      -r /tmp/requirements.txt
RUN rm /tmp/requirements.txt

## CLEAN UP
RUN apt-get clean autoclean -yq && \
    apt-get autoremove -yq && \
    rm -rf /tmp/* /var/tmp/* \
    rm -rf /var/lib/apt/lists/*
## CLEAN UP

USER compute
