# Carapace completion (rich-native-first).
# Loads after application-specific completion files. Rich native completers are
# preferred — real _<tool> functions, often dynamic (e.g. gh completes live
# PRs/repos, kubectl completes live pods/namespaces). Carapace handles everything
# else: commands with no native completer, and those whose only "native" completer
# is a thin bridge (bash complete -C, argcomplete, gnu_generic) that Carapace beats.
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

# Restore native completers, but only the genuinely rich ones. Thin "bridge"
# completers are usually thinner than Carapace's maintained spec, so leave those
# on Carapace:
#   _bash_complete -C <cmd>  the tool's own `complete -C` bash shim
#   _*_argcomplete           Python argcomplete shim
#   _gnu_generic             generic --help scraper
# Bonus: those bridges run the command to complete, which for op-wrapped tools
# (e.g. vault) triggers a 1Password prompt on TAB; Carapace's static spec doesn't.
# CARAPACE_FORCE_COMPLETIONS keeps a command on Carapace even with a rich native one.
for _carapace_cmd in ${(k)_carapace_native_snapshot}; do
  [[ "${_comps[$_carapace_cmd]}" == _carapace_completer ]] || continue
  [[ " ${CARAPACE_FORCE_COMPLETIONS} " == *" ${_carapace_cmd} "* ]] && continue
  _carapace_native=${_carapace_native_snapshot[$_carapace_cmd]}
  case "${_carapace_native}" in
    _bash_complete*|*_argcomplete|_gnu_generic) continue ;;
  esac
  compdef "${_carapace_native}" "${_carapace_cmd}" 2>/dev/null
done

command_completion "${_carapace_completion}" carapace _carapace zsh &|

unset _carapace_completion _carapace_cmd _carapace_native
unset _carapace_native_snapshot