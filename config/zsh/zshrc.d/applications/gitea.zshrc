is-executable tea || return

_tea() {

  local -a opts
  local cur
  cur=${words[-1]}
  # Use `command` so completion runs the real tea binary rather than the op
  # plugin wrapper function (which would trigger a 1Password prompt on every
  # TAB). tea uses urfave/cli's --generate-shell-completion (the older
  # --generate-bash-completion flag was removed).
  if [[ "$cur" == "-"* ]]; then
    opts=("${(@f)$(_CLI_ZSH_AUTOCOMPLETE_HACK=1 command ${words[@]:0:#words[@]-1} ${cur} --generate-shell-completion)}")
  else
    opts=("${(@f)$(_CLI_ZSH_AUTOCOMPLETE_HACK=1 command ${words[@]:0:#words[@]-1} --generate-shell-completion)}")
  fi

  if [[ "${opts[1]}" != "" ]]; then
    _describe 'values' opts
  else
    _files
  fi

  return
}

compdef _tea tea
