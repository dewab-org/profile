is-executable eza || return

# Replace some ls aliases with eza
alias ll='eza --classify --long --icons --color-scale --all'
alias l.='eza --list-dirs .* --icons --color-scale'
alias la='eza --classify --icons --color-scale --all'
