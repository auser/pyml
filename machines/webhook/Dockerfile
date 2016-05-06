FROM almir/webhook

RUN mkdir /data
ADD rebuild.sh /data/rebuild.sh
RUN chmod u+x /data/rebuild.sh
ADD hooks.json /etc/webhook/hooks.json

CMD ["-verbose", "-hooks=/etc/webhook/hooks.json", "-port=8888"]
