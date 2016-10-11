# Copy local configuration & fix perms
COPY system-conf /
# RUN chown -R root:root /etc/sudoers.d && chmod 0440 /etc/sudoers.d/*
RUN addgroup {{ NB_GROUP }}

# USER {{ NB_USER }}
RUN mkdir /notebooks
WORKDIR /notebooks

EXPOSE 8888
COPY entry.sh /opt/compute-container/entry.sh
RUN chmod +x /opt/compute-container/entry.sh
CMD ["/opt/compute-container/entry.sh"]
