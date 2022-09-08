if (( $+commands[kubectl] )); then
  # If the completion file does not exist, generate it and then source it
  # Otherwise, source it and regenerate in the background
  if [[ ! -f "$ZSH_CACHE_DIR/completions/_kubectl" ]]; then
    kubectl completion zsh | tee "$ZSH_CACHE_DIR/completions/_kubectl" >/dev/null
    source "$ZSH_CACHE_DIR/completions/_kubectl"
  else
    source "$ZSH_CACHE_DIR/completions/_kubectl"
    kubectl completion zsh | tee "$ZSH_CACHE_DIR/completions/_kubectl" >/dev/null &|
  fi
fi

alias k=kubectl

# if (( $+commands[kompose] )); then
#   # If the completion file does not exist, generate it and then source it
#   # Otherwise, source it and regenerate in the background
#   if [[ ! -f "$ZSH_CACHE_DIR/completions/_kompose" ]]; then
#     kompose completion zsh | tee "$ZSH_CACHE_DIR/completions/_kompose" >/dev/null
#     source "$ZSH_CACHE_DIR/completions/_kompose"
#   else
#     source "$ZSH_CACHE_DIR/completions/_kompose"
#     kompose completion zsh | tee "$ZSH_CACHE_DIR/completions/_kompose" >/dev/null &|
#   fi
# fi