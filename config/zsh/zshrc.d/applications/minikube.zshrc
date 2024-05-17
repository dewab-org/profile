is-executable minikube || return

# Move configuration to .config
export MINIKUBE_HOME="${XDG_DATA_HOME}/minikube"
