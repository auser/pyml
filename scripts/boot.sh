#!/bin/bash

SCRIPT=`basename ${BASH_SOURCE[0]}`
DM=$(which docker-machine)
D=$(which docker)

VERBOSE=false
DRY_RUN=false
PROVIDER="virtualbox"
CLUSTER_PREFIX="cluster"

#Set fonts for Help.
NORM=`tput sgr0`
BOLD=`tput bold`
REV=`tput smso`

function HELP {
  echo -e \\n"Help documentation for ${BOLD}${SCRIPT}.${NORM}"\\n
  echo -e "${REV}Basic usage:${NORM} ${BOLD}$SCRIPT ${NORM}"\\n
  echo "${REV}-p${NORM}     --Provider. Default is ${BOLD}${PROVIDER}${NORM}"
  echo "${REV}-v${NORM}     --verbose Default is ${BOLD}${VERBOSE}${NORM}"
  echo "${REV}-d${NORM}     --Dry run. Default is ${BOLD}${DRY_RUN}${NORM}"
  echo "${REV}-n${NORM}     --name. Default is ${BOLD}${CLUSTER_PREFIX}${NORM}"
  echo -e "${REV}-h${NORM}  --Displays this help message"\\n
  exit 1
}

while getopts :vdhp: FLAG; do
  case $FLAG in
    v) VERBOSE=true
        ;;
    h) HELP
        ;;
    d) DRY_RUN=true
        ;;
    n) CLUSTER_PREFIX="$OPTARG"
        ;;
    p)
        if [[ "$OPTARG" != "aws" &&
              "$OPTARG" != "virtualbox" ]]; then
          HELP
        else
          PROVIDER="$OPTARG"
        fi
        ;;
    \?) break ;;
  esac
done

RET=""
STATUS=""

verbose() {
  if [[ "$VERBOSE" != false ]]; then
    echo "$@"
  fi
}

getName() {
  # return 0
  local _outvar=$1
  local _result="$CLUSTER_PREFIX$2"

  eval $_outvar=\$_result
}

dmStatus() {
  local _outvar=$1
  local _name=$2
  $DM status $_name 2>&1 > /dev/null
  eval $_outvar=\$?
}

launchConsulHost() {
  local _name=$1
  local _options=${@:2}

  local _status
  dmStatus _status $_name

  if [[ $_status -eq 1 ]]; then
    # Machine not running
    $DM create $_options $_name
  # else
    # Machine already running
  fi
}

dockerId() {
  local _outvar=$1
  local _name=$2

  local _container=$($D ps | grep $_name)

  if [[ _container != "" ]]; then
    local _id=$(echo "$_container" | awk '{print $1}')
    eval $_outvar=\$_id
  fi
}

dockerRunning() {
  local _outvar=$1
  local _name=$2

  local containerId
  dockerId containerId $_name

  if [[ $containerId != "" ]]; then
    local _status=$($D inspect --format="{{ .State.Running }}" $containerId)
    eval $_outvar=\$_status
  fi
}

launchConsul() {
  local _name=$1
  local _ip=$2

  local containerStatus
  dockerRunning containerStatus "consul-server"

  if [[ $containerStatus != "true" ]]; then
    $D run -d -p $_ip:8500:8500 \
              -p $_ip:53:8600/udp \
              -p 8400:8400 \
              -h $_name \
              gliderlabs/consul-server \
              -node $_name \
              -bootstrap \
              -advertise $_ip \
              -client 0.0.0.0
  fi
}

dmIp() {
  local _outvar=$1
  local _name=$2

  local _res=$($DM ssh $_name 'ifconfig eth1 | grep "inet addr:" | cut -d: -f2 | cut -d" " -f1')
  eval $_outvar=\$_res
}

dmi() {
  local _name=$1
  eval $($DM env $_name)
}

launchRegistratorContainer() {
  local _ip=$1
  local _consulIp=$2

  local containerStatus
  dockerRunning containerStatus "registrator"

echo "launchRegistratorContainer: $containerStatus"

  if [[ $containerStatus != "true" ]]; then
    $D run -d -h $_ip \
            --volume=/var/run/docker.sock:/tmp/docker.sock \
            gliderlabs/registrator:latest \
            consul://${_consulIp}:8500
  fi
}

launchSwarmHost() {
  local _name=$1
  local _ip=$2
  local _options=${@:3}
  local hostIp

  local swarmMasterContainerStatus
  dmStatus swarmMasterContainerStatus $_name

  if [[ $swarmMasterContainerStatus -eq 1 ]]; then
    CMD="$DM create $_options $SWARM_OPTIONS $_name"
    verbose "Running command: $CMD"
    ${CMD}
  fi

  dmi $_name
  dmIp hostIp $_name
  launchRegistratorContainer $hostIp $_ip
}

launchSwarmMaster() {
  local _ip=$2

  SWARM_OPTIONS="--swarm \
                --swarm-master \
                --swarm-discovery=\"consul://$_ip:8500\" \
                --engine-opt=\"cluster-store=consul://$_ip:8500\" \
                --engine-opt=\"cluster-advertise=eth1:2376\""

  launchSwarmHost $@ $SWARM_OPTIONS
}

launchSwarmSlave() {
  local _ip=$2

  SWARM_OPTIONS="--swarm \
                --swarm-discovery=\"consul://$_ip:8500\" \
                --engine-opt=\"cluster-store=consul://$_ip:8500\" \
                --engine-opt=\"cluster-advertise=eth1:2376\""

  launchSwarmHost $@ $SWARM_OPTIONS
}

DRIVER_OPTIONS=""

if [[ $PROVIDER == "virtualbox" ]]; then
  DISK_SIZE=${DISK_SIZE:-50000}
  MEMORY=${MEMORY:-4096}
  CPU_COUNT=${CPU_COUNT:-2}

  DRIVER_OPTIONS="--driver virtualbox \
                  --virtualbox-disk-size $DISK_SIZE \
                  --virtualbox-memory $MEMORY \
                  --virtualbox-cpu-count $CPU_COUNT"

  verbose "${NORM}Running ${REV}${BOLD}virtualbox${NORM}"

elif [[ $PROVIDER == "aws" ]]; then
  echo "AWS"
else
  echo "Error"
fi

getName consulMachineName "consul"
verbose "${NORM}Consul machine name ${REV}${BOLD}${consulMachineName}${NORM}"
launchConsulHost $consulMachineName $DRIVER_OPTIONS
dmi $consulMachineName

dmIp consulIp $consulMachineName
verbose "${NORM}Booting consul container: ${REV}${BOLD}${consulIp}${NORM}"
launchConsul $consulMachineName $consulIp
verbose "${NORM}Consul launched and is at ip: ${REV}${BOLD}${consulIp}${NORM}"

getName masterName "swarm-master"
verbose "${NORM}Launching swarm master ${REV}${BOLD}${masterName}${NORM}"
launchSwarmMaster $masterName $consulIp $DRIVER_OPTIONS
dmIp swarmIp $masterName
verbose "${NORM}Swarm master launched and is at ip: ${REV}${BOLD}${swarmIp}${NORM}"

slaveName="${CLUSTER_PREFIX}-1"
verbose "${NORM}Launching swarm slave ${REV}${BOLD}${slaveName}${NORM}"
launchSwarmSlave "$slaveName" $consulIp $DRIVER_OPTIONS
dmIp slaveIp $slaveName
verbose "${NORM}Swarm slave launched and is at ip: ${REV}${BOLD}${slaveIp}${NORM}"

# Finally:
eval $($DM env -swarm $masterName)

echo "swarm ip: $swarmIp"

#
# CLUSTER_PREFIX="aws01"
# AWS_AMI=${AWS_AMI:-"ami-125b2c72"}
# AWS_VPC_ID=${VPC_ID:-"vpc-c9d848ac"}
# AWS_SUBNET_ID=${SUBNET_ID:-"subnet-9ae9aeff"}
# AWS_REGION=${AWS_REGION:-"us-west-1"}
#
# # --amazonec2-vpc-id vpc-c9d848ac \
# # --amazonec2-subnet-id subnet-9ae9aeff \
#
# AWS_DRIVER_OPTIONS="--driver amazonec2 \
#                 --amazonec2-ami ${AWS_AMI} \
#                 --amazonec2-instance-type=t2.nano \
#                 --amazonec2-vpc-id $AWS_VPC_ID \
#                 --amazonec2-subnet-id $AWS_SUBNET_ID \
#                 --amazonec2-region $AWS_REGION"
#
# LOCAL_DRIVER_OPTIONS="--driver virtualbox \
#                       --virtualbox-disk-size \"50000\" \
#                       --virtualbox-memory 4096 \
#                       --virtualbox-cpu-count 2"
#
#
# echo "PROVIDER: $PROVIDER"
#
# docker-machine create -d virtualbox \
#             --swarm \
#             --swarm-master \
#             --swarm-discovery="consul://$(docker-machine ip consul-machine):8500" \
#             --engine-opt="cluster-store=consul://$(docker-machine ip consul-machine):8500" \
#             --engine-opt="cluster-advertise=eth1:2376" \
#             swarm-master
#
#
# # # --amazonec2-vpc-id $vpcId \
# # # --amazonec2-subnet-id $subnetId \
# # if ${launchConsul}; then
# #     echo "Launching consul machine"
# #     docker-machine create $DRIVER_OPTIONS --amazonec2-instance-type=t2.nano ${CLUSTER_PREFIX}ks
# #
# #     echo "Launching docker consul server"
# #     docker $(docker-machine config ${CLUSTER_PREFIX}ks) run \
# #            -d \
# #            -p "8500:8500" \
# #            -h "consul" progrium/consul -server -bootstrap
# # fi
# #
# # if ${launchMaster}; then
# #   echo "Launching master..."
# #   NET_ETH=eth0
# #   KEYSTORE_IP=$(aws ec2 describe-instances | jq -r ".Reservations[].Instances[] | select(.KeyName==\"${CLUSTER_PREFIX}ks\" and .State.Name==\"running\") | .PrivateIpAddress")
# #   SWARM_OPTIONS="--swarm --swarm-discovery=consul://$KEYSTORE_IP:8500 --engine-opt=cluster-store=consul://$KEYSTORE_IP:8500 --engine-opt=cluster-advertise=$NET_ETH:2376"
# #   MASTER_OPTIONS="$DRIVER_OPTIONS $SWARM_OPTIONS --swarm-master -engine-label role=master --amazonec2-instance-type=m4.large"
# #   MASTER=${CLUSTER_PREFIX}n0
# #
# #   docker-machine create $MASTER_OPTIONS \
# #       --amazonec2-instance-type=m4.large $MASTER
# # fi
# #
# #
# # # aws ec2 authorize-security-group-ingress --group-id <security-group-id> --protocol tcp --port 80 --cidr $(curl checkip.amazonaws.com)/32
# #
# # # echo "-------------------"
# # # echo "Create our small instance machine"
# # # docker-machine create $DRIVER_OPTIONS --amazonec2-instance-type=t2.nano ${CLUSTER_PREFIX}ks
# # # echo "-------------------"
# #
# # # echo "-------------------"
# # # echo "Create our consul machine"
# # # docker $(docker-machine config ${CLUSTER_PREFIX}ks) run -d -p "8500:8500" -h "consul" progrium/consul -server -bootstrap
# # # echo "-------------------"
# #
# # # NET_ETH=eth0
# # # KEYSTORE_IP=$(aws ec2 describe-instances | jq -r ".Reservations[].Instances[] | select(.KeyName==\"${CLUSTER_PREFIX}ks\" and .State.Name==\"running\") | .PrivateIpAddress")
# # # SWARM_OPTIONS="--swarm \
# # #               --swarm-discovery consul://$KEYSTORE_IP:8500 \
# # #               --engine-opt cluster-store=consul://$KEYSTORE_IP:8500 \
# # #               --engine-opt cluster-advertise=$NET_ETH:2376"
# # # MASTER_OPTIONS="$DRIVER_OPTIONS $SWARM_OPTIONS \
# # #               --swarm-master \
# # #               --engine-label role=master \
# # #               --amazonec2-instance-type=m4.large"
# # # MASTER=${CLUSTER_PREFIX}n0
# # # docker-machine create $MASTER_OPTIONS --amazonec2-instance-type=m4.large $MASTER
# #
# # # docker $(docker-machine config --swarm $MASTER) run hello-world
# #
# # # # Tear the machine down
# # # # docker-machine ls | grep "^${CLUSTER_PREFIX}" | cut -d\ -f1 | xargs docker-machine rm -y
