is-executable rg || return

# ripgrep has no default config path; point it at the XDG location.
export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME:-${HOME}/.config}/ripgrep/config"

autoload -Uz _rg command_completion
(( ${+_comps} )) || typeset -g -A _comps
_comps[rg]=_rg
command_completion "${ZSH_CACHE_DIR}/completions/_rg" rg --generate=complete-zsh &|
