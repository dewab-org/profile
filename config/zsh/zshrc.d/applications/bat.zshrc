is-executable bat && alias cat=bat
is-executable batcat && alias cat=batcat
is-executable batcat && alias bat=batcat

# Always autoload; zsh will pick the compiled .zwc if present
autoload -Uz _bat command_completion
(( ${+_comps} )) || typeset -g -A _comps
_comps[bat]=_bat

command_completion "${ZSH_CACHE_DIR}/completions/_bat" bat --completion zsh &|
