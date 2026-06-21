is-executable terraform || return

# Shared provider plugin cache (XDG). Providers are downloaded once and reused
# across every Terraform/OpenTofu configuration instead of into each project's
# per-directory .terraform dir. Terraform won't create the dir itself, so ensure
# it exists. Also honored by `tofu`.
export TF_PLUGIN_CACHE_DIR="${XDG_CACHE_HOME:-${HOME}/.cache}/terraform/plugin-cache"
[[ -d "${TF_PLUGIN_CACHE_DIR}" ]] || mkdir -p "${TF_PLUGIN_CACHE_DIR}"

complete -C terraform terraform
