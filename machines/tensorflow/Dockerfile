FROM auser/opencv

USER root
# [ TensorFlow ]
RUN apt-get update && apt-get install -y \
  curl \
  libfreetype6-dev \
  libpng12-dev \
  libzmq3-dev \
  pkg-config

RUN /opt/conda/envs/python2/bin/pip install --upgrade pip
RUN /opt/conda/envs/python2/bin/pip install --upgrade --ignore-installed \
    https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-0.8.0-cp27-none-linux_x86_64.whl

RUN /opt/conda/bin/pip install --upgrade pip
RUN /opt/conda/bin/pip install --upgrade --ignore-installed \
    https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-0.8.0-cp34-cp34m-linux_x86_64.whl
    # https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-0.8.0rc0-cp34-cp34m-linux_x86_64.whl
    # https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.8.0-cp34-cp34m-linux_x86_64.whl

# RUN pip2 install --upgrade \
#     https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-0.8.0rc0-cp27-none-linux_x86_64.whl
#
# RUN pip3 install --upgrade \
#     https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-0.8.0rc0-cp34-cp34m-linux_x86_64.whl
RUN ldconfig /usr/local/cuda/lib64
USER jovyan
