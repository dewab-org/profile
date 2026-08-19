is-executable yq || return

# source <(yq shell-completion zsh)
autoload -Uz _yq command-completion
(( ${+_comps} )) || typeset -g -A _comps
_comps[yq]=_yq
command-completion "${ZSH_CACHE_DIR}/completions/_yq" yq shell-completion zsh &|
