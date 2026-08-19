is-executable fx || return

# fx does not currently expose custom named themes. The purple built-in is the
# closest fit for the rest of the Catppuccin Mocha profile.
export FX_THEME="🟣"
export FX_NO_MOUSE=true

autoload -Uz _fx command-completion
(( ${+_comps} )) || typeset -g -A _comps
_comps[fx]=_fx
command-completion "${ZSH_CACHE_DIR}/completions/_fx" fx --comp zsh &|
