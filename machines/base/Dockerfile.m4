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

EXPOSE 8888
COPY entry.sh /opt/compute-container/entry.sh
RUN chmod +x /opt/compute-container/entry.sh
WORKDIR /opt/compute-container

RUN source activate py2 && \
    pip install notebook --upgrade

RUN cp -r $HOME/.local/ ~{{ NB_USER }}/.local && \
    chown -R {{ NB_USER }}:users ~{{ NB_USER }}/.local

ENV USER {{ NB_USER }}
ENV USER_UID {{ NB_UID }}
ENV PATH $PATH:~/.local/bin

CMD ["/opt/compute-container/entry.sh"]
