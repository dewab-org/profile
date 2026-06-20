# Resolve the fd binary. Debian/Ubuntu ship it as 'fdfind' to avoid a name clash.
# Check $commands (real binaries only) before aliasing, since the alias would
# otherwise satisfy a later command -v / is-executable check.
if (( $+commands[fd] )); then
  _fd_bin=fd
elif (( $+commands[fdfind] )); then
  _fd_bin=fdfind
  alias fd=fdfind          # Ubuntu support: make `fd` work interactively
else
  return
fi

# Use fd as the default command for fzf (resolved binary so it works on Ubuntu)
is-executable fzf && {
  export FZF_DEFAULT_COMMAND="$_fd_bin --hidden --follow --strip-cwd-prefix --exclude .git"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="$_fd_bin --type=d --hidden --follow --strip-cwd-prefix --exclude .git"
}

# Shell completion (regenerated/cached by command_completion)
autoload -Uz _fd command_completion
(( ${+_comps} )) || typeset -g -A _comps
_comps[fd]=_fd
command_completion "${ZSH_CACHE_DIR}/completions/_fd" "$_fd_bin" --gen-completions zsh &|

# fd colorizes paths via LS_COLORS, which is set by vivid.zshrc (Catppuccin Mocha).

unset _fd_bin
