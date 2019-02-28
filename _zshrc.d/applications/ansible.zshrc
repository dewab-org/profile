local ANSIBLE=$(command -v ansible )
[ ! -x "${ANSIBLE}" ] && return

ANSIBLE_PATH="$(dirname $( head -1 ${ANSIBLE} | sed -e 's/^\#\!//' ))"
alias ansible-pip="${ANSIBLE_PATH}/pip3"

if [ -x "${ANSIBLE_PATH}/tower-cli" ] ; then
	alias tower-cli="${ANSIBLE_PATH}/tower-cli"
fi

unset ANSIBLE
