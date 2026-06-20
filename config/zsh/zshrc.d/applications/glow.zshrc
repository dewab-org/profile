is-executable glow || return

# glow has no styles-by-name lookup and does not expand ~/env vars in its config
# 'style' field, so apply the Catppuccin Mocha theme via the --style flag (highest
# precedence). The path is resolved at call time, keeping the tracked config portable.
alias glow='command glow --style "${XDG_CONFIG_HOME:-$HOME/.config}/glow/catppuccin-mocha.json"'
