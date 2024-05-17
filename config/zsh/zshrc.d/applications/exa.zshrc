is-executable exa || return

# Replace some ls aliases with exa
alias ll='exa --classify --long --icons --color-scale --all'
alias l.='exa --list-dirs .* --icons --color-scale'
alias la='exa --classify --icons --color-scale --all'
