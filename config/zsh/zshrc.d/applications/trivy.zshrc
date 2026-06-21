is-executable trivy || return

# Vulnerability/secret/misconfig scanner DB cache under XDG (default on macOS is
# ~/Library/Caches/trivy). trivy creates the dir itself.
export TRIVY_CACHE_DIR="${XDG_CACHE_HOME:-${HOME}/.cache}/trivy"

autoload -Uz _trivy command_completion
(( ${+_comps} )) || typeset -g -A _comps
_comps[trivy]=_trivy
command_completion "${ZSH_CACHE_DIR}/completions/_trivy" trivy completion zsh &|
