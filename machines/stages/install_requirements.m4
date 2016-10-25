COPY requirements.txt /tmp/requirements.txt

RUN source activate py2 && \
  pip install -r /tmp/requirements.txt && \
  jupyter nbextension enable --py --sys-prefix widgetsnbextension && \
  conda install -c damianavila82 rise && \
  jupyter-nbextension install rise --py && \
  jupyter nbextension enable rise --py

RUN source activate py3 && \
  pip install -r /tmp/requirements.txt && \
  jupyter nbextension enable --py --sys-prefix widgetsnbextension && \
  conda install -c damianavila82 rise && \
  jupyter-nbextension install rise --py && \
  jupyter nbextension enable rise --py

RUN rm /tmp/requirements.txt
