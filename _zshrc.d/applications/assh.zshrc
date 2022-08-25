[[ $+commands[assh] -lt 1 ]] && return

alias ssh="assh wrapper ssh"

source <(assh completion zsh)
compdef _assh assh