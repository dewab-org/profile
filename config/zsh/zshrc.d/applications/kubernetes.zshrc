# Kubernetes tooling (kubectl, kubecolor, kubectx/kubens, krew)
is-executable kubectl || return

if is-directory "${HOME}/.krew/bin"; then
  append_path PATH "${HOME}/.krew/bin"
fi

typeset -i have_kubecolor=0
is-executable kubecolor && have_kubecolor=1

alias k=kubectl
alias ku='kubectl config use-context'

# Keep kubectl completions available even when kubecolor is aliased to kubectl.
_kubectl_completion_file="${ZSH_CACHE_DIR}/completions/_kubectl"
autoload -Uz _kubectl command_completion
(( ${+_comps} )) || typeset -g -A _comps
command_completion "${_kubectl_completion_file}" kubectl completion zsh &|

autoload -Uz add-zsh-hook
__kube__compdefs() {
  if [[ "${CARAPACE_COMPLETIONS:-1}" == 1 && "${_comps[kubectl]}" == _carapace_completer ]]; then
    # Carapace has no specs for these aliases, so retain native completion.
    compdef _kubectl k
    (( have_kubecolor )) && compdef _kubectl kubecolor
  else
    compdef _kubectl kubectl
    compdef k=kubectl
    (( have_kubecolor )) && compdef kubecolor=kubectl
  fi
  add-zsh-hook -d precmd __kube__compdefs 2>/dev/null
}
add-zsh-hook precmd __kube__compdefs

if (( have_kubecolor )); then
  export KUBECOLOR_CONFIG="${XDG_CONFIG_HOME:-${HOME}/.config}/kubecolor.yaml"
  alias kubectl='kubecolor'
fi

if is-executable kubectx; then
  alias kctx='kubectx'
  alias kns='kubens'
fi

if is-executable helm; then
  alias h=helm

  _helm_completion_file="${ZSH_CACHE_DIR}/completions/_helm"
  autoload -Uz _helm
  _comps[helm]=_helm
  command_completion "${_helm_completion_file}" helm completion zsh &|
fi

if is-executable k9s; then
  _k9s_completion_file="${ZSH_CACHE_DIR}/completions/_k9s"
  autoload -Uz _k9s
  _comps[k9s]=_k9s
  command_completion "${_k9s_completion_file}" k9s completion zsh &|
fi

if is-executable kompose; then
  _kompose_completion_file="${ZSH_CACHE_DIR}/completions/_kompose"
  autoload -Uz _kompose
  _comps[kompose]=_kompose
  command_completion "${_kompose_completion_file}" kompose completion zsh &|
fi
