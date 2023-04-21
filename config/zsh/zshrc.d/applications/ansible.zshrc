is-executable ansible || return

# added 2022-01-08 to fix issue with ansible crashing running win_* modules
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

#alias ansible="OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES ansible"
#alias ansible-playbook="OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES ansible-playbook"

# if I wanted to do XDG for Ansible Configuration
# export ANSIBLE_HOME="${XDG_CONFIG_HOME}/ansible"
# export ANSIBLE_CONFIG="${XDG_CONFIG_HOME}/ansible.cfg"
# export ANSIBLE_GALAXY_CACHE_DIR="${XDG_CACHE_HOME}/ansible/galaxy_cache"