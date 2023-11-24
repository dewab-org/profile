is-executable step || return

# source <(step completion zsh)

if [[ ! -f "${ZSH_CACHE_DIR}/completions/_step" ]]; then
  autoload -Uz _step
  typeset -g -A _comps
  _comps[step]=_step
fi

step completion zsh >| "${ZSH_CACHE_DIR}/completions/_step" &|
