# FROM bethgelab/jupyter-torch:cuda7.5-cudnn4
# FROM ubuntu:14.04
FROM auser/torch

ENV OPENCV_VERSION 3.1.0
ENV LD_LIBRARY_PATH /usr/local/lib
ENV INSTALL_ROOT /usr/local/src/
ENV OPENCV_ROOT /usr/local/src
ENV OPENCV_HOME $OPENCV_ROOT/opencv
ENV USER_LOGIN compute
ENV CONDA_DIR /opt/conda

ADD requirements.txt /tmp/requirements.txt

ADD *.sh $INSTALL_ROOT
RUN chmod u+x $INSTALL_ROOT/*.sh

ADD etc/apt/sources.list /etc/apt/
RUN apt-get update -qq

RUN apt-get install -yq \
    mktemp

# Copy local configuration & fix perms
ADD system-conf /
RUN chown -R root:root /etc/sudoers.d && chmod 0440 /etc/sudoers.d/*
RUN addgroup compute-users

# Run any system setup
# ADD setup /tmp/setup
# RUN /bin/bash /tmp/setup/build_cuda.sh
#
# RUN /bin/bash /tmp/setup/build_python.sh
# RUN /bin/bash /tmp/setup/build_spark.sh
# RUN /bin/bash /tmp/setup/build_torch.sh
# RUN /bin/bash /tmp/setup/build_opencv.sh
# RUN /bin/bash /tmp/setup/build_tensorflow.sh

# RUN chown -R compute $CONDA_DIR/

# RUN $CONDA_DIR/bin/conda create -n py3 --clone root 
# RUN $CONDA_DIR/bin/conda create -n py2 --clone python2

ADD setup /tmp/setup
RUN cd /tmp/setup && \
    /bin/bash ./setup.sh && \
    rm -r /tmp/setup

EXPOSE 8888
ADD entry.sh /opt/compute-container/entry.sh
RUN chmod +x /opt/compute-container/entry.sh
CMD /opt/compute-container/entry.sh
