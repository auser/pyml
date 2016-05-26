include(`macros.m4')DONT_CHANGE(__file__)

# FROM ubuntu:trusty
FROM nvidia/cuda:7.5-cudnn4-devel

ENV DEBIAN_FRONTEND noninteractive
ENV INSTALL_ROOT /usr/local/src
ENV CONDA_DIR /opt/conda

COPY system-conf /

include(`build_tools.m4')
include(`create_user.m4')
include(`python.m4')

include(`openblas.m4')

# include(`cuda.m4')

include(`leptonica.m4')
include(`tesseract.m4')
include(`ffmpeg.m4')

include(`opencv.m4')

include(`torch.m4')
include(`tensorflow.m4')

EXPOSE 8888
COPY entry.sh /opt/compute-container/entry.sh
RUN chmod +x /opt/compute-container/entry.sh
WORKDIR /opt/compute-container

RUN source activate py2 && pip install notebook --upgrade && \
    source activate py3 && pip install notebook --upgrade

ENV USER {{ NB_USER }}
ENV USER_UID {{ NB_UID }}
ENV PATH $PATH:~/.local/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:${PY2_DIR}/lib:${PY3_DIR}/lib:/usr/local/cuda/lib:/usr/local/cuda/lib64

CMD ["/opt/compute-container/entry.sh"]
