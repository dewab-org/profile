is-executable gh || return

if [[ ! -f "${ZSH_CACHE_DIR}/completions/_gh" ]]; then
  autoload -Uz _gh
  typeset -g -A _comps
  _comps[gh]=_gh
fi

command gh completion -s zsh >| "${ZSH_CACHE_DIR}/completions/_gh" &|
