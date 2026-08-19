is-executable gh || return

autoload -Uz _gh command-completion
(( ${+_comps} )) || typeset -g -A _comps
_comps[gh]=_gh
command-completion "${ZSH_CACHE_DIR}/completions/_gh" gh completion -s zsh &|
