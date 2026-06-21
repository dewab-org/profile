# Resolve preferred implementations after all application integrations load.
# Keep policy here when multiple installed tools provide the same shell feature.

# History search: prefer Atuin's context-aware history database and TUI. Fall
# back to fzf's shell-history widget, then leave Zsh's native binding untouched.
if (( ${+widgets[atuin-search]} )); then
  bindkey -M emacs '^R' atuin-search
  bindkey -M viins '^R' atuin-search-viins

  # Atuin provides a prefix-aware Up Arrow search in addition to general Ctrl-R
  # history search. Bind both common terminal encodings.
  bindkey -M emacs '^[[A' atuin-up-search
  bindkey -M emacs '^[OA' atuin-up-search
  bindkey -M viins '^[[A' atuin-up-search-viins
  bindkey -M viins '^[OA' atuin-up-search-viins
  bindkey -M vicmd '^[[A' atuin-up-search-vicmd
  bindkey -M vicmd '^[OA' atuin-up-search-vicmd
  bindkey -M vicmd 'k' atuin-up-search-vicmd
elif (( ${+widgets[fzf-history-widget]} )); then
  bindkey -M emacs '^R' fzf-history-widget
  bindkey -M viins '^R' fzf-history-widget
fi
