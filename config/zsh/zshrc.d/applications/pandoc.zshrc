is-executable pandoc || return

autoload -Uz _pandoc command-completion
(( ${+_comps} )) || typeset -g -A _comps
_comps[pandoc]=_pandoc
# pandoc 3.11+ emits a native zsh completer; the old --bash-completion flag
# is deprecated (and produced a bash script, so completion never worked).
command-completion "${ZSH_CACHE_DIR}/completions/_pandoc" pandoc --completion=zsh &|
