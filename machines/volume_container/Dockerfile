FROM ubuntu

RUN apt-get update -yq && \
    apt-get install -yq \
      automake autotools-dev g++ git \
      libcurl4-gnutls-dev libfuse-dev libssl-dev \
      libxml2-dev make pkg-config \
    && rm -rf /var/cache/apk/*

RUN mkdir -p /root
WORKDIR /root

RUN git clone --depth 1 https://github.com/s3fs-fuse/s3fs-fuse.git
WORKDIR /root/s3fs-fuse

RUN ./autogen.sh && \
    ./configure --prefix=/usr --with-openssl && \
    make && \
    make install

RUN mkdir -p /mnt/mountpoint
RUN echo $'#!/bin/sh\n \
           echo $S3User:$S3Secret > /etc/passwd-s3fs\n \
           chmod 600 /etc/passwd-s3fs\n \
           exec s3fs "$@"' > /root/s3fs.sh
RUN chmod +x /root/s3fs.sh

ENV S3User $S3User
ENV S3Secret $S3Secret

ENTRYPOINT ["/root/s3fs.sh"]
