is-executable op || return

# source <(op completion zsh)

if [[ ! -f "${ZSH_CACHE_DIR}/completions/_op" ]]; then
  autoload -Uz _op
  typeset -g -A _comps
  _comps[op]=_op
fi

op completion zsh >| "${ZSH_CACHE_DIR}/completions/_op" &|

# Load opswd function (copies password to clipboard)
autoload -Uz opswd

is-readable "${HOME}/.op/plugins.sh" && source "${HOME}/.op/plugins.sh"
