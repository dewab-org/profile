# Homebrew coreutils provides 'gdu' (GNU du), which shadows dundee's interactive
# disk-usage analyzer — Homebrew installs that as 'gdu-go' to avoid the clash.
# Prefer the analyzer under the bare 'gdu' name when it is available.
is-executable gdu-go || return

alias gdu=gdu-go

autoload -Uz _gdu command_completion
(( ${+_comps} )) || typeset -g -A _comps
_comps[gdu]=_gdu
_comps[gdu-go]=_gdu
command_completion "${ZSH_CACHE_DIR}/completions/_gdu" gdu-go completion zsh &|
