is-executable op || return

# Keep op's own completion definition fresh.
if [[ ! -f "${ZSH_CACHE_DIR}/completions/_op" ]]; then
  autoload -Uz _op
  typeset -g -A _comps
  _comps[op]=_op
fi
op completion zsh >| "${ZSH_CACHE_DIR}/completions/_op" &|

# 1Password CLI plugin wrappers.
#
# These previously lived in the op-generated ~/.op/plugins.sh, but that file is
# machine-specific, untracked, and overwritten by `op plugin init`. Define them
# here instead: version-controlled, portable, and as functions (not aliases) so
# shell completion resolves to the wrapped command's own completer rather than
# completing `op`. Each is guarded on its tool being installed; add new plugins
# here after running `op plugin init <tool>`.
#
# gh is intentionally NOT wrapped: it uses native keyring auth (`gh auth login`,
# account dewab74). The op gh plugin injects GH_TOKEN, which overrides the
# keyring with a stale token and causes "HTTP 401: Bad credentials".
for _op_plugin in tea vault; do
  is-executable "${_op_plugin}" && functions[$_op_plugin]="op plugin run -- ${_op_plugin} \"\$@\""
done
unset _op_plugin

if is-executable step; then
  step() {
    # All step-ca secrets live in one 1Password item. ~/.step/secret.txt.tpl holds
    # the password pointer (op://vault/item/password), so nothing 1Password-specific
    # is hardcoded here. Derive the item, take the provisioner from its username
    # field, and stream the password via process substitution — never written to disk.
    local _pwref _item
    _pwref="$(<"${HOME}/.step/secret.txt.tpl")"
    _item="${_pwref%/*}"
    STEP_PROVISIONER="$(op read "${_item}/username")" \
    STEP_PROVISIONER_PASSWORD_FILE=<(op read "${_pwref}") \
      command step "$@"
  }
fi
