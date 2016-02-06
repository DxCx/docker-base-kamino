#!/bin/sh
set -e

export KAMINO_WORKDIR=/tmp/kamino
export KAMINO_ENVFILE=${KAMINO_WORKDIR}/env.list

# TODO: optparse
while getopts ":hi:" opt; do
	case $opt in
		h)
			echo "Usage: kamino -i <input dir>" >&2
			exit 1
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
echo COMPOSE_PROJECT_NAME=$(basename "${INPUT_DIR}") > ${KAMINO_ENVFILE}
echo PUSER=${PUSER} >> ${KAMINO_ENVFILE}
echo PUID=${PUID} >> ${KAMINO_ENVFILE}
echo PGID=${PGID} >> ${KAMINO_ENVFILE}

# Handle docker-compose yml file.
cp /kamino/docker-compose.yml .
cat ${INPUT_DIR}/docker-compose.yml >> ./docker-compose.yml

# Run inner bootstrap
cd ${INPUT_DIR}
source ${INPUT_DIR}/bootstrap.sh
cd ${KAMINO_WORKDIR}

# pull all images
# TODO, fix grep "image:" docker-compose.yml| cut -d ' ' -f6 | xargs -L1 docker pull
docker pull dduportal/docker-compose:latest 

# Run docker-compose
exec /usr/local/bin/docker run \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v "${KAMINO_WORKDIR}":"${KAMINO_WORKDIR}" --workdir="${KAMINO_WORKDIR}" \
	--env-file ./env.list \
	-ti --rm \
	dduportal/docker-compose:latest up
