is-executable xh || return

export XH_CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/xh"

autoload -Uz _xh command_completion
(( ${+_comps} )) || typeset -g -A _comps
_comps[xh]=_xh
command_completion "${ZSH_CACHE_DIR}/completions/_xh" xh --generate=complete-zsh &|
