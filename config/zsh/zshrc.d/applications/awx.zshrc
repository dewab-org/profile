is-executable awx || return

autoload -Uz awx-login && awx-login
