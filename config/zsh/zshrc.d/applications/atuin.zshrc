is-executable atuin || return

_atuin_completion="${ZSH_CACHE_DIR}/completions/_atuin"
_atuin_theme=catppuccin-mocha-mauve
_atuin_theme_file="${XDG_CONFIG_HOME}/atuin/themes/${_atuin_theme}.toml"

# Always autoload; zsh will pick the compiled .zwc if present
autoload -Uz _atuin command_completion
(( ${+_comps} )) || typeset -g -A _comps
_comps[atuin]=_atuin

command_completion "${_atuin_completion}" atuin gen-completions --shell zsh &|

if is-readable "${_atuin_theme_file}" &&
  [[ "$(atuin config get theme.name 2>/dev/null)" != "${_atuin_theme}" ]]; then
  atuin config set --type string theme.name "${_atuin_theme}" >/dev/null
fi

if [[ "$(atuin config get style 2>/dev/null)" != full ]]; then
  atuin config set --type string style full >/dev/null
fi

eval "$(atuin init zsh)"

unset _atuin_completion _atuin_theme _atuin_theme_file
