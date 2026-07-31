# Load optional Zsh plugins from common package-manager and user locations.
# This file sorts late so syntax highlighting is initialized after other plugins.

# Catppuccin Mocha: dim the autosuggestion to overlay0 (read at suggestion time).
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6c7086'

# Bind widgets once at startup instead of re-wrapping every ZLE widget on each
# precmd. Without this, zsh-autosuggestions rewraps all widgets every prompt;
# with atuin + fast-syntax-highlighting also wrapping widgets, that compounds
# in long-lived shells and surfaces as multi-second history-recall stalls.
# Must be set before zsh-autosuggestions is sourced (below).
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

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
          "${_plugin_source_cmd[@]}" "${plugin_path}"
          return 0
        fi
      done
    done

    return 1
  }

  # zsh-defer postpones sourcing until after the first prompt renders, cutting
  # first-prompt lag. It must itself load synchronously; the plugins below are
  # then deferred (in order) when it is available, sourced directly otherwise.
  local -a _plugin_source_cmd=(source)
  _source_first_zsh_plugin zsh-defer/zsh-defer.plugin.zsh &&
    _plugin_source_cmd=(zsh-defer source)

  # Remind when a typed command already has a shorter alias defined.
  _source_first_zsh_plugin \
    zsh-you-should-use/you-should-use.plugin.zsh

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
