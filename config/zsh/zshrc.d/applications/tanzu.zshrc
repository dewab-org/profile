is-executable tanzu || return

# source <(tanzu completion zsh)
# compdef _tanzu tanzu

if [[ ! -f "${ZSH_CACHE_DIR}/completions/_tanzu" ]]; then
  autoload -Uz _tanzu
  typeset -g -A _comps
  _comps[tanzu]=_tanzu
fi

tanzu completion zsh >| "${ZSH_CACHE_DIR}/completions/_tanzu" &|
