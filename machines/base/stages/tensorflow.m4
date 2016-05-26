ENV TENSORFLOW_VERSION 0.8.0
ENV TENSORFLOW_ARCH gpu

 RUN source activate py2 && \
      pip --no-cache-dir install --ignore-installed --upgrade \
      https://storage.googleapis.com/tensorflow/linux/${TENSORFLOW_ARCH}/tensorflow-${TENSORFLOW_VERSION}-cp27-none-linux_x86_64.whl


RUN source activate py3 && \
      pip install --ignore-installed --upgrade https://storage.googleapis.com/tensorflow/linux/${TENSORFLOW_ARCH}/tensorflow-${TENSORFLOW_VERSION}-cp34-cp34m-linux_x86_64.whl
