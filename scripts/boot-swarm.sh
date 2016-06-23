#!/bin/bash

## LIBRARY FUNCTION -- just gotta copy+paste
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

source $DIR/utils.sh
source $DIR/swarm.sh

SCRIPT=`basename ${BASH_SOURCE[0]}`
DM=$(which docker-machine)
D=$(which docker)

VERBOSE=false
DRY_RUN=false
SKIP_CONFIRMATION=false
NUM_NODES=2
PROVIDER="virtualbox"
CLUSTER_PREFIX="fs"
NET_NAME="${CLUSTER_PREFIX}-net"

SPOT_PRICE=

function HELP {
  e_header "Help documentation"
  e_log "Usage: $0 [options]"
  e_log
  e_log "-p" "provider. Default: ${PROVIDER}"
  e_log "-v" "verbose. Default: ${VERBOSE}"
  e_log "-s" "number of nodes to start. Default: ${NUM_NODES}"
  e_log "-d" "dry run. Default: ${DRY_RUN}"
  e_log "-y" "skip confirmation. Default: ${SKIP_CONFIRMATION}"
  e_log "-n" "name. Default is: ${CLUSTER_PREFIX}"
  e_log "-t" "request spot price. Default: ${SPOT_PRICE}"
  e_log "-h" "Display this help message\n"
  e_log

  exit 1
}

if [ -f "$DIR/../.env" ]; then
  e_log
  e_log e_header ".env file found"
  e_log
  source "$DIR/../.env"
fi

while getopts :vdhp:ys:ct: FLAG; do
  case $FLAG in
    v) VERBOSE=true
        ;;
    y) SKIP_CONFIRMATION=true
        ;;
    h) HELP
        ;;
    d) DRY_RUN=true
        ;;
    n) CLUSTER_PREFIX="$OPTARG"
        ;;
    s) NUM_NODES=$OPTARG
        ;;
    t) SPOT_PRICE="$OPTARG"
        ;;
    p)
        if [[ "$OPTARG" != "aws" &&
              "$OPTARG" != "virtualbox" ]]; then
          HELP
        else
          PROVIDER="$OPTARG"
        fi
        ;;
    \?) ;;
  esac
done

DRIVER_OPTIONS=""

if [[ $PROVIDER == "virtualbox" ]]; then
  DISK_SIZE=${DISK_SIZE:-50000}
  MEMORY=${MEMORY:-4096}
  CPU_COUNT=${CPU_COUNT:-2}

  DRIVER_OPTIONS="--driver virtualbox \
                  --virtualbox-disk-size $DISK_SIZE \
                  --virtualbox-memory $MEMORY \
                  --virtualbox-cpu-count $CPU_COUNT"

  e_debug e_header "${NORM}Running ${REV}${BOLD}virtualbox${NORM}"

elif [[ $PROVIDER == "aws" ]]; then
  if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_VPC_ID" ]; then
    echo "Please set your AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and AWS_VPC_ID"
    exit 1;
  fi

  AWS_AMI=${AWS_AMI:-"ami-125b2c72"}
  AWS_VPC_ID=${AWS_VPC_ID:-"vpc-c9d848ac"}
  AWS_SUBNET_ID=${SUBNET_ID:-"subnet-9ae9aeff"}
  AWS_REGION=${AWS_REGION:-"us-west-1"}

  DRIVER_OPTIONS="--driver amazonec2 \
                  --amazonec2-access-key ${AWS_ACCESS_KEY_ID} \
                  --amazonec2-secret-key ${AWS_SECRET_ACCESS_KEY} \
                  --amazonec2-ami ${AWS_AMI} \
                  --amazonec2-region $AWS_REGION \
                  --amazonec2-vpc-id ${AWS_VPC_ID}"
                  # --amazonec2-subnet-id $AWS_SUBNET_ID \

  if [[ ! -z "$SPOT_PRICE" ]]; then
    echo "HERE $SPOT_PRICE"
    DRIVER_OPTIONS="$DRIVER_OPTIONS \
                    --amazonec2-request-spot-instance \
                    --amazonec2-spot-price $SPOT_PRICE"
  fi
else
  echo "Error"
fi

echo "DRIVER: $DRIVER_OPTIONS"
exit 0

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

e_debug e_header "Creating multihost keystore"
getName keystoreName "keystore"
createMachine $keystoreName "$DRIVER_OPTIONS"
dmi $keystoreName

e_debug e_header "Launching consul on $keystoreName"
launchConsul _keystoreContainerId "consul-server"
dmIp keystoreIp $keystoreName

launchRegistrator _consulRegistratorContainer $keystoreIp

e_debug e_success "Consul launched on $keystoreName at $_keystoreContainerId with external ip: $keystoreIp"
e_debug e_header "Creating swarm master..."

getName swarmMasterName "swarm-master"
launchSwarmMaster swarmMasterId \
                  $swarmMasterName \
                  $keystoreIp \
                  "$DRIVER_OPTIONS"

dmIp swarmMasterIP $swarmMasterName
dmi $swarmMasterName
launchRegistrator _masterRegistrator $keystoreIp

# e_debug e_header "Creating network"
# createNetwork $NET_NAME

e_debug e_success "Swarm master launched on $swarmMasterName at $swarmMasterIP"

for I in $(seq 1 $NUM_NODES)
do
  e_debug e_header "Creating swarm node $I..."
  getName swarmNodeName "swarm-node$I"

  launchSwarmNode swarmNodeName \
                    $swarmNodeName \
                    $keystoreIp \
                    "$DRIVER_OPTIONS"

  dmIp swarmNodeIP $swarmNodeName
  dmi $swarmNodeName
  launchRegistrator _nodeRegistrator $keystoreIp
  e_debug e_success "Launched swarm node $I at $swarmNodeIP"
done

dmi $swarmMasterName
docker network create --driver overlay $NET_NAME

exit 0
#
# ## Launch a consult host and kick off the consul
# # instance running
# getName consulMachineName "consul"
# verbose "${NORM}Consul machine name ${REV}${BOLD}${consulMachineName}${NORM}"
# launchConsulHost $consulMachineName $DRIVER_OPTIONS
# dmi $consulMachineName
# dmIp consulIp $consulMachineName "docker0"
# verbose "${NORM}Booting consul container: ${REV}${BOLD}${consulIp}${NORM}"
# launchConsul $consulMachineName $consulIp
# verbose "${NORM}Consul launched and is at ip: ${REV}${BOLD}${consulIp}${NORM}"
#
# noticeAndExit $consulMachineName
#
# getName masterName "swarm-master"
# verbose "${NORM}Launching swarm master ${REV}${BOLD}${masterName}${NORM}"
# launchSwarmMaster $masterName $consulIp $DRIVER_OPTIONS
# dmIp swarmIp $masterName
# verbose "${NORM}Swarm master launched and is at ip: ${REV}${BOLD}${swarmIp}${NORM}"
#
# for I in 1 2
# do
#   slaveName="swarm-node-$I"
#   verbose "${NORM}Launching swarm slave ${REV}${BOLD}${slaveName}${NORM}"
#   launchSwarmSlave "$slaveName" $consulIp $DRIVER_OPTIONS
#   dmIp slaveIp $slaveName
#   verbose "${NORM}Swarm slave launched and is at ip: ${REV}${BOLD}${slaveIp}${NORM}"
# done
#
# # Finally:
# eval $($DM env --swarm $masterName)
#
# docker ps
