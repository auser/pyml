FROM auser/opencv

## Torch
RUN apt-get update && apt-get -yq --force-yes upgrade
RUN apt-get install -yq build-essential \
	curl git cmake \
	libqt4-core libqt4-gui libqt4-dev \
	libjpeg-dev libpng-dev \
	ncurses-dev imagemagick libgraphicsmagick1-dev \
	libzmq3-dev \
	gfortran unzip \
	gnuplot gnuplot-x11 \
	libsdl2-dev \
	python-software-properties \
  software-properties-common \
	libfftw3-dev sox libsox-dev libsox-fmt-all \
	libopenblas-dev libreadline-dev libssl-dev

#nodejs npm \

RUN source activate py2 && \
    pip install "ipython[notebook]" && \
    source activate py3 && \
    pip install "ipython[notebook]"

# install torch and useful packages
RUN git clone --depth 1 https://github.com/torch/distro.git /usr/local/torch --recursive \
    && git config --global url.https://github.com/.insteadOf git://github.com/ \
    && cd /usr/local/torch && ./install.sh

ENV PATH /usr/local/torch/install/bin:$PATH

RUN ls -l /usr/local/torch/install

RUN source activate py2 \
  && git clone https://github.com/facebook/iTorch.git /usr/local/itorch \
  && cd /usr/local/itorch \
  && luarocks make \
  && cp -r /root/.ipython/* /usr/local/share/jupyter/

## CLEANUP

RUN apt-get -yq clean && apt-get autoclean