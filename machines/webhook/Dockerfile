FROM almir/webhook

RUN mkdir /data
ADD rebuild.sh /data/rebuild.sh
RUN chmod u+x /data/rebuild.sh
ADD hooks.json /etc/webhook/hooks.json
ADD git_ssh /usr/local/git_ssh
ENV GIT_SSH /usr/local/git_ssh

RUN apk add --update -t build-deps git make openssh

CMD ["-verbose", "-hooks=/etc/webhook/hooks.json", "-port=4040"]
