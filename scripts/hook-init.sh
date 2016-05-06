#!/bin/bash

make build/webhook

docker run \
  --name webhook \
  -p 4040:4040 \
  --restart=always \
  -d \
  -v /home/ubuntu/.ssh:/ssh \
  -v /var/run/docker.sock:/var/run/docker.sock \
  auser/webhook
