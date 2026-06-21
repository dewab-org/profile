is-executable grype || return

# Vulnerability DB cache under XDG (default ~/.cache/grype/db; pin it to
# XDG_CACHE_HOME so it follows a non-default cache root). grype creates the dir.
export GRYPE_DB_CACHE_DIR="${XDG_CACHE_HOME:-${HOME}/.cache}/grype/db"

autoload -Uz _grype command_completion
(( ${+_comps} )) || typeset -g -A _comps
_comps[grype]=_grype
command_completion "${ZSH_CACHE_DIR}/completions/_grype" grype completion zsh &|
