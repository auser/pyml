# FROM bethgelab/jupyter-torch:cuda7.5-cudnn4
FROM auser/torch

# ENV LANG=en_US.UTF-8
# ENV LANGUAGE=en_US.UTF-8
# ENV LC_ALL=en_US.UTF-8
#
# #2.4.12.3
# ENV OPENCV_VERSION 3.1.0
# ENV SPARK_VERSION "1.6.0"
# ENV SPARK_HOME "/usr/local/spark"
#
ENV PATH=/usr/local/cuda/bin:$PATH \
  LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

USER root
# RUN apt-get update -yq
# RUN apt-get -yq dist-upgrade
#
# # Install git, bc and dependencies
# RUN apt-get install -yq \
#   git \
#   bc \
#   cmake \
#   libgflags-dev \
#   libavcodec-dev \
#   libjpeg-dev libpng-dev libtiff-dev libjasper-dev \
#   libavformat-dev \
#   libswscale-dev \
#   libv4l-dev \
#   libgoogle-glog-dev \
#   libopencv-dev \
#   libleveldb-dev \
#   libsnappy-dev \
#   liblmdb-dev \
#   libgtk2.0-dev \
#   libhdf5-serial-dev \
#   libprotobuf-dev \
#   protobuf-compiler \
#   libatlas-base-dev \
#   gfortran
#
# # Install boost
# RUN apt-get install -y --no-install-recommends libboost-all-dev
#
# # Install build-essential, git, python-dev, pip and other dependencies
# RUN apt-get install -y \
#   build-essential \
#   checkinstall \
#   cmake \
#   pkg-config yasm \
#   git \
#   python-dev \
#   libopenblas-dev \
#   python-pip \
#   python-nose \
#   python-numpy \
#   python-scipy \
#   python-opencv \
#   python-tk \
#   python2.7-dev \
#   python3-dev \
#   python3-tk \
#   python3-numpy
#
# # [ Spark ]
# # Spark dependencies
#
# ## Java
# RUN apt-get install -yq python-software-properties
# RUN apt-get install -yq default-jdk ant
# # RUN apt-add-repository ppa:webupd8team/java
# # RUN apt-get update -yq
# # RUN apt-get install -yq --no-install-recommends oracle-java7-installer
# #
# # Scala
# RUN wget http://www.scala-lang.org/files/archive/scala-2.11.8.deb
# RUN dpkg -i scala-2.11.8.deb
# ## Py4J
# RUN pip install py4j
# WORKDIR /usr/local
# # ## Spark
# RUN curl -sL -o "/usr/local/spark-$SPARK_VERSION.tgz" "http://d3kbcqa49mib13.cloudfront.net/spark-$SPARK_VERSION.tgz"
#
# RUN tar xvf "spark-$SPARK_VERSION.tgz" && \
#     mv "/usr/local/spark-$SPARK_VERSION" "$SPARK_HOME"
#
# RUN cd "$SPARK_HOME" && build/sbt assembly
#
# # [ OpenCV ]
#
# # GUI:
# RUN apt-get install -yq qt5-default libvtk6-dev
#
# # Media I/O:
# RUN apt-get install -yq zlib1g-dev \
#             libjpeg-dev \
#             libwebp-dev \
#             libpng-dev \
#             libtiff5-dev \
#             libjasper-dev \
#             libopenexr-dev \
#             libgdal-dev
#
# # Video I/O:
# RUN apt-get install -yq libdc1394-22-dev \
#             libavcodec-dev libavformat-dev \
#             libswscale-dev libtheora-dev \
#             libvorbis-dev libxvidcore-dev \
#             libx264-dev yasm \
#             libopencore-amrnb-dev \
#             libopencore-amrwb-dev libv4l-dev libxine2-dev
#
# # Parallelism and linear algebra libraries:
# RUN apt-get install -yq \
#     libtbb-dev \
#     libeigen3-dev \
#     libtesseract-dev
#
# RUN apt-get clean -yq
#
# WORKDIR /usr/local/src/opencv
# RUN git clone https://github.com/itseez/opencv.git /usr/local/src/opencv
# RUN git clone https://github.com/Itseez/opencv_contrib.git /usr/local/src/opencv_contrib
# RUN git checkout "$OPENCV_VERSION" && mkdir release
#
# ENV PYTHONPATH="/usr/local/lib/python2.7/site-packages:$PYTHONPATH"
# ENV PYTHONPATH="/usr/local/lib/python3.4/site-packages:$PYTHONPATH"
#
# ENV CUDA_LIB_PATH=/usr/local/cuda/lib64/stubs/
#
# RUN cd /usr/local/src/opencv/release && \
#     cmake -G "Unix Makefiles" \
#     -D OPENCV_EXTRA_MODULES_PATH=/usr/local/src/opencv_contrib/modules \
#     -D CMAKE_BUILD_TYPE=RELEASE \
#     -D CMAKE_INSTALL_PREFIX=/usr/local \
#     -D WITH_TBB=ON \
#     -D WITH_V4L=ON \
#     -D INSTALL_C_EXAMPLES=ON \
#     -D BUILD_EXAMPLES=ON \
#     -D INSTALL_PYTHON_EXAMPLES=ON \
#     -D BUILD_opencv_python2=ON \
#     -D BUILD_opencv_python3=ON \
#     -D WITH_QT=ON \
#     -D WITH_GDAL=ON \
#     -D WITH_XINE=ON \
#     -D WITH_OPENGL=ON \
#     -D ENABLE_FAST_MATH=ON \
#     -D BUILD_SHARED_LIBS=ON \
#     -D INSTALL_TESTS=OFF \
#     -D WITH_GSTREAMER=ON ..
#     # -D FORCE_VTK=ON \
#     # -D INSTALL_CREATE_DISTRIB=ON \
#     # -D INSTALL_TO_MANGLED_PATHS=ON \
#     # -D BUILD_NEW_PYTHON_SUPPORT=ON \
#     # -D CUDA_GENERATION=Kepler \
#     # -D WITH_IMAGEIO=ON \
#
# # /usr/local/lib/python2.7/
# # /usr/local/lib/python3.4/
#
#
# RUN cd /usr/local/src/opencv/release && \
#       make all -j4 && \
#       make install && \
#       ldconfig

RUN apt-get purge -yq cmake && apt-get autoremove -yq --purge
#
# # Install bleeding-edge Theano
# # RUN pip install --upgrade --no-deps git+git://github.com/Theano/Theano.git
# RUN /opt/conda/envs/python2/bin/pip install --upgrade --no-deps \
#     git+git://github.com/Theano/Theano.git
# RUN /opt/conda/bin/pip install --upgrade --no-deps \
#     git+git://github.com/Theano/Theano.git
# # RUN /opt/conda/envs/python2/bin/pip install --upgrade --no-deps git+git://github.com/Theano/Theano.git
# # RUN /opt/conda/bin/pip install --upgrade --no-deps git+git://github.com/Theano/Theano.git
#
# # [ Lasagne ]
#
# # Install bleeding-edge Lasagne
# # RUN pip install --upgrade https://github.com/Lasagne/Lasagne/archive/master.zip
# RUN /opt/conda/envs/python2/bin/pip install --upgrade --no-deps \
#     https://github.com/Lasagne/Lasagne/archive/master.zip
# RUN /opt/conda/bin/pip install --upgrade --no-deps \
#     https://github.com/Lasagne/Lasagne/archive/master.zip
#
# # [ Keras ]
#
# # Install dependencies
# RUN apt-get install -y \
#   libhdf5-dev \
#   python-h5py \
#   python-yaml
#
# # Clone Keras repo and move into it
# RUN cd /usr/local && \
#     git clone https://github.com/fchollet/keras.git
#
# RUN cd /usr/local/keras && python2 setup.py install
# RUN cd /usr/local/keras && python3 setup.py install
#
# WORKDIR /usr/local/

# [ TensorFlow ]
#
# RUN apt-get update && apt-get install -y \
#   curl \
#   libfreetype6-dev \
#   libpng12-dev \
#   libzmq3-dev \
#   pkg-config
#
# RUN /opt/conda/envs/python2/bin/pip install --upgrade pip
# RUN /opt/conda/envs/python2/bin/pip install --upgrade --no-deps \
#     https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-0.8.0-cp27-none-linux_x86_64.whl
#
# RUN ls /opt/conda/envs/tensorflow
# RUN /opt/conda/envs/python3.4/bin/pip install --upgrade pip
# RUN /opt/conda/envs/python3.4/bin/pip install --upgrade --no-cache-dir \
#     https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-0.8.0-cp34-cp34m-linux_x86_64.whl
    # https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-0.8.0rc0-cp34-cp34m-linux_x86_64.whl
    # https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.8.0-cp34-cp34m-linux_x86_64.whl

# RUN pip2 install --upgrade \
#     https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-0.8.0rc0-cp27-none-linux_x86_64.whl
#
# RUN pip3 install --upgrade \
#     https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-0.8.0rc0-cp34-cp34m-linux_x86_64.whl

# [ python deps ]

# ADD requirements.txt /tmp/requirements.txt
#
# RUN /opt/conda/envs/python2/bin/pip install --upgrade --no-deps \
#     -r /tmp/requirements.txt
# RUN /opt/conda/bin/pip install --upgrade --no-deps \
#     -r /tmp/requirements.txt
# # RUN pip2 install --upgrade --no-cache-dir -r /tmp/requirements.txt
# # RUN pip3 install --upgrade --no-cache-dir -r /tmp/requirements.txt
#
# RUN rm /tmp/requirements.txt

# RUN ln -s /usr/lib/python2.7/dist-packages/cv2.so /usr/lib/python3/dist-packages/cv2.so
# RUN ln -s /usr/lib/python2.7/dist-packages/cv2.py /usr/lib/python3/dist-packages/cv2.py
# RUN ln -s /usr/lib/python2.7/dist-packages/cv2.pyc /usr/lib/python3/dist-packages/cv2.pyc
# RUN ls -l /usr/lib/python3/dist-packages

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

# RUN mkdir -p /usr/lib/python3/site-packages/
RUN find /usr/local -name "cv2.so"
RUN ls -l /usr/local/src/opencv/release/lib/
RUN ls -l /usr/local/src/opencv/release/lib/python3
RUN ln -s /usr/local/src/opencv/release/lib/cv2.* /usr/lib/python3/dist-packages/
RUN ln -s /usr/local/src/opencv/release/lib/python3/cv2.* /usr/lib/python3/dist-packages/
RUN ls -l /usr/lib/python3/dist-packages

VOLUME /home/compute

ENV USER_UID 1000
ENV USER_GID compute-users
RUN addgroup $USER_GID
ENV PYTHONPATH "$SPARK_HOME/python:${PYTHONPATH}"

RUN mkdir -p /opt/compute-container
ADD entry.sh /opt/compute-container/entry.sh
RUN chmod u+x /opt/compute-container/entry.sh
RUN chown -R $NB_USER /opt/compute-container/

# # USER jovyan
# CMD /opt/compute-container/entry.sh

## CLEAN UP
RUN AUTO_ADDED_PACKAGES=`apt-mark showauto`
RUN apt-get remove --purge -y $BUILD_PACKAGES $AUTO_ADDED_PACKAGES
RUN rm -rf /tmp/* /var/tmp/*

RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*
## CLEAN UP

# Configure container startup as root
EXPOSE 8888
WORKDIR /home/$NB_USER/work
ENTRYPOINT ["tini", "--"]
# CMD ["/usr/local/bin/start-notebook.sh"]
CMD ["/opt/compute-container/entry.sh"]

# Add local files as late as possible to avoid cache busting
# Start notebook server
# COPY start-notebook.sh /usr/local/bin/
# Start single-user notebook server for use with JupyterHub
# COPY start-singleuser.sh /usr/local/bin/
# COPY jupyter_notebook_config.py /home/$NB_USER/.jupyter/
RUN chown -R $NB_USER:users /home/$NB_USER/.jupyter

# Switch back to jovyan to avoid accidental container runs as root
# USER jovyan
