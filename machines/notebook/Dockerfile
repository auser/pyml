FROM auser/python23

EXPOSE 8888
COPY entry.sh /opt/compute-container/entry.sh
RUN chmod +x /opt/compute-container/entry.sh
WORKDIR /opt/compute-container

RUN source activate py2 && pip install notebook --upgrade && \
    source activate py3 && pip install notebook --upgrade

ENTRYPOINT ["tini", "--"]
CMD ["/opt/compute-container/entry.sh", "/tmp/build-env"]