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
  e_log "-h" "Display this help message\n"
  e_log

  exit 1
}

while getopts :vdhp:ys:c FLAG; do
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

  verbose "${NORM}Running ${REV}${BOLD}virtualbox${NORM}"

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
else
  echo "Error"
fi

e_debug e_header "Creating multihost keystore"
getName keystoreName "keystore"
createMachine $keystoreName "$DRIVER_OPTIONS --amazonec2-instance-type=t2.nano"
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
                  "$DRIVER_OPTIONS \
                    --amazonec2-instance-type=t2.nano"

dmIp swarmMasterIP $swarmMasterName
dmi $swarmMasterName
echo "keystoreIp: $keystoreIp"
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
                    "$DRIVER_OPTIONS \
                      --amazonec2-instance-type=g2.2xlarge"

  dmIp swarmNodeIP $swarmNodeName
  dmi $swarmNodeName
  launchRegistrator _nodeRegistrator $keystoreIp
  e_debug e_success "Launched swarm node $I at $swarmNodeIP"
done

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
