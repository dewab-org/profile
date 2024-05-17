is-executable az || return
is-executable register-python-argcomplete || return

# Enable ZSH compatibility mode
autoload bashcompinit && bashcompinit

if [[ ! -f "${ZSH_CACHE_DIR}/completions/_az" ]]; then
  register-python-argcomplete az >| "${ZSH_CACHE_DIR}/completions/_az" &|
  source <(cat "${ZSH_CACHE_DIR}/completions/_az")
else
  source <(cat "${ZSH_CACHE_DIR}/completions/_az")
fi
