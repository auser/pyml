# Configure environment
ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH
ENV SHELL /bin/bash
ENV USER_LOGIN ${USER_LOGIN:-compute}
ENV USER_UID ${USER_UID:-1000}

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

ENV USER_FULL_NAME "${USER_FULL_NAME:-Compute container user}"
ENV USER_DIR "/home/${USER_LOGIN}"
ENV PASSWORD ${PASSWORD:-itsginger}
ENV PYTHON_ENV ${PYTHON_ENV:-py2}

ENV NOTEBOOK_PORT ${PORT:-8888}

ENV JDIR "${USER_DIR}/.jupyter"
ENV CONF_FILE "${JDIR}/jupyter_notebook_config.py"

# Create ${USER_LOGIN} user with UID=${USER_UID} and in the 'users' group
RUN useradd -m -s /bin/bash -u $USER_UID $USER_LOGIN && \
    mkdir -p $CONDA_DIR && \
    chown $USER_LOGIN $CONDA_DIR

RUN rm /bin/sh && ln -s /bin/bash /bin/sh
