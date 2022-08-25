local KUBECTL=$(command -v kubectl )
[ ! -x "${KUBECTL}" ] && return

alias k=kubectl

source <(kubectl completion zsh)
source <(kubectl completion zsh | sed 's/kubectl/k/g')
