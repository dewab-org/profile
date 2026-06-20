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
    local tmpfile ret
    tmpfile="$(mktemp -q /tmp/.step.XXXXXX)" || return 1
    op inject -i "${HOME}/.step/secret.txt.tpl" -o "${tmpfile}" -f >/dev/null
    STEP_PROVISIONER="dwhicker@bifrost.cc" STEP_PROVISIONER_PASSWORD_FILE="${tmpfile}" command step "$@"
    ret=$?
    rm -f "${tmpfile}"
    return $ret
  }
fi
