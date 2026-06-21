# Load optional Zsh plugins from common package-manager and user locations.
# This file sorts late so syntax highlighting is initialized after other plugins.

# Catppuccin Mocha: dim the autosuggestion to overlay0 (read at suggestion time).
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6c7086'

function _load_zsh_plugins() {
  local root plugin_path
  local -a plugin_roots

  plugin_roots=(
    "${XDG_DATA_HOME:-${HOME}/.local/share}/zsh/plugins"
    "${HOMEBREW_PREFIX:+${HOMEBREW_PREFIX}/share}"
    /opt/homebrew/share
    /usr/local/share
    /home/linuxbrew/.linuxbrew/share
    "${HOME}/.linuxbrew/share"
    /brew/share
    /usr/share
    /usr/share/zsh/plugins
  )

  _source_first_zsh_plugin() {
    local relative_path

    for relative_path in "$@"; do
      for root in "${plugin_roots[@]}"; do
        plugin_path="${root}/${relative_path}"
        if [[ -r "${plugin_path}" ]]; then
          source "${plugin_path}"
          return 0
        fi
      done
    done

    return 1
  }

  _source_first_zsh_plugin \
    zsh-autosuggestions/zsh-autosuggestions.zsh

  _source_first_zsh_plugin \
    fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh \
    zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh ||
    _source_first_zsh_plugin \
      zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

  unfunction _source_first_zsh_plugin
}

_load_zsh_plugins
unfunction _load_zsh_plugins
