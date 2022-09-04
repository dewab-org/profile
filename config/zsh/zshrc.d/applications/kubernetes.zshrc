if (( $+commands[kubectl] )) ; then
    source <(kubectl completion zsh)
    # source <(kubectl completion zsh | sed 's/kubectl/k/g')
    alias k=kubectl
fi

if (( $+commands[kompose] )) ; then
    source <(kompose completion zsh)
fi