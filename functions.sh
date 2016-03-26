#!/bin/bash

_kamino_bg_dind() {
	. dockerd-entrypoint.sh
}

kamino_dind() {
	echo "About to start DIND"
	if [[ -f /var/run/docker.pid ]]; then
		echo "Docker PID leftover was found"
		kill -9 $(cat /var/run/docker.pid) > /dev/null 2>&1 || true
		rm -f /var/run/docker.*
	fi
	_kamino_bg_dind &
	printf "Waiting for Docker : "
	while [[ ! -e /var/run/docker.sock ]]; do
		printf "#"
		sleep 1
	done
	printf "\nDocker is ready.\n"
}

kamino_prepare_compose() {
	docker pull dduportal/docker-compose:latest
	cat > /usr/local/bin/docker-compose << EOF
#!/bin/sh
printenv > ${KAMINO_ENVFILE}
if [[ ${KAMINO_DEBUG} = true ]]; then
	echo ">>>>>> DEBUG: KAMINO_ENVFILE <<<<<<"
	cat ${KAMINO_ENVFILE}
	echo ">>>>>> DEBUG: KAMINO_ENVFILE <<<<<<"
fi

exec /usr/local/bin/docker run \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v /var/lib/docker:/var/lib/docker \
	-v "${KAMINO_WORKDIR}":"${KAMINO_WORKDIR}" --workdir="${KAMINO_WORKDIR}" \
	--env-file ${KAMINO_ENVFILE} \
	-ti --rm \
	dduportal/docker-compose:latest \$@
EOF
	chmod +x /usr/local/bin/docker-compose
}
