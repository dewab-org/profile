is-executable fzf || return

is-readable ${XDG_DATA_HOME}/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh && source ${XDG_DATA_HOME}/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh

# Load fzf key bindings (ctrl-t, ctrl-r, alt-c)
_fzf_key_bindings_scripts=(
  "${HOMEBREW_PREFIX}/opt/fzf/shell/key-bindings.zsh"
  "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"
  "/usr/local/opt/fzf/shell/key-bindings.zsh"
  "${HOME}/.fzf/shell/key-bindings.zsh"
  "/usr/share/fzf/key-bindings.zsh"
)

for _fzf_key_binding_script in "${_fzf_key_bindings_scripts[@]}"; do
  if is-readable "${_fzf_key_binding_script}"; then
    source "${_fzf_key_binding_script}"
    break
  fi
done

unset _fzf_key_bindings_scripts _fzf_key_binding_script

# Load fzf command completions
_fzf_completion_scripts=(
  "${HOMEBREW_PREFIX}/opt/fzf/shell/completion.zsh"
  "/opt/homebrew/opt/fzf/shell/completion.zsh"
  "/usr/local/opt/fzf/shell/completion.zsh"
  "${HOME}/.fzf/shell/completion.zsh"
  "/usr/share/fzf/completion.zsh"
  "/usr/share/doc/fzf/examples/completion.zsh"
)

for _fzf_completion_script in "${_fzf_completion_scripts[@]}"; do
  if is-readable "${_fzf_completion_script}"; then
    source "${_fzf_completion_script}"
    break
  fi
done

unset _fzf_completion_scripts _fzf_completion_script

# ── Catppuccin Mocha theme + sensible defaults (applies to every fzf surface) ──
export FZF_DEFAULT_OPTS="\
--height 50% --layout=reverse --border --info=inline \
--bind 'ctrl-/:toggle-preview,ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down' \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a,border:#6c7086,label:#cdd6f4"

# Previews for the key-binding widgets (Ctrl-T files, Alt-C dirs).
is-executable bat && export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {} 2>/dev/null || eza -1 --color=always --icons {} 2>/dev/null || cat {}' --preview-window=right:55%:wrap"
is-executable eza && export FZF_ALT_C_OPTS="--preview 'eza -1 --color=always --icons {}' --preview-window=right:45%"

# fzf-tab: inherit the theme above, and preview files/dirs while completing.
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons $realpath 2>/dev/null'
zstyle ':fzf-tab:complete:*:*' fzf-preview '
  if [[ -d $realpath ]]; then eza -1 --color=always --icons $realpath 2>/dev/null
  elif [[ -f $realpath ]]; then bat --color=always --style=numbers --line-range=:200 $realpath 2>/dev/null || cat $realpath
  else echo $realpath; fi'
