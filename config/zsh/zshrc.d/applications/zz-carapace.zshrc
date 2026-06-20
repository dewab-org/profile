# Carapace completion (native-first).
# Loads after application-specific completion files. Native completions are
# preferred wherever they exist — they are richer and often dynamic (e.g. gh
# completes live PRs/repos, kubectl completes live pods/namespaces) — and
# Carapace fills in completions for the many commands that have no native one.
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

# Snapshot the native completers registered so far (per-app completion files plus
# compinit's scan of fpath) before Carapace overrides them.
typeset -gA _carapace_native_snapshot
_carapace_native_snapshot=()
for _carapace_cmd in ${(k)_comps}; do
  _carapace_native_snapshot[$_carapace_cmd]="${_comps[$_carapace_cmd]}"
done

source "${_carapace_completion}"

# Restore native completers (richer than Carapace's static specs). Carapace keeps
# the commands that had no native completion. Commands listed in
# CARAPACE_FORCE_COMPLETIONS stay on Carapace even when a native completer exists.
for _carapace_cmd in ${(k)_carapace_native_snapshot}; do
  [[ "${_comps[$_carapace_cmd]}" == _carapace_completer ]] || continue
  [[ " ${CARAPACE_FORCE_COMPLETIONS} " == *" ${_carapace_cmd} "* ]] && continue
  compdef "${_carapace_native_snapshot[$_carapace_cmd]}" "${_carapace_cmd}" 2>/dev/null
done

command_completion "${_carapace_completion}" carapace _carapace zsh &|

unset _carapace_completion _carapace_cmd
unset _carapace_native_snapshot