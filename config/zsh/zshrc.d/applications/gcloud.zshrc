is-executable gcloud || return

is-readable ${HOMEBREW_PREFIX}/share/google-cloud-sdk/path.zsh.inc && source ${HOMEBREW_PREFIX}/share/google-cloud-sdk/path.zsh.inc
is-readable ${HOMEBREW_PREFIX}/share/google-cloud-sdk/completion.zsh.inc && source ${HOMEBREW_PREFIX}/share/google-cloud-sdk/completion.zsh.inc
