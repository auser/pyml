FROM bethgelab/jupyter-torch:cuda7.0-cudnn4

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

ENV OPENCV_VERSION 2.4.12.3

ENV WORKON_HOME "~/.virtualenvs"
ENV LD_LIBRARY_PATH /usr/local/lib

RUN apt-get update -yq
RUN apt-get -y dist-upgrade

# Install git, bc and dependencies
RUN apt-get install -y \
  git \
  bc \
  cmake \
  libgflags-dev \
  libavcodec-dev \
  libjpeg8-dev libtiff4-dev libjasper-dev libpng12-dev \
  libavformat-dev \
  libswscale-dev libv4l-dev \
  libgoogle-glog-dev \
  libopencv-dev \
  libleveldb-dev \
  libsnappy-dev \
  liblmdb-dev \
  libgtk2.0-dev \
  libhdf5-serial-dev \
  libprotobuf-dev \
  protobuf-compiler \
  libatlas-base-dev \
  gfortran

# Install boost
RUN apt-get install -y --no-install-recommends libboost-all-dev

# Install build-essential, git, python-dev, pip and other dependencies
RUN apt-get install -y \
  build-essential \
  cmake \
  git \
  python-dev \
  libopenblas-dev \
  python-pip \
  python-nose \
  python-numpy \
  python-scipy \
  python-opencv \
  python3.4-dev


RUN  curl -sL -o /tmp/build.sh "https://raw.githubusercontent.com/siomiz/node-opencv/master/build.sh"

RUN bash /tmp/build.sh \
	&& rm /tmp/build.sh


RUN pip install virtualenv virtualenvwrapper
RUN  mkdir ~/.virtualenvs && \
     echo ". /usr/local/bin/virtualenvwrapper.sh" >> ~/.bashrc

RUN pip install numpy scipy scikit-learn nolearn keras
RUN pip install cv2 pyopencv

VOLUME /home/compute

ENV USER_GID compute-users
RUN addgroup $USER_GID

ADD entry.sh /opt/compute-container/entry.sh
RUN chmod u+x /opt/compute-container/entry.sh
CMD /opt/compute-container/entry.sh
