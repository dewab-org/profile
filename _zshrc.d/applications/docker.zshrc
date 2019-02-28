#
local DOCKER="$(command -v docker)"
[ ! -x "${DOCKER}" ] && return

function docker-update () {
	# Update all latest images
	docker images | awk '$2=="latest" {print $1}' | xargs -n1 docker pull	

	# Try and remove images not in use
	docker images | awk '$2=="<none>" {print $3}' | xargs -rn1 docker rmi

	# Remove any dangling volumes
	#docker volume ls -qf dangling=true | xargs -rn1 docker volume rm
	docker volume prune -f
}

function drips(){
    docker ps -q | xargs -n 1 docker inspect --format '{{ .NetworkSettings.IPAddress }} {{ .Name }}' | sed 's/ \// /'
}

unset DOCKER
