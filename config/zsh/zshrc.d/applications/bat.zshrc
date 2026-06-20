# Resolve the bat binary. Debian/Ubuntu ship it as 'batcat' to avoid a name clash.
if (( $+commands[bat] )); then
  _bat_bin=bat
elif (( $+commands[batcat] )); then
  _bat_bin=batcat
  alias bat=batcat         # Ubuntu support: make `bat` work interactively
else
  return
fi

alias cat="$_bat_bin"

# Shell completion (regenerated/cached by command_completion)
autoload -Uz _bat command_completion
(( ${+_comps} )) || typeset -g -A _comps
_comps[bat]=_bat
command_completion "${ZSH_CACHE_DIR}/completions/_bat" "$_bat_bin" --completion zsh &|

unset _bat_bin
