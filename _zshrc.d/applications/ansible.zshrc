ANSIBLE=$(which ansible 2>/dev/null)

if [ -x "${ANSIBLE}" ] ; then
	ANSIBLE_PATH="$(dirname $( head -1 $(which ansible) | sed -e 's/^\#\!//' ))"
	alias ansible-pip="${ANSIBLE_PATH}/pip"
fi

if [ -x "${ANSIBLE_PATH}/tower-cli" ] ; then
	alias tower-cli="${ANSIBLE_PATH}/tower-cli"
fi
