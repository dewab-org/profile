is-executable ncdu || return

is-at-least 2.0.0 ${$(ncdu -V)[2]} && alias ncdu='ncdu --color=dark'
