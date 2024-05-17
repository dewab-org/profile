is-executable docker || return

# ESXCLI
alias esxcli='DOCKER_CONTEXT=desktop-linux docker run -it -v "${HOME}"/.config/esxcli:/config:ro --rm esxcli:7.0.0 -c /config/vcsa.lab.local.conf'

autoload -Uz web-server
autoload -Uz ftp-server
