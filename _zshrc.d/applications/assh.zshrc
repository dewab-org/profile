local ASSH=$(command -v assh)
[ ! -x "${ASSH}" ] && return

alias ssh="${ASSH} wrapper ssh"

unset ASSH
