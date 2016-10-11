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

ENV USER_UID ${USER_UID:-1001}
ENV USER_LOGIN ${USER:-jovyan}
ENV USER_FULL_NAME "${USER_FULL_NAME:-Compute container user}"
ENV USER_DIR "/home/${USER_LOGIN}"
ENV PASSWORD ${PASSWORD:-itsginger}
ENV PYTHON_ENV ${PYTHON_ENV:-py2}

ENV NOTEBOOK_PORT ${PORT:-8888}

ENV JDIR "${USER_DIR}/.jupyter"
ENV CONF_FILE "${JDIR}/jupyter_notebook_config.py"

include(`torch.m4')
include(`tensorflow.m4')

EXPOSE 8888
COPY entry.sh /opt/compute-container/entry.sh
RUN chmod +x /opt/compute-container/entry.sh
WORKDIR /opt/compute-container

RUN source activate py2 && pip install notebook --upgrade && \
    source activate py3 && pip install notebook --upgrade

ENTRYPOINT ["tini", "--"]
CMD ["/opt/compute-container/entry.sh", "/tmp/build-env"]
