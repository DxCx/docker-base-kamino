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

kamino_clean_env() {
	truncate -s 0 ${KAMINO_ENVFILE}
}

kamino_env_add() {
	export $1
	echo $1 >> ${KAMINO_ENVFILE}
}
