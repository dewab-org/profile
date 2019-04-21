local ANSIBLE=$(command -v ansible )
[ ! -x "${ANSIBLE}" ] && return

local ANSIBLE_PYTHON=$(head -1 ${ANSIBLE})
local ANSIBLE_PYTHON_PATH=$(dirname ${${(s: :)ANSIBLE_PYTHON}[1]:s/\#\!/})

alias ansible-pip="${ANSIBLE_PYTHON_PATH}/pip3"

if [ -x "${ANSIBLE_PATH}/tower-cli" ] ; then
	alias tower-cli="${ANSIBLE_PATH}/tower-cli"
fi

unset ANSIBLE
