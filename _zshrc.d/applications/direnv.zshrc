local PROG=$(command -v direnv)
[ ! -x "${PROG}" ] && return

eval "$(${PROG} hook zsh)"
