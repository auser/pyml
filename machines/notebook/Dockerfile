# FROM bethgelab/jupyter-torch:cuda7.5-cudnn4
FROM ubuntu:14.04

ENV OPENCV_VERSION 3.1.0
ENV LD_LIBRARY_PATH /usr/local/lib
ENV INSTALL_ROOT /usr/local/src/
ENV OPENCV_ROOT /usr/local/src
ENV OPENCV_HOME $OPENCV_ROOT/opencv

ADD requirements.txt /tmp/requirements.txt

ADD *.sh $INSTALL_ROOT
RUN chmod u+x $INSTALL_ROOT/*.sh

ADD etc/apt/sources.list /etc/apt/
RUN apt-get update -qq

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

# RUN cd /tmp/setup && \
#     chmod u+x /tmp/setup/setup.sh && \
#     /bin/bash ./setup.sh && \
#     rm -r /tmp/setup

EXPOSE 8888
ADD entry.sh /opt/compute-container/entry.sh
RUN chmod u+x /opt/compute-container/entry.sh
CMD /opt/compute-container/entry.sh
