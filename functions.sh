#!/bin/bash

kamino_clean_env() {
	truncate -s 0 ${KAMINO_ENVFILE}
}

kamino_env_add() {
	export $1
	echo $1 >> ${KAMINO_ENVFILE}
}

