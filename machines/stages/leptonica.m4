
#######################
# Leptonica
#######################

RUN apt-get update -qq -y && \
    apt-get install -yq \
    libwebp-dev \
    giflib-tools \
    autoconf automake libtool checkinstall

WORKDIR $INSTALL_ROOT
RUN git clone https://github.com/DanBloomberg/leptonica.git --branch v{{LEPTONICA_VERSION}} --depth 1 && \
    cd leptonica && \
    autoconf && ./configure && \
    make -j {{ NUM_CORES }} && \
    make install && \
    ldconfig

#RUN wget http://www.leptonica.org/source/leptonica-{{LEPTONICA_VERSION}}.tar.gz \
#    -O $INSTALL_ROOT/leptonica.tar.gz && \
#    tar -zxvf leptonica.tar.gz && \
#    rm -rf leptonica.tar.gz && \
#    cd leptonica-{{LEPTONICA_VERSION}} && \
#    ./configure && \
#    make -j {{ NUM_CORES }} && \
#    make install && \
#    ldconfig

#######################
# End Leptonica
#######################
