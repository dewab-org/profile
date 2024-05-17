is-executable yq || return

# source <(yq shell-completion zsh)

if [[ ! -f "${ZSH_CACHE_DIR}/completions/_yq" ]]; then
  autoload -Uz _yq
  typeset -g -A _comps
  _comps[yq]=_yq
fi

yq shell-completion zsh >| "${ZSH_CACHE_DIR}/completions/_yq" &|
