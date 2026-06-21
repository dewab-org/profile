# Self-install the current terminal's terminfo when this host lacks it (common
# when SSHing in from Ghostty/kitty to a box without the entry), so keys and
# colors work. The source ships with the profile; tic installs into ~/.terminfo
# (no root). Only acts when we actually carry that TERM's source.
is-executable tic || return
[[ -n "$TERM" ]] || return
infocmp -x "$TERM" &>/dev/null && return

_terminfo_src="${ZDOTDIR:-$HOME/.config/zsh}/zshrc.d/terminfo/${TERM}.terminfo"
is-readable "${_terminfo_src}" && tic -x "${_terminfo_src}" 2>/dev/null
unset _terminfo_src
