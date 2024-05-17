is-executable tmc || return

# source <(tmc completion zsh)
# compdef _tmc tmc

if [[ ! -f "${ZSH_CACHE_DIR}/completions/_tmc" ]]; then
  autoload -Uz _tmc
  typeset -g -A _comps
  _comps[tmc]=_tmc
fi

tmc completion zsh >| "${ZSH_CACHE_DIR}/completions/_tmc" &|
