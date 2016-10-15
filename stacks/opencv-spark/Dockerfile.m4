include(`macros.m4')DONT_CHANGE(__file__)
FROM auser/torch

COPY requirements.txt /tmp/requirements.txt

RUN source activate py2 && \
  pip install -r /tmp/requirements.txt && \
  jupyter nbextension enable --py --sys-prefix widgetsnbextension

RUN source activate py3 && \
  pip install -r /tmp/requirements.txt && \
  jupyter nbextension enable --py --sys-prefix widgetsnbextension

RUN rm /tmp/requirements.txt

USER root

include(`java.m4')
include(`spark.m4')