FROM bethgelab/jupyter-torch:cuda7.0-cudnn4

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

ENV OPENCV_VERSION 2.4.12.3
ENV SPARK_VERSION "1.6.0"
ENV SPARK_HOME "/usr/local/spark"

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

## Install OpenCV
RUN git clone https://github.com/itseez/opencv.git /usr/local/src/opencv

WORKDIR /usr/local/src/opencv

RUN git clone https://github.com/Itseez/opencv_contrib.git /usr/local/src/opencv_contrib

RUN git checkout "$OPENCV_VERSION" \
	  && mkdir release

RUN cd /usr/local/src/opencv/release && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
	    -D CMAKE_INSTALL_PREFIX=/usr/local \
	    -D INSTALL_PYTHON_EXAMPLES=ON \
      -D OPENCV_EXTRA_MODULES_PATH=/usr/local/src/opencv_contrib \
	    -D BUILD_EXAMPLES=OFF \
      -D INSTALL_C_EXAMPLES=OFF \
      -D WITH_IPP=ON \
      -D INSTALL_PYTHON_EXAMPLES=ON \
      ..

RUN cd /usr/local/src/opencv/release && \
      make -j4 && \
      make install && \
      ldconfig

RUN rm -rf /usr/local/src/opencv \
  	  && apt-get purge -y cmake \
  	  && apt-get autoremove -y --purge

# ADD ./build_opencv.sh /tmp/build.sh
# RUN bash /tmp/build.sh \
# 	&& rm /tmp/build.sh


# Install bleeding-edge Theano
RUN pip install --upgrade --no-deps git+git://github.com/Theano/Theano.git

# [ Lasagne ]

# Install bleeding-edge Lasagne
RUN pip install --upgrade https://github.com/Lasagne/Lasagne/archive/master.zip

# [ Keras ]

# Install dependencies
RUN apt-get install -y \
  libhdf5-dev \
  python-h5py \
  python-yaml

# Upgrade six
RUN pip install --upgrade six

# Clone Keras repo and move into it
RUN cd /usr/local && git clone https://github.com/fchollet/keras.git && cd keras && \
  # Install
  python setup.py install


WORKDIR /usr/local/
# PySpark
# Spark dependencies
ENV APACHE_SPARK_VERSION 1.6.0
# RUN apt-get update && \
#     apt-get install -y --no-install-recommends openjdk-7-jre-headless && \
#     apt-get clean
# RUN wget -qO - http://d3kbcqa49mib13.cloudfront.net/spark-${APACHE_SPARK_VERSION}-bin-hadoop2.6.tgz | tar -xz -C /usr/local/ && \
#     cd /usr/local && \
#     ln -s spark-${APACHE_SPARK_VERSION}-bin-hadoop2.6 spark

# # Scala Spark kernel (build and cleanup)
# RUN cd /tmp && \
#     echo deb http://dl.bintray.com/sbt/debian / > /etc/apt/sources.list.d/sbt.list && \
#     apt-get update && \
#     git clone https://github.com/ibm-et/spark-kernel.git && \
#     apt-get install -yq --force-yes --no-install-recommends sbt

# RUN cd /tmp/spark-kernel && \
#     sbt compile -Xms1024M \
#         -Xmx2048M \
#         -Xss1M \
#         -XX:+CMSClassUnloadingEnabled \
#         -XX:MaxPermSize=1024M

# RUN cd /tmp/spark-kernel && \
#     sbt assembly && \
#     mv kernel/target/pack /opt/sparkkernel && \
#     chmod +x /opt/sparkkernel && \
#     rm -rf ~/.ivy2 && \
#     rm -rf ~/.sbt && \
#     rm -rf /tmp/spark-kernel && \
#     apt-get remove -y sbt && \
#     apt-get clean

## Java
RUN apt-get install -yq python-software-properties
RUN apt-get install -yq default-jdk
# RUN apt-add-repository ppa:webupd8team/java
# RUN apt-get update -yq
# RUN apt-get install -yq --no-install-recommends oracle-java7-installer
#
# Scala
RUN wget http://www.scala-lang.org/files/archive/scala-2.11.8.deb
RUN dpkg -i scala-2.11.8.deb
## Py4J
RUN pip install py4j
WORKDIR /usr/local
# ## Spark
RUN curl -sL -o "/usr/local/spark-$APACHE_SPARK_VERSION.tgz" "http://d3kbcqa49mib13.cloudfront.net/spark-$APACHE_SPARK_VERSION.tgz"

RUN tar xvf "spark-$APACHE_SPARK_VERSION.tgz" && \
    mv "/usr/local/spark-$APACHE_SPARK_VERSION" "$SPARK_HOME"

RUN cd "$SPARK_HOME" && build/sbt assembly

ADD requirements.txt /tmp/requirements.txt

RUN pip2 install --no-cache-dir -r /tmp/requirements.txt
RUN pip3 install --no-cache-dir -r /tmp/requirements.txt

RUN rm /tmp/requirements.txt
# Julia
# Julia dependencies
# RUN apt-get update &&  \
#     apt-get install -y julia libnettle4 && \
#     apt-get clean

# IJulia and Julia packages
# RUN julia -e 'Pkg.add("IJulia")'
# RUN julia -e 'Pkg.add("Gadfly")' && julia -e 'Pkg.add("RDatasets")'

# Extra Kernels
# RUN pip install --user --no-cache-dir ipyparallel && \
#     ipcluster nbextension enable

VOLUME /home/compute

ENV USER_GID compute-users
RUN addgroup $USER_GID
ENV PYTHONPATH "$SPARK_HOME/python:${PYTHONPATH}"

ADD entry.sh /opt/compute-container/entry.sh
RUN chmod u+x /opt/compute-container/entry.sh
CMD /opt/compute-container/entry.sh
