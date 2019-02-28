local NCDU=$(command -v ncdu)
[ ! -x "${NCDU}" ] && return

alias ncdu='ncdu --color=dark'

unset NCDU
