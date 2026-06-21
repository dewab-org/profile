is-executable atuin || return

_atuin_completion="${ZSH_CACHE_DIR}/completions/_atuin"

# Always autoload; zsh will pick the compiled .zwc if present
autoload -Uz _atuin command_completion
(( ${+_comps} )) || typeset -g -A _comps
_comps[atuin]=_atuin

command_completion "${_atuin_completion}" atuin gen-completions --shell zsh &|

eval "$(atuin init zsh)"
