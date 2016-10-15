FROM auser/torch

COPY requirements.txt /tmp/requirements.txt

RUN source activate py2 && \
	pip install -r /tmp/requirements.txt && \
	jupyter nbextension enable --py --sys-prefix widgetsnbextension

RUN source activate py3 && \
	pip install -r /tmp/requirements.txt && \
	jupyter nbextension enable --py --sys-prefix widgetsnbextension

RUN rm /tmp/requirements.txt
