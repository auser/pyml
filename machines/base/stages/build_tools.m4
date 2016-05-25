# Install common utilities
# python-software-properties software-properties-common \
# build-essential curl
RUN apt-get -y update && \
    apt-get install -y -q \
    wget \
    build-essential curl \
    cmake \
    git

RUN locale-gen en_US en_US.UTF-8
RUN dpkg-reconfigure locales


include(`cleanup.m4')
