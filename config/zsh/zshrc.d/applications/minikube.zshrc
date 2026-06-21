is-executable minikube || return

# Move configuration to .config
export MINIKUBE_HOME="${XDG_DATA_HOME}/minikube"

autoload -Uz _minikube command_completion
(( ${+_comps} )) || typeset -g -A _comps
_comps[minikube]=_minikube
command_completion "${ZSH_CACHE_DIR}/completions/_minikube" minikube completion zsh &|
