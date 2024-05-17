is-executable kubectl || return

if [[ ! -f "${ZSH_CACHE_DIR}/completions/_kubectl" ]]; then
  autoload -Uz _kubectl
  typeset -g -A _comps
  _comps[kubectl]=_kubectl
fi

kubectl completion zsh >| "${ZSH_CACHE_DIR}/completions/_kubectl" &|

alias k=kubectl
