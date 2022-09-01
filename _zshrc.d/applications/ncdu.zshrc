[[ $+commands[ncdu] -lt 1 ]] && return

is-at-least 2.0.0 $(ncdu -V | awk '{print $NF}') && alias ncdu='ncdu --color=dark'