is-executable vivid || return

# vivid generates a full LS_COLORS database from a theme. Generating on every
# shell start is slow, so cache the output and only regenerate when missing.
_vivid_theme=catppuccin-mocha
_vivid_cache="${ZSH_CACHE_DIR}/lscolors-${_vivid_theme}"

if [[ ! -s "$_vivid_cache" ]]; then
  vivid generate "$_vivid_theme" >| "$_vivid_cache" 2>/dev/null
fi
[[ -s "$_vivid_cache" ]] && export LS_COLORS="$(<"$_vivid_cache")"

# .zshrc applies completion list-colors before application scripts run (while
# LS_COLORS is still empty); re-apply now that it is populated.
[[ -n "$LS_COLORS" ]] && zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

unset _vivid_theme _vivid_cache
