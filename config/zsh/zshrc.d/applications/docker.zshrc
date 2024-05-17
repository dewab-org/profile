is-executable docker || return

# Move configuration files to .config
export DOCKER_CONFIG="${XDG_CONFIG_HOME}/docker"
export MACHINE_STORAGE_PATH="${XDG_DATA_HOME}/docker-machine"

if [[ ! -f "${ZSH_CACHE_DIR}/completions/_docker" ]]; then
  autoload -Uz _docker
  typeset -g -A _comps
  _comps[docker]=_docker
fi

docker completion zsh >| "${ZSH_CACHE_DIR}/completions/_docker" &|

function drips(){
    docker ps -q | xargs -n 1 docker inspect --format '{{ .NetworkSettings.IPAddress }} {{ .Name }}' | sed 's/ \// /'
}
