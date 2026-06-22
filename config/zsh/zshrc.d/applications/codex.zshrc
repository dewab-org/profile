is-executable codex || return

autoload -Uz _codex command_completion
(( ${+_comps} )) || typeset -g -A _comps
_comps[codex]=_codex
command_completion "${ZSH_CACHE_DIR}/completions/_codex" codex completion zsh &|
