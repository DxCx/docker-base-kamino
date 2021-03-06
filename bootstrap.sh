#!/bin/sh
set -e

# Get current script dir
# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/bin
export KAMINO_DIR=$(dirname "$SCRIPT")

# General configuration
source ${KAMINO_DIR}/functions.sh
export KAMINO_WORKDIR=/var/run/kamino
export KAMINO_DEBUG=false

# option parsing
while getopts ":hd" opt; do
	case $opt in
		h)
			echo "Usage: kamino [-d]" >&2
			echo "Flags:"
			echo " -d -> debug mode. print env vars"
			exit 1
			;;
		d)
			echo ">> debug mode enabled"
			export KAMINO_DEBUG=true
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit 1
			;;
		:)
			echo "Option -$OPTARG requires an argument." >&2
			exit 1
			;;
	esac
done
if [[ ${KAMINO_DEBUG} = true ]]; then
	set -x
fi

if [[ -z "${KAMINO_INPUT_DIR}" ]]; then
	echo "KAMINO_INPUT_DIR enviorment is missing."
	exit 1
fi
INPUT_DIR=${KAMINO_INPUT_DIR}

# Prepare workdir
mkdir -p ${KAMINO_WORKDIR}
cd ${KAMINO_WORKDIR}

# Create env file
COMPOSE_PROJECT_NAME=$(basename "${INPUT_DIR}")

# Handle docker-compose yml file.
cp /kamino/docker-compose.yml .
cat ${INPUT_DIR}/docker-compose.yml >> ./docker-compose.yml

################# Start the actual work ##################

# Register cleanup
trap _kamino_cleanup EXIT INT TERM KILL

# Run docker daemon
kamino_dind

# After docker is up, setup Kamino docker network
export KAMINO_DOCKER_NETWORK=`ip route | awk '!/ (docker0|br-)/ && /src/ { printf "%s ", $1 }'`

# Run inner bootstrap
cd ${INPUT_DIR}
source ${INPUT_DIR}/bootstrap.sh
cd ${KAMINO_WORKDIR}

## pull all images
docker-compose pull &
wait $!

# Dump enviorment if debug flag exists
if [[ ${KAMINO_DEBUG} = true ]]; then
    docker version
    docker info
    uname -a
fi

kamino_start
