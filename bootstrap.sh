#!/bin/sh
set -e
source functions.sh
export KAMINO_WORKDIR=/tmp/kamino
export KAMINO_ENVFILE=${KAMINO_WORKDIR}/env.list
export KAMINO_DEBUG=false

while getopts ":hdi:" opt; do
	case $opt in
		h)
			echo "Usage: kamino [-d] -i <input dir>" >&2
			echo "Flags:"
			echo " -i -> input directory"
			echo " -d -> debug mode. print env vars"
			exit 1
			;;
		d)
			echo ">> debug mode enabled"
			export KAMINO_DEBUG=true
			;;
		i)
			echo ">> input dir is $OPTARG" >&2
			INPUT_DIR=$OPTARG
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

# Run docker daemon
dockerd-entrypoint.sh & #2>&1 > /dev/null

# Prepare workdir
mkdir -p ${KAMINO_WORKDIR}
cd ${KAMINO_WORKDIR}

# Create env file
kamino_clean_env
COMPOSE_PROJECT_NAME=$(basename "${INPUT_DIR}")
kamino_env_add COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME}
kamino_env_add PUSER=${PUSER}
kamino_env_add PUID=${PUID}
kamino_env_add PGID=${PGID}

# Handle docker-compose yml file.
cp /kamino/docker-compose.yml .
cat ${INPUT_DIR}/docker-compose.yml >> ./docker-compose.yml

# Run inner bootstrap
cd ${INPUT_DIR}
source ${INPUT_DIR}/bootstrap.sh
cd ${KAMINO_WORKDIR}

if [[ ${KAMINO_DEBUG} = true ]]; then
	echo ">>>>>> DEBUG: KAMINO_ENVFILE <<<<<<"
	cat ${KAMINO_ENVFILE}
	echo ">>>>>> DEBUG: KAMINO_ENVFILE <<<<<<"
fi

# pull all images
# TODO: fix grep "image:" docker-compose.yml| cut -d ' ' -f6 | xargs -L1 docker pull
docker pull dduportal/docker-compose:latest 

# Run docker-compose
exec /usr/local/bin/docker run \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v "${KAMINO_WORKDIR}":"${KAMINO_WORKDIR}" --workdir="${KAMINO_WORKDIR}" \
	--env-file ./env.list \
	-ti --rm \
	dduportal/docker-compose:latest up
