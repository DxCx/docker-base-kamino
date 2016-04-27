#!/bin/sh

# Globals
kamino_docker_pid=
kamino_compose_up=false

_kamino_cleanup() {
	set +e
	trap '' EXIT INT TERM
	
	echo "Kamino Cleans-up... (PID=${kamino_docker_pid})"

	if [[ ${kamino_compose_up} == true ]]; then
		#docker-compose down
		kamino_compose_up=false
	fi

	if [[ ! -z ${kamino_docker_pid} ]]; then
		docker stop $(docker ps -a -q) > /dev/null 2>&1 || true
		echo "Stopping Docker PID=${kamino_docker_pid}"
		kill ${kamino_docker_pid}
		wait ${kamino_docker_pid}
		rm -vf /var/run/docker.*
		kamino_docker_pid=
	fi
}

_kamino_bg_dind() {
	nohup /usr/local/bin/dockerd-entrypoint.sh & > /dev/null
}

kamino_dind() {
	echo "About to start DIND"
	if [[ -f /var/run/docker.pid ]]; then
		echo "Docker PID leftover was found"
		kill -9 $(cat /var/run/docker.pid) > /dev/null 2>&1 || true
		rm -vf /var/run/docker.*
	fi

	# Run docker DIND
	_kamino_bg_dind
	printf "Waiting for Docker : "
	while [[ ! -e /var/run/docker.sock ]]; do
		printf "#"
		sleep 1
	done

	# Update docker pid
	kamino_docker_pid=$(cat /var/run/docker.pid)
	printf "\nDocker is ready. PID=${kamino_docker_pid}\n"
}

kamino_start() {
	# Run docker-compose
	nohup docker-compose up -d > /dev/null
	kamino_compose_up=true
	docker-compose logs -f &
	wait $!
}
