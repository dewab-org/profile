is-executable pandoc || return

# Enable ZSH compatibility mode
autoload bashcompinit && bashcompinit

if [[ ! -f "${ZSH_CACHE_DIR}/completions/_pandoc" ]]; then
  pandoc --bash-completion >| "${ZSH_CACHE_DIR}/completions/_pandoc" &|
  source <(cat "${ZSH_CACHE_DIR}/completions/_pandoc")
else
  source <(cat "${ZSH_CACHE_DIR}/completions/_pandoc")
fi
