[[ $+commands[direnv] -lt 1 ]] && return

eval "$(direnv hook zsh)"
