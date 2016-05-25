RUN apt-get update -yq && apt-get install -yq gfortran
RUN git clone https://github.com/xianyi/OpenBLAS /usr/local/src/OpenBLAS

RUN cd /usr/local/src/OpenBLAS && \
    make FC=gfortran && \
    make PREFIX=/opt/openblas install
