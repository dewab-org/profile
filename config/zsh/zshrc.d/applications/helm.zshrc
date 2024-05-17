is-executable helm || return

if [[ ! -f "${ZSH_CACHE_DIR}/completions/_helm" ]]; then
  autoload -Uz _helm
  typeset -g -A _comps
  _comps[op]=_helm
fi

helm completion zsh >| "${ZSH_CACHE_DIR}/completions/_helm" &|
