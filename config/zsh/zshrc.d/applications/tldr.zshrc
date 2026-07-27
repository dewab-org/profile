is-executable tldr || return

# `tldr` may be tealdeer (Linux, from the tools manifest) or tlrc (macOS, the
# Homebrew `tlrc` formula). Both provide the `tldr` command but use different
# config schemas and cache layouts; the wiring below covers both clients.

# tealdeer honours TEALDEER_CONFIG_DIR; point it at the XDG location so its
# repo-managed config.toml is found. tlrc ignores this var (its config is
# symlinked into place by the repo manifest), so exporting it is harmless there.
export TEALDEER_CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/tealdeer"

# Pre-warm the page cache once, in the background and silently, so the first
# lookup is instant and works offline; each client keeps it fresh afterwards via
# auto_update. Only run when no cache exists in any known location — tealdeer
# stores pages under tldr-pages/, tlrc under pages.en/. Redirecting output means
# a stray run can never spam interactive shells at startup.
if [[ ! -d "${XDG_CACHE_HOME:-${HOME}/.cache}/tealdeer/tldr-pages" \
   && ! -d "${HOME}/Library/Caches/tealdeer/tldr-pages" \
   && ! -d "${XDG_CACHE_HOME:-${HOME}/.cache}/tlrc/pages.en" \
   && ! -d "${HOME}/Library/Caches/tlrc/pages.en" ]]; then
  tldr --update >/dev/null 2>&1 &|
fi
