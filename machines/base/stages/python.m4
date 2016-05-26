RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
  libglib2.0-0 libxext6 libsm6 libxrender1 \
  git mercurial subversion
RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
  wget --quiet https://repo.continuum.io/miniconda/Miniconda2-4.0.5-Linux-x86_64.sh && \
  /bin/bash /Miniconda2-4.0.5-Linux-x86_64.sh -f -b -p /opt/conda && \
  rm Miniconda2-4.0.5-Linux-x86_64.sh

RUN apt-get install -y curl grep sed dpkg && \
  TINI_VERSION=$(curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:') && \
  curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
  dpkg -i tini.deb && \
  rm tini.deb && \
  apt-get clean

ENV PATH /opt/conda/bin:$PATH

ENTRYPOINT [ "/usr/bin/tini", "--" ]z
ENV PATH $CONDA_DIR/bin:$PATH

# libav-tools for matplotlib anim
RUN apt-get update -qq && \
    apt-get install -qy --no-install-recommends --force-yes \
      libav-tools \
      libhdf5-dev graphviz libhdf5-dev \
      libfreetype6-dev libpng12-dev \
      pkg-config build-essential cmake git \
      libx11-dev \
      unzip; \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Python 3 packages
RUN $CONDA_DIR/bin/conda create --quiet --yes -n py3 python=3.4
RUN $CONDA_DIR/bin/conda create --quiet --yes -n py2 python=2.7

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

COPY requirements.txt /tmp/requirements.txt
RUN source activate py2 && \
    $CONDA_DIR/bin/conda install --yes \
    'cython=0.23*' \
    'numpy' \
    'statsmodels' && \
    pip install --upgrade ipykernel jupyter notebook && \
    pip install --upgrade -r /tmp/requirements.txt

RUN source activate py3 && \
    $CONDA_DIR/bin/conda install --yes \
    'cython=0.23*' \
    'numpy' \
    'statsmodels' && \
    pip install --upgrade ipykernel jupyter notebook && \
    pip install --upgrade -r /tmp/requirements.txt

RUN cp -r $HOME/.conda /etc/skel/.conda
