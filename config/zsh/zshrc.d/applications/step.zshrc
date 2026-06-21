is-executable step || return

# step is wrapped by an op-plugin function that runs `op inject`, so its completer
# must invoke the real binary via `command` — otherwise every TAB triggers a
# 1Password prompt. step (urfave/cli) uses --generate-bash-completion.
_step() {
  local -a opts
  local cur=${words[-1]}
  if [[ "$cur" == "-"* ]]; then
    opts=("${(@f)$(_CLI_ZSH_AUTOCOMPLETE_HACK=1 command ${words[@]:0:#words[@]-1} ${cur} --generate-bash-completion)}")
  else
    opts=("${(@f)$(_CLI_ZSH_AUTOCOMPLETE_HACK=1 command ${words[@]:0:#words[@]-1} --generate-bash-completion)}")
  fi

  if [[ "${opts[1]}" != "" ]]; then
    _describe 'values' opts
  else
    _files
  fi
}
compdef _step step
