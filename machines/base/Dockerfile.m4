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

USER {{ NB_USER }}

EXPOSE 8888
COPY entry.sh /opt/compute-container/entry.sh
RUN chmod +x /opt/compute-container/entry.sh
CMD ["/opt/compute-container/entry.sh"]
