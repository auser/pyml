#!/bin/bash

launchConsul() {
  local _outvar=$1
  local _name=$2
  local _options=${@:3}

  local _consulContainerId
  dockerId _consulContainerId $_name

  # -p 53:8600/udp \
  # -p 8400:8400 \
  # -p 8600:53/udp \
  launchContainer _consulContainerId $_name \
            "$($DM config $_name) \
            -p 8500:8500 \
            gliderlabs/consul-server \
            -server \
            -bootstrap"

  eval $_outvar=$_consulContainerId
}

# docker run -d \
#     --name=registrator \
#     --net=host \
#     --volume=/var/run/docker.sock:/tmp/docker.sock \
#     gliderlabs/registrator:latest \
#       consul://localhost:8500

launchRegistrator() {
  local _outvar=$1
  local _name="registrator"
  local _consulIp=$2

  local _consulContainerId
  dockerId _consulContainerId $_name

  # -p 53:8600/udp \
  # -p 8400:8400 \
  # -p 8600:53/udp \
  launchContainer _consulContainerId $_name \
            "$($DM config $_name) \
            --volume=/var/run/docker.sock:/tmp/docker.sock \
            --name=$_name \
            gliderlabs/registrator:latest \
            consul://$_consulIp:8500"

  eval $_outvar=$_consulContainerId
}

launchSwarmMaster() {
  local _outvar=$1
  local _name=$2
  local _consulIp=$3
  local _options=${@:4}

  SWARM_OPTIONS="--swarm \
                --swarm-master \
                --swarm-discovery=consul://$_consulIp:8500 \
                --engine-opt=cluster-store=consul://$_consulIp:8500 \
                --engine-opt=cluster-advertise=eth0:2376"

  createMachine $_name $_options $SWARM_OPTIONS
}

launchSwarmNode() {
  local _outvar=$1
  local _name=$2
  local _consulIp=$3
  local _options=${@:4}

  # TODO: --engine-opt=net=${NET_NAME} \
  SWARM_OPTIONS="--swarm \
                --swarm-discovery=consul://$_consulIp:8500 \
                --engine-opt=cluster-store=consul://$_consulIp:8500 \
                --engine-opt=cluster-advertise=eth0:2376"

  createMachine $_name $_options $SWARM_OPTIONS
}
