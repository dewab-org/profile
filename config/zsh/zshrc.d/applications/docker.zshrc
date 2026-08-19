is-executable docker || return

# Move configuration files to .config
export DOCKER_CONFIG="${XDG_CONFIG_HOME}/docker"
export MACHINE_STORAGE_PATH="${XDG_DATA_HOME}/docker-machine"

autoload -Uz _docker command-completion
(( ${+_comps} )) || typeset -g -A _comps
_comps[docker]=_docker
command-completion "${ZSH_CACHE_DIR}/completions/_docker" docker completion zsh &|

function drips(){
    docker ps -q | xargs -n 1 docker inspect --format '{{ .NetworkSettings.IPAddress }} {{ .Name }}' | sed 's/ \// /'
}

# Drop the Ports column from `docker ps` by default; anything else (including
# an explicit --format) passes straight through to the real binary.
function docker(){
    if [[ "$1" == "ps" ]]; then
        shift
        if [[ "$*" == *--format* ]]; then
            command docker ps "$@"
        else
            command docker ps --format 'table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Names}}' "$@"
        fi
    else
        command docker "$@"
    fi
}
