is-executable assh || return

# I don't think I really need this, but it's here for reference
# alias ssh="assh wrapper ssh --"

autoload -Uz _assh command-completion
(( ${+_comps} )) || typeset -g -A _comps
_comps[assh]=_assh
command-completion "${ZSH_CACHE_DIR}/completions/_assh" assh completion zsh &|
