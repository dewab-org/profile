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
    # All step-ca secrets live in one 1Password item, referenced in
    # ~/.step/provisioner as op://<vault>/<item> — so nothing 1Password-specific
    # is hardcoded here. Fetch username + password in a SINGLE op call (one auth
    # prompt), take the provisioner from the username field, and stream the password
    # via process substitution — never written to disk.
    local _ref _vault _item _json _user _pass
    if ! is-readable "${HOME}/.step/provisioner"; then
      print -u2 "step: ~/.step/provisioner not found; expected an op://<vault>/<item> reference"
      return 1
    fi
    _ref="$(<"${HOME}/.step/provisioner")"   # op://vault/item
    _ref="${_ref#op://}"
    _vault="${_ref%%/*}"
    _item="${_ref#*/}"
    _json="$(op item get "${_item}" --vault "${_vault}" --fields label=username,label=password --format json)" || return
    _user="$(jq -r '.[] | select(.label=="username") | .value' <<<"${_json}")"
    _pass="$(jq -r '.[] | select(.label=="password") | .value' <<<"${_json}")"
    STEP_PROVISIONER="${_user}" \
    STEP_PROVISIONER_PASSWORD_FILE=<(print -r -- "${_pass}") \
      command step "$@"
  }
fi
