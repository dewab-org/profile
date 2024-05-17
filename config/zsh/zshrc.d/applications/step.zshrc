is-executable step || return

## This does not seem to work.  I wish I knew why.

# if [[ ! -f "${ZSH_CACHE_DIR}/completions/_step" ]]; then
#   autoload -Uz _step
#   typeset -g -A _comps
#   _comps[step]=_step
# fi

# step completion zsh >| "${ZSH_CACHE_DIR}/completions/_step" &|

if [[ ! -f "${ZSH_CACHE_DIR}/completions/_step" ]]; then
  step completion zsh >| "${ZSH_CACHE_DIR}/completions/_step" &|
  source <(cat "${ZSH_CACHE_DIR}/completions/_step")
else
  source <(cat "${ZSH_CACHE_DIR}/completions/_step")
fi
