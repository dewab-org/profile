local ANSIBLE=$(command -v ansible )
[ ! -x "${ANSIBLE}" ] && return

#local ANSIBLE_PYTHON=$(head -1 ${ANSIBLE})
#local ANSIBLE_PYTHON_PATH=$(dirname ${${ANSIBLE_PYTHON}:s/\#\!/})

#alias ansible-pip="${ANSIBLE_PYTHON_PATH}/pip3"
alias ansible-pip="/usr/local/opt/ansible/libexec/bin/pip"
alias ansible-up='find ~/.ansible ~/ansible -name ".git" -exec dirname {} \; | xargs -n1 -I % git -C % pull'

if [ -x "${ANSIBLE_PATH}/tower-cli" ] ; then
	alias tower-cli="${ANSIBLE_PATH}/tower-cli"
fi

unset ANSIBLE
