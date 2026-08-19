TANZU_COMMANDS=( "tanzu" "tmc" "kapp" "kctrl" "imgpkg" "ytt" "vks-support-bundler" "velero" )

for cmd in "${TANZU_COMMANDS[@]}"; do
  if is-executable "$cmd"; then
    comp_file="${ZSH_CACHE_DIR}/completions/_${cmd}"
    autoload -Uz "_${cmd}" command-completion
    (( ${+_comps} )) || typeset -g -A _comps
    _comps["$cmd"]="_${cmd}"
    command-completion "$comp_file" "$cmd" completion zsh &|
  fi
done
