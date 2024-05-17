is-executable assh || return

alias ssh="assh wrapper ssh --"

# source <(assh completion zsh)
# compdef _assh assh

if [[ ! -f "${ZSH_CACHE_DIR}/completions/_assh" ]]; then
  autoload -Uz _assh
  typeset -g -A _comps
  _comps[assh]=_assh
fi

assh completion zsh >| "${ZSH_CACHE_DIR}/completions/_assh" &|
