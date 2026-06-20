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

# Carapace registers its completer for every command it knows, including ones
# whose native completion is richer/dynamic. gh, for example, completes live PRs,
# repos, branches and aliases via `gh completion zsh`, whereas Carapace only has a
# static command/flag spec. Restore the native completer for those commands
# (configurable via CARAPACE_NATIVE_COMPLETIONS; defaults to gh).
for _carapace_native in ${=CARAPACE_NATIVE_COMPLETIONS-gh}; do
  is-executable "${_carapace_native}" && compdef "_${_carapace_native}" "${_carapace_native}" 2>/dev/null
done

command_completion "${_carapace_completion}" carapace _carapace zsh &|

unset _carapace_completion _carapace_native
