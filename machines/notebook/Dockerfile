FROM bethgelab/jupyter-torch:cuda7.5-cudnn4
# FROM ubuntu:14.04
# FROM auser/torch

ENV OPENCV_VERSION 3.1.0

ADD etc/apt/sources.list /etc/apt/
RUN apt-get update -qq
RUN apt-get install -yq \
    mktemp

# Copy local configuration & fix perms
ADD system-conf /
RUN chown -R root:root /etc/sudoers.d && chmod 0440 /etc/sudoers.d/*
RUN addgroup compute-users

USER compute
ADD setup /tmp/setup
RUN cd /tmp/setup && \
    /bin/bash ./setup.sh

USER root
RUN rm -r /tmp/setup

EXPOSE 8888
ADD entry.sh /opt/compute-container/entry.sh
RUN chmod +x /opt/compute-container/entry.sh
CMD /opt/compute-container/entry.sh
USER compute
