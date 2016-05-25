#######################
# Tesseract
#######################

WORKDIR $INSTALL_ROOT/
RUN wget https://github.com/tesseract-ocr/tesseract/archive/{{ TESSERACT_VERSION }}.tar.gz \
      -O $INSTALL_ROOT/tesseract.tar.gz
RUN tar -zxvf $INSTALL_ROOT/tesseract.tar.gz && \
    rm -rf tesseract.tar.gz && \
    cd tesseract-{{ TESSERACT_VERSION }} && \
    ls -la && \
    /bin/bash ./autogen.sh && \
    ./configure && \
    LDFLAGS="-L/usr/local/lib" CFLAGS="-I/usr/local/include" make -j ${NUM_CORES} && \
    make install && \
    ldconfig

#######################
# End Tesseract
#######################
