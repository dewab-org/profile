is-executable tldr || return

# tealdeer honours TEALDEER_CONFIG_DIR; point it at the XDG location so the
# repo-managed config.toml is found on macOS too (Linux already defaults here).
# The cache stays at its default ($XDG_CACHE_HOME/tealdeer on Linux) because the
# TEALDEER_CACHE_DIR env var is deprecated in favour of the config's cache_dir.
export TEALDEER_CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/tealdeer"

# Pre-warm the page cache once, in the background, so the first lookup is
# instant and works offline. auto_update in config.toml keeps it fresh after.
[[ -d "${XDG_CACHE_HOME:-${HOME}/.cache}/tealdeer/tldr-pages" ]] || tldr --update &|
