is-executable pandoc || return

autoload -Uz _pandoc command_completion
(( ${+_comps} )) || typeset -g -A _comps
_comps[pandoc]=_pandoc
command_completion "${ZSH_CACHE_DIR}/completions/_pandoc" pandoc --bash-completion &|
