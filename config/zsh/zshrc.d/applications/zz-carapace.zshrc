# Carapace completion experiment.
# Load after application-specific completion files so supported commands use
# Carapace while unsupported commands retain their native Zsh completions.
[[ "${CARAPACE_COMPLETIONS:-1}" == 1 ]] || return
is-executable carapace || return

_carapace_completion="${ZSH_CACHE_DIR}/completions/_carapace"

autoload -Uz command_completion

# The first shell needs a completion definition to source. Subsequent daily
# refreshes can happen in the background through command_completion.
if [[ ! -s "${_carapace_completion}" ]]; then
  carapace _carapace zsh >| "${_carapace_completion}" || return
fi

if [[ ! -e "${_carapace_completion}.zwc" || "${_carapace_completion}" -nt "${_carapace_completion}.zwc" ]]; then
  zcompile -R -- "${_carapace_completion}.zwc" "${_carapace_completion}" 2>/dev/null
fi

source "${_carapace_completion}"
command_completion "${_carapace_completion}" carapace _carapace zsh &|

unset _carapace_completion
