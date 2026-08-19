is-executable gitleaks || return

autoload -Uz _gitleaks command-completion
(( ${+_comps} )) || typeset -g -A _comps
_comps[gitleaks]=_gitleaks
command-completion "${ZSH_CACHE_DIR}/completions/_gitleaks" gitleaks completion zsh &|
