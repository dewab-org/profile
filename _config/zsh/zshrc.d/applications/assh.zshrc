is-executable assh || return

alias ssh="assh wrapper ssh --"

source <(assh completion zsh)
compdef _assh assh