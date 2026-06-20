# Resolve the fd binary. Debian/Ubuntu ship it as 'fdfind' to avoid a name clash.
# Check $commands (real binaries only) before aliasing, since is-executable/command -v
# would also match the alias we are about to define.
if (( $+commands[fd] )); then
  _fd_bin=fd
elif (( $+commands[fdfind] )); then
  _fd_bin=fdfind
  alias fd=fdfind          # Ubuntu support: make `fd` work interactively
else
  return
fi

# Use fd as the default command for fzf (use the resolved binary so it works on Ubuntu)
is-executable fzf && {
  export FZF_DEFAULT_COMMAND="$_fd_bin --hidden --follow --strip-cwd-prefix --exclude .git"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="$_fd_bin --type=d --hidden --follow --strip-cwd-prefix --exclude .git"
}

# fd has no theme of its own; it colorizes paths via LS_COLORS. Set a Catppuccin
# Mocha palette for the core file types (also picked up by zsh completion list-colors).
[[ -n "$LS_COLORS" ]] || export LS_COLORS="di=38;2;137;180;250:ln=38;2;148;226;213:so=38;2;245;194;231:pi=38;2;245;194;231:ex=38;2;166;227;161:bd=38;2;249;226;175:cd=38;2;249;226;175:su=38;2;243;139;168:sg=38;2;243;139;168:tw=38;2;137;180;250:ow=38;2;137;180;250:st=38;2;137;180;250:or=38;2;243;139;168:mi=38;2;243;139;168"

unset _fd_bin
