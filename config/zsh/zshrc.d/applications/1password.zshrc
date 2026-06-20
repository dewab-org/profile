is-executable op || return

# source <(op completion zsh)

if [[ ! -f "${ZSH_CACHE_DIR}/completions/_op" ]]; then
  autoload -Uz _op
  typeset -g -A _comps
  _comps[op]=_op
fi

op completion zsh >| "${ZSH_CACHE_DIR}/completions/_op" &|

is-readable "${HOME}/.op/plugins.sh" && source "${HOME}/.op/plugins.sh"

# op plugins.sh aliases commands to "op plugin run -- <cmd>". With complete_aliases
# off (our default), zsh expands such an alias before completing, so e.g.
# `gh <TAB>` completes `op` instead of gh. Convert these aliases to functions —
# functions are not expanded for completion, so zsh uses the wrapped command's
# own completer (carapace/native). Mirrors how plugins.sh already defines `step`.
if [[ -n "${OP_PLUGIN_ALIASES_SOURCED}" ]]; then
  for _op_alias in ${(k)aliases}; do
    if [[ "${aliases[$_op_alias]}" == "op plugin run -- "* ]]; then
      functions[$_op_alias]="${aliases[$_op_alias]} \"\$@\""
      unalias -- "${_op_alias}"
    fi
  done
  unset _op_alias
fi
