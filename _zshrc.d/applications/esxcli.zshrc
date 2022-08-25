[[ $+commands[docker] -lt 1 ]] && return

alias esxcli='DOCKER_CONTEXT=desktop-linux docker run -it -v "${HOME}"/.esxcli:/config:ro --rm esxcli:7.0.0 -c /config/vcsa.lab.local.conf'