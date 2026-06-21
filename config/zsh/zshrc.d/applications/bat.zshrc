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

# Debian/Ubuntu package a native _batcat completer and older bat releases do
# not support `--completion`. Prefer the packaged completer in that case.
(( ${+_comps} )) || typeset -g -A _comps
if (( $+commands[batcat] )); then
  autoload -Uz _batcat
  _comps[bat]=_batcat
  _comps[batcat]=_batcat
elif "$_bat_bin" --help 2>/dev/null | command grep -q -- '--completion'; then
  # Newer bat releases can generate their own completion definition.
  autoload -Uz _bat command_completion
  _comps[bat]=_bat
  command_completion "${ZSH_CACHE_DIR}/completions/_bat" "$_bat_bin" --completion zsh &|
fi

# Colored, themed man pages via bat (uses bat's Catppuccin Mocha theme).
export MANPAGER="sh -c 'col -bx | ${_bat_bin} --language man --plain'"
export MANROFFOPT="-c"

unset _bat_bin
