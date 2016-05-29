#!/bin/sh

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
source $DIR/utils.sh

VERBOSE=false
MACHINE_NAME=${MACHINE_NAME:-dev}
S3_USER=${S3_USER:-}
S3_SECRET=${S3_SECRET:-}
BUCKET=${BUCKET:-}
MOUNT=${MOUNT:-/mnt/data}

function HELP {
  e_header "Help documentation"
  e_log "Usage: $0 [options]"
  e_log
  e_log "-v" "verbose. Default: ${VERBOSE}"
  e_log "-b" "bucket to mount. Default: ${BUCKET}"
  e_log "-n" "docker machine name. Default: ${MACHINE_NAME}"
  e_log "-m" "mount point. Default: ${MOUNT}"
  e_log "-u" "the s3 user. Default: ${S3_USER}"
  e_log "-s" "the s3 secret. Default: ${S3_SECRET}"
  e_log "-h" "Display this help message\n"
  e_log

  exit 1
}

while getopts :vhb:m:n:u:s: FLAG; do
  case $FLAG in
    v) VERBOSE=true
        ;;
    b) BUCKET="$OPTARG"
        ;;
    m) MOUNT="$OPTARG"
        ;;
    n) MACHINE_NAME="$OPTARG"
        ;;
    u) S3_USER="$OPTARG"
        ;;
    h) HELP
        ;;
    s) S3_SECRET="$OPTARG"
        ;;
    \?) ;;
  esac
done

if [[ $# -lt 1 ]]
then
  echo "set S3_USER and S3_SECRET env"
  echo
  echo "Usage: $0 bucket mountpoint"
  echo "Example: $0 snuffy /mnt/snuffy"
  exit
fi

CUDA_SO=$(docker-machine ssh $MACHINE_NAME ls /usr/lib/x86_64-linux-gnu/libcuda.* | \
          xargs -I{} echo '-v {}:{}')
DEVICES=$(docker-machine ssh $MACHINE_NAME ls /dev/nvidia* | \
          xargs -I{} echo '--device {}:{}')
echo "$CUDA_SO $DEVICES"
# export CUDA_SO=$(\ls /usr/lib/x86_64-linux-gnu/libcuda.* | \
#                     xargs -I{} echo '-v {}:{}')
# export DEVICES=$(\ls /dev/nvidia* | \
#                     xargs -I{} echo '--device {}:{}')
#
# DEVICES=--device=/dev/nvidia0:/dev/nvidia0 \                        [2.2.1]
#   --device=/dev/nvidiactl:/dev/nvidiactl \
#   --device=/dev/nvidia-uvm:/dev/nvidia-uvm
#
# CUDA_SO=-v /usr/lib/x86_64-linux-gnu/libcuda.so:/usr/lib/x86_64-linux-gnu/libcuda.so -v /usr/lib/x86_64-linux-gnu/libcuda.so.1:/usr/lib/x86_64-linux-gnu/libcuda.so.1 -v /usr/lib/x86_64-linux-gnu/libcuda.so.352.93:/usr/lib/x86_64-linux-gnu/libcuda.so.352.93
# $DEVICES $CUDA_SO \

docker run --privileged \
    -e S3User=$S3_USER \
    -e S3Secret=$S3_SECRET \
    -v $MOUNT:/mnt/mountpoint:shared \
    --cap-add SYS_ADMIN $USER/volume_container $1 \
    /mnt/mountpoint \
    -o passwd_file=/etc/passwd-s3fs \
    -d -d -f -o f2 -o curldbg
