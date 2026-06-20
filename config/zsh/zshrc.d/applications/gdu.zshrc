# Homebrew coreutils provides 'gdu' (GNU du), which shadows dundee's interactive
# disk-usage analyzer — Homebrew installs that as 'gdu-go' to avoid the clash.
# Prefer the analyzer under the bare 'gdu' name when it is available.
is-executable gdu-go || return

alias gdu=gdu-go
